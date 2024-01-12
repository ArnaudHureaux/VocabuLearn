import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '1_home.dart';
import '2_3_fuzzy.dart';
import '2_4_2_sort_one.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class SortMulti extends StatefulWidget {
  final folderPath;
  SortMulti(this.folderPath);
  @override
  _SortMultiState createState() => _SortMultiState(this.folderPath);
}

class _SortMultiState extends State<SortMulti> {
  final folderPath;
  _SortMultiState(this.folderPath);

  //others
  int index = -1;
  List _informations = [
    'This means that these words will be reproposed to you the next time you start learning.',
    'This means that these words will be put at the end of your current learning list, and will be offered to you later.',
    'This means that these words will be considered as learned and will not be offered again.',
  ];
  bool display_info = false;
  List texts = ['Keep learning them', ' Re-learn later  ', 'Sort as learned  '];

  //settings
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = int.parse(liste_settings[1]);
  late String speak = liste_settings[19];
  late String learn = liste_settings[21];
  //mots en
  late String file_learn_learning = get_file_learn_learning(learn);
  late String file_learn_learned = get_file_learn_learned(learn);
  //mots fr
  late String file_speak_learning = get_file_speak_learning(speak);
  late String file_speak_learned = get_file_speak_learned(speak);
  // words
  late List<String> en_raw_learning =
      import_list_sync(file_learn_learning, folderPath);
  late List<String> fr_raw_learning =
      import_list_sync(file_speak_learning, folderPath);
  late List<List<String>> new_lists =
      remove_empty(en_raw_learning, fr_raw_learning);
  late List<String> en_learning = new_lists[0];
  late List<String> fr_learning = new_lists[1];
  late List<String> sub_speak_learning =
      process(fr_learning.getRange(0, nb_batch).toList());
  late List<String> sub_learn_learning =
      process(en_learning.getRange(0, nb_batch).toList());

  late List<String> en_raw_learned =
      import_list_sync(file_learn_learned, folderPath);
  late List<String> fr_raw_learned =
      import_list_sync(file_speak_learned, folderPath);
  late List<List<String>> new_lists2 =
      remove_empty(en_raw_learned, fr_raw_learned);
  late List<String> en_learned = new_lists2[0];
  late List<String> fr_learned = new_lists2[1];
  //----fonctions intermédiaires intro ---------------------------------------
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
        context, MaterialPageRoute(builder: (context) => Home(speak, learn)));
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

  go_to_sort_one() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    liste_settings[17] = "false";
    save_settings(liste_settings, folderPath);
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SortOne(folderPath)));
  }

  //----fonctions finales-----------------------------------------------------
  get_info(i) {
    setState(() {
      if (i != index) {
        display_info = true;
      } else {
        display_info = !display_info;
      }
      ;
      index = i;
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
    export_list(file_learn_learning, new_content_en);
    export_list(file_speak_learning, new_content_fr);
    restart_sort();
    go_to_home();
  }

  _appris() {
    String new_content_learn_learned = from_list_to_string(
        [...en_learning.getRange(0, nb_batch).toList(), ...en_learned]);
    String new_content_speak_learned = from_list_to_string(
        [...fr_learning.getRange(0, nb_batch).toList(), ...fr_learned]);
    export_list(file_learn_learned, new_content_learn_learned);
    export_list(file_speak_learned, new_content_speak_learned);
    List new_list_en = list_delete_start(en_learning, nb_batch);
    List new_list_fr = list_delete_start(fr_learning, nb_batch);
    String new_content_en = from_list_to_string(new_list_en);
    String new_content_fr = from_list_to_string(new_list_fr);
    export_list(file_learn_learning, new_content_en);
    export_list(file_speak_learning, new_content_fr);
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
    children_table.add(TableRow(
        children: [Center(child: Text(speak)), Center(child: Text(learn))]));
    for (var i = 0; i < nb_batch; i++) {
      children_table.add(TableRow(children: [
        Center(child: Text(sub_speak_learning[i])),
        Center(child: Text(sub_learn_learning[i]))
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
                  primary: ((index == i) & (display_info))
                      ? Colors.green
                      : Colors.blue,
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
              Text('Step 4/4: Sorting'),
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
                                'What to do with these words ?',
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
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                              ),
                              onPressed: go_to_sort_one,
                              child: Text('Sort word by word'))
                        ]))))));
  }
}
