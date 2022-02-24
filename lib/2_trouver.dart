import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '1_home.dart';

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

  // pour gérer l'affichage
  int window = 10;
  bool loading2 = false;
  bool need_sauvegarde = true;
  List<int> index_diff = List.filled(20, 0);
  int sub_index = 0;
  late List list_en_learning = import_list_sync(file_en_learning, folderPath);
  late int nb_learn = list_en_learning.length;
  int nb_notlearn = 0;
  int min_nb_word = 12;
  //ids
  String values_learning = '';
  String values_notlearn = '';
  String values_learned = '';
  String file_learning = get_file_learning();
  String file_notlearn = get_file_notlearn();
  String file_learned = get_file_learned();
  //mots fr & en
  String values_en_learning = '';
  String values_fr_learning = '';
  String values_en_learned = '';
  String values_fr_learned = '';
  //mots en
  String file_en_learning = get_file_en_learning();
  String file_en_learned = get_file_en_learned();
  //mots fr
  String file_fr_learning = get_file_fr_learning();
  String file_fr_learned = get_file_fr_learned();
  // cette variable sert à gérer le cas où l'user parcourt la totalité des mots
  late int max_length = all_filter[0][difficulty].length;
  //----fonctions intermédiaires----------------------------------------------
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
      await file.writeAsString(content + ',' + new_ids);
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
  rightPush() {
    setState(() {
      values_learning = values_learning +
          all_filter[0][difficulty][index_diff[difficulty]] +
          ',';
      values_en_learning = values_en_learning +
          all_filter[1][difficulty][index_diff[difficulty]] +
          ',';
      values_fr_learning = values_fr_learning +
          all_filter[2][difficulty][index_diff[difficulty]] +
          ',';
      index_diff[difficulty] = index_diff[difficulty] + 1;
      sub_index++;
      nb_learn = nb_learn + 1;
      need_sauvegarde = true;
    });
  }

  leftPush() {
    setState(() {
      values_notlearn = values_notlearn +
          all_filter[0][difficulty][index_diff[difficulty]] +
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
    await save_data_one(file_en_learning, values_en_learning);
    await save_data_one(file_fr_learning, values_fr_learning);
    await save_data_one(file_en_learned, '');
    await save_data_one(file_fr_learned, '');
    save_settings_difficulty(difficulty);
    setState(() {
      loading2 = false;
      sub_index = 0;
      need_sauvegarde = false;
      values_learning = '';
      values_notlearn = '';
      values_learned = '';
      values_en_learning = '';
      values_fr_learning = '';
      values_en_learned = '';
      values_fr_learned = '';
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
        context, MaterialPageRoute(builder: (context) => Home()));
    return true; // return true if the route to be popped
  }

  pushApprendre() {
    restart_trouver();
    go_to_paire(context);
  }
  //----fonctions de debug-----------------------------------------------------

  restart_trouver() {
    bool loading2 = false;
    List<int> index_diff = List.filled(20, 0);
    late List list_en_learning =
        import_list_sync('list_en_learning.txt', folderPath);
    late int nb_learn = list_en_learning.length;
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
            title: Row(children: [
              Text('Séléction de mots'),
              Expanded(child: Container()),
              appLogo
            ]),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (need_sauvegarde)
                  ElevatedButton(
                      onPressed: (sub_index > 0) ? saveData : null,
                      child: Text('Sauvegarder mes choix')),
                if (!need_sauvegarde)
                  ElevatedButton(
                      onPressed:
                          ((nb_learn >= min_nb_word)) ? pushApprendre : null,
                      child: Text('Apprendre mes $nb_learn mots')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 250,
                        height: 50,
                        child: Card(
                            child: Center(
                                child: Text(
                          'Difficulté/Occurence:  ${difficulty * 5}/100',
                          style: TextStyle(fontSize: 15),
                        )))),
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: ElevatedButton(
                            onPressed: difficulty > 0 ? lessDifficulty : null,
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
                            padding: EdgeInsets.all(10)),
                        icon: Icon(
                          Icons.thumb_down_alt,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text('Je le connais déjà'),
                        onPressed: loading2 ? null : leftPush,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10)),
                        icon: Icon(
                          Icons.thumb_up_alt,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text('Je veux l\'apprendre'),
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
