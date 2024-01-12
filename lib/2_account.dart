import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '_global_functions.dart';
import '_global_variables.dart';
import '1_home.dart';

class Account extends StatefulWidget {
  final folderPath;
  Account(this.folderPath);
  @override
  _AccountState createState() => _AccountState(this.folderPath);
}

class _AccountState extends State<Account> {
  final folderPath;
  _AccountState(this.folderPath);
  //other
  late List<String> liste_settings = import_setting_sync(folderPath);
  late String speak = liste_settings[19];
  late String learn = liste_settings[21];
  int index = 0;
  bool display = false;
  bool popup = false;
  //file name
  //mots en
  late String file_learn_learning = get_file_learn_learning(learn);
  late String file_learn_learned = get_file_learn_learned(learn);
  //mots fr
  late String file_speak_learning = get_file_speak_learning(speak);
  late String file_speak_learned = get_file_speak_learned(speak);
  //ids
  late String file_notlearn = get_file_notlearn(speak, learn);
  //listes de mots
  late List<String> en_raw_learning =
      import_list_sync(file_learn_learning, folderPath);
  late List<String> fr_raw_learning =
      import_list_sync(file_speak_learning, folderPath);
  late List<List<String>> new_lists =
      remove_empty(en_raw_learning, fr_raw_learning);
  late List<String> en_learning = new_lists[0];
  late List<String> fr_learning = new_lists[1];

  late List<String> en_raw_learned =
      import_list_sync(file_learn_learned, folderPath);
  late List<String> fr_raw_learned =
      import_list_sync(file_speak_learned, folderPath);
  late List<List<String>> new_lists2 =
      remove_empty(en_raw_learned, fr_raw_learned);
  late List<String> en_learned = new_lists2[0];
  late List<String> fr_learned = new_lists2[1];

  late List ids_notlearn = import_list_sync(file_notlearn, folderPath);

  late List en_all = en_learning + en_learned;
  late List fr_all = fr_learning + fr_learned;
  //other late
  late int nb_mot_learned = en_learned.length;
  late int nb_mot_learning = en_learning.length;
  late int nb_mot_declined = ids_notlearn.length;

  //----fonctions intermédiaires
  save_data(file_name, new_list) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    List lines = file.readAsLinesSync();
    await file.writeAsString(new_list.join(','));
  }

  go_to_account() async {
    create_setting();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Account(folderPath)));
  }

  //----fonctions finales ----------------------------------------------------
  _pushLearning() {
    setState(() {
      index = 0;
      display = true;
    });
  }

  _pushLearned() {
    setState(() {
      index = 1;
      display = true;
    });
  }

  _pushReset() {
    setState(() {
      popup = !popup;
    });
  }

  _pushYes() async {
    await save_data(file_learn_learning, en_all);
    await save_data(file_speak_learning, fr_all);
    await save_data(file_learn_learned, []);
    await save_data(file_learn_learned, []);
    _pushReset();
    go_to_account();
  }

  Future<bool> _willPopCallback() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(speak, learn)));
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    List<List> en_words = [en_learning, en_learned];
    List<List> fr_words = [fr_learning, fr_learned];
    List<TableRow> children_table = [];
    children_table.add(TableRow(
        children: [Center(child: Text(learn)), Center(child: Text(speak))]));
    for (var i = 0; i < en_words[index].length; i++) {
      children_table.add(TableRow(children: [
        Center(child: Text(en_words[index][i])),
        Center(child: Text(fr_words[index][i]))
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
            Text('My words'),
            Expanded(child: Container()),
            appLogo
          ])),
          body: Scrollbar(
              child: SingleChildScrollView(
                  child: Center(
                      child: Column(
            mainAxisAlignment: (popup)
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              if (!popup)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary:
                          ((index == 0) & display) ? Colors.green : Colors.blue,
                    ),
                    onPressed: _pushLearning,
                    child: Text('Words being learned: $nb_mot_learning')),
              if (!popup)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary:
                          ((index == 1) & display) ? Colors.green : Colors.blue,
                    ),
                    onPressed: _pushLearned,
                    child: Text('Words learned: $nb_mot_learned')),

              // ElevatedButton(
              //     onPressed: null, child: Text('Mots refusés: $nb_mot_declined')),
              if (display & !popup)
                Table(
                  textDirection: TextDirection.ltr,
                  defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                  border: TableBorder.all(width: 1.0, color: Colors.black),
                  children: children_table,
                ),
              if ((!popup) & (en_learned.length > 0))
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange.shade300,
                    ),
                    onPressed: _pushReset,
                    child: Text('Relearn all my words')),
              if (popup)
                AlertDialog(
                  title: Text("Are you sure ?"),
                  content: Text(
                      "It will move every words of the category \"Learned\" in the category \"Words being learned\"."),
                  actions: [
                    Row(children: [
                      TextButton(
                        child: Text("Yes"),
                        onPressed: _pushYes,
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: _pushReset,
                      ),
                    ])
                  ],
                ),
            ],
          )))),
        ));
  }
}
