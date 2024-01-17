import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '1_home.dart';
import '2_pay.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class Trouver extends StatefulWidget {
  final String folderPath;
  final List all;
  final List all_filter;
  Trouver(this.folderPath, this.all, this.all_filter);
  @override
  _TrouverState createState() =>
      _TrouverState(this.folderPath, this.all, this.all_filter);
}

class _TrouverState extends State<Trouver> {
  final String folderPath;
  final List all;
  final List all_filter;
  _TrouverState(this.folderPath, this.all, this.all_filter);
  //settings
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = int.parse(liste_settings[1]);
  late int difficulty = int.parse(liste_settings[13]);
  late int nb_words_max = 1000000; //int.parse(liste_settings[15]);
  late String speak = liste_settings[19];
  late String learn = liste_settings[21];
  //current number of words
  late List list_learn_learning =
      import_list_sync(file_learn_learning, folderPath);
  late List list_learn_learned =
      import_list_sync(file_learn_learned, folderPath);
  late List list_learn_learning_count = remove_empty(list_learn_learning);
  late List list_learn_learned_count = remove_empty(list_learn_learned);
  late int nb_learning = list_learn_learning_count.length;
  late int nb_learned = list_learn_learned_count.length;
  late int current_number = nb_learned + nb_learning;

  // pour gérer l'affichage
  int window = 10;
  bool loading2 = false;
  bool need_sauvegarde = true;
  List<int> index_diff = List.filled(20, 0);
  int sub_index = 0;
  int nb_notlearn = 0;
  late int min_nb_word = nb_batch;
  //ids
  String values_learning = '';
  String values_notlearn = '';
  String values_learned = '';
  late String file_learning = get_file_learning(speak, learn);
  late String file_notlearn = get_file_notlearn(speak, learn);
  late String file_learned = get_file_learned(speak, learn);
  //mots fr & en
  String values_learn_learning = '';
  String values_speak_learning = '';
  String values_learn_learned = '';
  String values_speak_learned = '';
  //mots en
  late String file_learn_learning = get_file_learn_learning(learn);
  late String file_learn_learned = get_file_learn_learned(learn);
  //mots fr
  late String file_speak_learning = get_file_speak_learning(speak);
  late String file_speak_learned = get_file_speak_learned(speak);
  // cette variable sert à gérer le cas où l'user parcourt la totalité des mots
  late int max_length = all_filter[0][difficulty].length;
  //----fonctions intermédiaires----------------------------------------------
  remove_empty(List list) {
    list.removeWhere((value) => value == "");
    return list;
  }

  save_data_one(file_name, new_ids) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    if (new_ids.length != 0) {
      new_ids = new_ids.substring(0, new_ids.length - 1);
    }
    List lines = file.readAsLinesSync();
    if (lines.length == 0) {
      await file.writeAsString(new_ids);
    } else {
      String content = lines[0];
      await file.writeAsString(new_ids + ',' + content);
    }
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

  save_settings_difficulty(difficulty) {
    List<String> settings = import_setting_sync(folderPath);
    settings[13] = difficulty.toString();
    save_settings(settings, folderPath);
  }

  //----fonctions finales-----------------------------------------------------
  rightPush() async {
    setState(() {
      values_learning = values_learning +
          all_filter[0][difficulty][index_diff[difficulty]].toString() +
          ',';
      values_learn_learning = values_learn_learning +
          all_filter[1][difficulty][index_diff[difficulty]] +
          ',';
      values_speak_learning = values_speak_learning +
          all_filter[2][difficulty][index_diff[difficulty]] +
          ',';
      index_diff[difficulty] = index_diff[difficulty] + 1;
      sub_index++;
      nb_learning = nb_learning + 1;
      current_number = nb_learned + nb_learning;
      need_sauvegarde = true;

      if (current_number >= nb_words_max) {
        print(nb_words_max);
        go_to_pay(context);
      }
    });
    if (current_number >= nb_words_max) {
      await saveData();
    }
  }

  leftPush() {
    setState(() {
      values_notlearn = values_notlearn +
          all_filter[0][difficulty][index_diff[difficulty]].toString() +
          ',';
      index_diff[difficulty] = index_diff[difficulty] + 1;
      sub_index++;
      nb_notlearn = nb_notlearn + 1;
      need_sauvegarde = true;
    });
  }

  saveData() async {
    setState(() {
      loading2 = true;
    });
    await save_data_one(file_learning, values_learning);
    await save_data_one(file_notlearn, values_notlearn);
    await save_data_one(file_learned, values_learned);
    await save_data_one(file_learn_learning, values_learn_learning);
    await save_data_one(file_speak_learning, values_speak_learning);
    await save_data_one(file_learn_learned, '');
    await save_data_one(file_speak_learned, '');
    save_settings_difficulty(difficulty);
    setState(() {
      loading2 = false;
      sub_index = 0;
      need_sauvegarde = false;
      values_learning = '';
      values_notlearn = '';
      values_learned = '';
      values_learn_learning = '';
      values_speak_learning = '';
      values_learn_learned = '';
      values_speak_learned = '';
    });
  }

  moreDifficulty() {
    setState(() {
      difficulty = difficulty + 1;
      need_sauvegarde = true;
      sub_index++;
    });
  }

  lessDifficulty() {
    setState(() {
      difficulty = difficulty - 1;
      need_sauvegarde = true;
      sub_index++;
    });
  }

  Future<bool> _willPopCallback() async {
    if (sub_index > 0) {
      await saveData();
    }
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(speak, learn)));
    return true; // return true if the route to be popped
  }

  pushApprendre() async {
    await saveData();
    restart_trouver();
    go_to_paire(context);
    return;
  }
  //----fonctions de debug-----------------------------------------------------

  restart_trouver() {
    bool loading2 = false;
    List<int> index_diff = List.filled(20, 0);

    // String speak = liste_settings[19];
    // String learn = liste_settings[21];
    // String file_learn_learning = get_file_learn_learning(learn);
    // print(learn);
    // print(file_learn_learning);
    List list_learn_learning =
        import_list_sync(file_learn_learning, folderPath);
    int nb_learn = list_learn_learning.length;
    int nb_notlearn = 0;
    int min_nb_word = 12;
  }

  @override
  Widget build(BuildContext context) {
    List colors = [
      Colors.green.shade900,
      Colors.green.shade800,
      Colors.green.shade700,
      Colors.green.shade600,
      Colors.green.shade500,
      Colors.green.shade400,
      Colors.green.shade300,
      Colors.green.shade200,
      Colors.orange.shade200,
      Colors.orange.shade300,
      Colors.orange.shade400,
      Colors.orange.shade500,
      Colors.orange.shade600,
      Colors.orange.shade700,
      Colors.red.shade400,
      Colors.red.shade500,
      Colors.red.shade600,
      Colors.red.shade700,
      Colors.red.shade800,
      Colors.red.shade900,
    ];
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
              Text('Words selection !',
                  style: TextStyle(
                    color: Colors.white, // Set text color to black
                  )),
              Expanded(child: Container()),
              appLogo
            ]),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.all(10),
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed:
                        ((nb_learning >= min_nb_word)) ? pushApprendre : null,
                    child: Text(
                      'Learn my $nb_learning words (min: $nb_batch)',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 250,
                        height: 50,
                        child: Card(
                            child: Center(
                                child: Text(
                          'Difficulty/Occurence:  ${difficulty * 5}/100',
                          style: TextStyle(fontSize: 15),
                        )))),
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: ElevatedButton(
                            onPressed: difficulty > 1 ? lessDifficulty : null,
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green.shade300,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(0)),
                            child: Text(
                              '-',
                              style: TextStyle(fontSize: 25),
                            ))),
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: ElevatedButton(
                            onPressed:
                                (difficulty < 19) ? moreDifficulty : null,
                            style: ElevatedButton.styleFrom(
                                primary: Colors.red.shade300,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(0)),
                            child: Text(
                              '+',
                              style: TextStyle(fontSize: 25),
                            ))),
                  ],
                ),
                if (index_diff[difficulty] < max_length)
                  SizedBox(
                      height: 150,
                      width: 300,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            side: new BorderSide(
                                color: colors[difficulty], width: 1.0),
                            borderRadius: BorderRadius.circular(4.0)),
                        //shadowColor: Colors.green.shade600,
                        child: Center(
                          child: Text(
                            all_filter[1][difficulty][index_diff[difficulty]],
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      )),
                if (loading2) CircularProgressIndicator(),
                if (index_diff[difficulty] < max_length)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            primary: Colors.blue),
                        icon: Icon(
                          Icons.thumb_down_alt,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text(
                          'I already know him',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: loading2 ? null : leftPush,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            primary: Colors.blue),
                        icon: Icon(
                          Icons.thumb_up_alt,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text(
                          'I want to learn it',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: loading2 ? null : rightPush,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ));
  }
}
