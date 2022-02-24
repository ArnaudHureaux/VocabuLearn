import 'package:Vocabulearn/2_3_fuzzy.dart';
import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '1_home.dart';

class Sort extends StatefulWidget {
  final folderPath;
  Sort(this.folderPath);
  @override
  _SortState createState() => _SortState(this.folderPath);
}

class _SortState extends State<Sort> {
  final folderPath;
  _SortState(this.folderPath);

  //settings
  late List<String> liste_settings = import_setting_sync();
  late int nb_batch = int.parse(liste_settings[1]);
  //others
  int index = -1;
  List _informations = [
    'Cela signifie que ces mots vous seront reproposés la prochaine fois que lancerez un apprentissage.',
    'Cela signifie que ces mots seront mis à la fin de votre liste de mots à apprendre actuelle, et vous serons reproposés plus tard.',
    'Cela signifie que ces mots seront considérés comme appris et qu\'il ne vous seront plus proposés.'
  ];
  bool display_info = false;
  List texts = [
    'Continuer à les apprendre',
    '   Réapprendre plus tard  ',
    '  Classer comme appris  '
  ];

  //mots en
  String file_en_learning = 'list_en_learning.txt';
  String file_en_learned = 'list_en_learned.txt';
  //mots fr
  String file_fr_learning = 'list_fr_learning.txt';
  String file_fr_learned = 'list_fr_learned.txt';
  // words
  late List<String> en_learning = import_list_sync(file_en_learning);
  late List<String> fr_learning = import_list_sync(file_fr_learning);
  late List<String> sub_fr_learning =
      process(fr_learning.getRange(0, nb_batch).toList());
  late List<String> sub_en_learning =
      process(en_learning.getRange(0, nb_batch).toList());
  //----fonctions intermédiaires intro ---------------------------------------
  import_setting_sync() {
    final file = File('$folderPath/settings.txt');
    List<String> lines = file.readAsLinesSync();
    if (lines.length == 0) {
      String content_str =
          'nb_batch,6,nb_questions,5,similarity_threshold,80,step_1,true,step_2,true,step_3,true';
      file.writeAsString(content_str);
      return content_str.split(',');
    } else {
      List<String> content_list = lines[0].split(',');
      return content_list;
    }
  }

  process(list) {
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i]
          .replaceAll('/ ', '/')
          .replaceAll('   ', ' ')
          .replaceAll('  ', ' ');
    }
    return list;
  }

  shuffle(list) {
    list.shuffle();
    return list;
  }

  import_list_sync(file_name) {
    final file = File('$folderPath/$file_name');
    List<String> lines = file.readAsLinesSync();
    String content = lines[0];
    return content.split(',');
  }

  import_list_async(file_name) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    bool exist = await file.exists();
    if (!exist) {
      await file.writeAsString('');
      return [];
    }
    List<String> lines = file.readAsLinesSync();
    if (lines.length == 0) {
      return [];
    } else {
      String content = lines[0];
      return content.split(',');
    }
  }

  export_list(file_name, content) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    await file.writeAsString(content);
  }

  go_to_home() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home()));
  }

  list_go_to_end(list, nb) {
    List b = list.getRange(nb, list.length).toList();
    b = b + list.getRange(0, nb).toList();
    return b;
  }

  list_delete_start(list, nb) {
    list = list.getRange(nb, list.length).toList();
    return list;
  }

  from_list_to_string(list) {
    String new_string = list.join(',');
    return new_string;
  }

  //----fonctions finales-----------------------------------------------------
  get_info(i) {
    setState(() {
      index = i;
      display_info = true;
    });
  }

  _continuer() {
    restart_sort();
    go_to_home();
  }

  _plus_tard() {
    List new_list_en = list_go_to_end(en_learning, nb_batch);
    List new_list_fr = list_go_to_end(fr_learning, nb_batch);
    String new_content_en = from_list_to_string(new_list_en);
    String new_content_fr = from_list_to_string(new_list_fr);
    export_list(file_en_learning, new_content_en);
    export_list(file_fr_learning, new_content_fr);
    restart_sort();
    go_to_home();
  }

  _appris() async {
    List learned_en = await import_list_async(file_en_learned);
    List learned_fr = await import_list_async(file_fr_learned);
    String new_content_en_learned = from_list_to_string(
        [...en_learning.getRange(0, nb_batch).toList(), ...learned_en]);
    String new_content_fr_learned = from_list_to_string(
        [...fr_learning.getRange(0, nb_batch).toList(), ...learned_fr]);
    export_list(file_en_learned, new_content_en_learned);
    export_list(file_fr_learned, new_content_fr_learned);
    List new_list_en = list_delete_start(en_learning, nb_batch);
    List new_list_fr = list_delete_start(fr_learning, nb_batch);
    String new_content_en = from_list_to_string(new_list_en);
    String new_content_fr = from_list_to_string(new_list_fr);
    export_list(file_en_learning, new_content_en);
    export_list(file_fr_learning, new_content_fr);
    restart_sort();
    go_to_home();
  }

  Future<bool> _willPopCallback() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Fuzzy(folderPath)));
    return true; // return true if the route to be popped
  }

  //----fonction de debug-----------------------------------------------------
  restart_sort() {
    setState(() {
      bool display_info = false;
      int index = -1;
    });
  }

  //----liste de widget-------------------------------------------------------
  List<Widget> children_table = [];
  @override
  Widget build(BuildContext context) {
    List<TableRow> children_table = [];
    children_table.add(TableRow(children: [
      Center(child: Text('FRENCH')),
      Center(child: Text('ENGLISH'))
    ]));
    for (var i = 0; i < nb_batch; i++) {
      children_table.add(TableRow(children: [
        Center(child: Text(sub_fr_learning[i])),
        Center(child: Text(sub_en_learning[i]))
      ]));
    }
    List functions = [
      [_continuer, _plus_tard, _appris],
      [() => get_info(0), () => get_info(1), () => get_info(2)]
    ];
    List<Row> children_columns = [];
    for (var i = 0; i < 3; i++) {
      children_columns
          .add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: functions[0][i], child: Text(texts[i])),
        SizedBox(
            width: 30,
            height: 36,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: index == i ? Colors.green : Colors.blue,
                  padding: EdgeInsets.zero,
                ),
                onPressed: (functions[1][i]),
                child: Icon(
                  Icons.info,
                  size: 18.0,
                ))),
      ]));
    }
    Image appLogo = new Image(
        image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
        height: 28.0,
        width: 28.0,
        alignment: FractionalOffset.center);
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                title: Row(children: [
              Text('Etape 4/4: Classification'),
              Expanded(child: Container()),
              appLogo
            ])),
            body: SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: (nb_batch < 12)
                          ? 0.8 * MediaQuery.of(context).size.height
                          : nb_batch /
                              12 *
                              0.8 *
                              MediaQuery.of(context).size.height,
                    ),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                          SizedBox(
                              height: 50,
                              width: 300,
                              child: Card(
                                  child: Center(
                                      child: Text(
                                'Que faire de ces mots ?',
                                style: TextStyle(fontSize: 20),
                              )))),
                          Table(
                            textDirection: TextDirection.ltr,
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.bottom,
                            border: TableBorder.all(
                                width: 1.0, color: Colors.black),
                            children: children_table,
                          ),

                          ...children_columns,
                          if (display_info)
                            SizedBox(
                              width: 300,
                              height: 70,
                              child: Card(
                                  child: Row(
                                children: [
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info,
                                          size: 20.0,
                                        ),
                                      ]),
                                  Flexible(
                                    child: Text(_informations[index]),
                                  )
                                ],
                              )),
                            ),
                          // ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       primary: Colors.orange,
                          //     ),
                          //     onPressed: go_to_home,
                          //     child: Text('Skip'))
                        ]))))));
  }
}
