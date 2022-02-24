import 'package:flutter/material.dart';
import '_global_functions.dart';
import '_global_variables.dart';

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
  int index = 0;
  bool display = false;
  //file name
  //mots en
  String file_en_learning = get_file_en_learning();
  String file_en_learned = get_file_en_learned();
  //mots fr
  String file_fr_learning = get_file_fr_learning();
  String file_fr_learned = get_file_fr_learned();
  //ids
  String file_notlearn = get_file_notlearn();
  //listes de mots
  late List en_learning = import_list_sync(file_en_learning, folderPath);
  late List fr_learning = import_list_sync(file_fr_learning, folderPath);
  late List en_learned = import_list_sync(file_en_learned, folderPath);
  late List fr_learned = import_list_sync(file_fr_learned, folderPath);
  late List ids_notlearn = import_list_sync(file_notlearn, folderPath);
  //other late
  late int nb_mot_learned = en_learned.length;
  late int nb_mot_learning = en_learning.length;
  late int nb_mot_declined = ids_notlearn.length;

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

  @override
  Widget build(BuildContext context) {
    List<List> en_words = [en_learning, en_learned];
    List<List> fr_words = [fr_learning, fr_learned];
    List<TableRow> children_table = [];
    children_table.add(TableRow(children: [
      Center(child: Text('FRENCH')),
      Center(child: Text('ENGLISH'))
    ]));
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Row(children: [
        Text('Mes mots'),
        Expanded(child: Container()),
        appLogo
      ])),
      body: Scrollbar(
          child: SingleChildScrollView(
              child: Center(
                  child: Column(
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: ((index == 0) & display) ? Colors.green : Colors.blue,
              ),
              onPressed: _pushLearning,
              child: Text('Mots en cours d\'apprentissage: $nb_mot_learning')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: ((index == 1) & display) ? Colors.green : Colors.blue,
              ),
              onPressed: _pushLearned,
              child: Text('Mots appris: $nb_mot_learned')),

          // ElevatedButton(
          //     onPressed: null, child: Text('Mots refusés: $nb_mot_declined')),
          if (display)
            Table(
              textDirection: TextDirection.ltr,
              defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
              border: TableBorder.all(width: 1.0, color: Colors.black),
              children: children_table,
            )
        ],
      )))),
    );
  }
}
