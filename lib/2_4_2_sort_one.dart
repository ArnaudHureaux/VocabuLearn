import 'package:VocabuLearn/2_4_1_sort_multi.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '1_home.dart';
import '2_3_fuzzy.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class SortOne extends StatefulWidget {
  final folderPath;
  SortOne(this.folderPath);
  @override
  _SortOneState createState() => _SortOneState(this.folderPath);
}

class _SortOneState extends State<SortOne> {
  final folderPath;
  _SortOneState(this.folderPath);

  //others
  int index = -1;
  List _informations = [
    'Cela signifie que ce mot vous sera reproposé la prochaine fois que lancerez un apprentissage.',
    'Cela signifie que ce mot sera mis à la fin de votre liste de mots à apprendre actuelle, et vous sera reproposé plus tard.',
    'Cela signifie que ce mot sera considéré comme appris et qu\'il ne vous sera plus proposé.'
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
  // index
  late int number = 0;
  late int number_max = sub_learn_learning.length;
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

  // variables
  late List<String> tronc_learn_learning =
      en_learning.getRange(nb_batch, en_learning.length).toList();
  late List<String> tronc_speak_learning =
      fr_learning.getRange(nb_batch, en_learning.length).toList();
  late List<String> en_learning_start = [];
  late List<String> fr_learning_start = [];
  late List<String> en_learning_end = [];
  late List<String> fr_learning_end = [];
  late List<String> en_learned_start = [];
  late List<String> fr_learned_start = [];

  //----fonctions finales-----------------------------------------------------

  _continuer() {
    setState(() {
      en_learning_start.add(sub_learn_learning[number]);
      fr_learning_start.add(sub_speak_learning[number]);
      number++;
      print("2_4_2_sort _continuer $number");
    });

    if (number == number_max) {
      _end();
    }
  }

  _plus_tard() {
    setState(() {
      en_learning_end.add(sub_learn_learning[number]);
      fr_learning_end.add(sub_speak_learning[number]);
      number++;
      print("2_4_2_sort _plus_tard $number");
    });

    if (number == number_max) {
      _end();
    }
  }

  _appris() {
    setState(() {
      en_learned_start.add(sub_learn_learning[number]);
      fr_learned_start.add(sub_speak_learning[number]);
      number++;
      print("2_4_2_sort _appris $number");
    });

    if (number == number_max) {
      _end();
    }
  }

  _end() {
    String new_content_learn_learned =
        from_list_to_string([...en_learned_start, ...en_learned]);
    String new_content_speak_learned =
        from_list_to_string([...fr_learned_start, ...fr_learned]);
    String new_content_learn_learning = from_list_to_string(
        [...en_learning_start, ...tronc_learn_learning, ...en_learning_end]);
    String new_content_speak_learning = from_list_to_string(
        [...fr_learning_start, ...tronc_speak_learning, ...fr_learning_end]);
    export_list(file_learn_learned, new_content_learn_learned);
    export_list(file_speak_learned, new_content_speak_learned);
    export_list(file_learn_learning, new_content_learn_learning);
    export_list(file_speak_learning, new_content_speak_learning);
    restart_SortOne();
    go_to_home();
  }

  go_to_sort_multi() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    liste_settings[17] = "true";
    save_settings(liste_settings, folderPath);
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SortMulti(folderPath)));
  }

  get_info(i) {
    setState(() {
      index = i;
      display_info = true;
    });
  }

  Future<bool> _willPopCallback() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    print("2_4_2_sort _willPopCallback $folderPath");
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Fuzzy(folderPath)));
    return true; // return true if the route to be popped
  }

  //----fonction de debug-----------------------------------------------------
  restart_SortOne() {
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
    List functions = [
      [_continuer, _plus_tard, _appris],
      [() => get_info(0), () => get_info(1), () => get_info(2)]
    ];
    List<Row> children_columns = [];
    for (var i = 0; i < 3; i++) {
      children_columns
          .add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 200, // Définissez la largeur souhaitée ici
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
                onPressed: functions[0][i],
                child: Text(texts[i]))),
        SizedBox(
            width: 30,
            // height: 36,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: index == i ? Colors.green : Colors.blue,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
                onPressed: (functions[1][i]),
                child: Icon(
                  Icons.info,
                  size: 18.0,
                  color: Colors.white,
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
                backgroundColor: Colors.blue,
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                title: Row(children: [
                  Text(
                    'Step 4/4: Sorting',
                    style: TextStyle(
                      color: Colors.white, // Set text color to black
                    ),
                  ),
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
                                      child: (number < number_max)
                                          ? Text(
                                              'How classify this word ? (${number + 1}/$number_max)',
                                              style: TextStyle(fontSize: 20),
                                            )
                                          : Text(
                                              'What to do with this word ? (${number}/$number_max)',
                                              style: TextStyle(fontSize: 20),
                                            )))),
                          Row(
                            children: [
                              SizedBox(
                                  height: 60,
                                  width: 280,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    child: Center(
                                      child: (number < number_max)
                                          ? Text(
                                              sub_learn_learning[number] +
                                                  ' : ' +
                                                  sub_speak_learning[number],
                                              style: TextStyle(fontSize: 15),
                                            )
                                          : Text(
                                              sub_learn_learning[
                                                      number_max - 1] +
                                                  ' : ' +
                                                  sub_speak_learning[
                                                      number_max - 1],
                                              style: TextStyle(fontSize: 15),
                                            ),
                                    ),
                                  )),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                              onPressed: go_to_sort_multi,
                              child: Text('Sort by batch',
                                  style: TextStyle(
                                    color: Colors.white,
                                  )))
                        ]))))));
  }
}
