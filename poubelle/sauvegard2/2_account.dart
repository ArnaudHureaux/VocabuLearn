import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  String file_en_learning = 'list_en_learning.txt';
  String file_fr_learning = 'list_fr_learning.txt';
  String file_en_learned = 'list_en_learned.txt';
  String file_fr_learned = 'list_fr_learned.txt';
  String file_ids_notlearn = 'list_notlearning.txt';
  //listes de mots
  late List en_learning = import_list_sync(file_en_learning);
  late List fr_learning = import_list_sync(file_fr_learning);
  late List en_learned = import_list_sync(file_en_learned);
  late List fr_learned = import_list_sync(file_fr_learned);
  late List ids_notlearn = import_list_sync(file_ids_notlearn);
  //other late
  late int nb_mot_learned = en_learned.length;
  late int nb_mot_learning = en_learning.length;
  late int nb_mot_declined = ids_notlearn.length;
  //----fonctions intermédiaires intro ---------------------------------------
  import_list_sync(file_name) {
    final file = File('$folderPath/$file_name');
    List<String> lines = file.readAsLinesSync();
    if (lines.length == 0) {
      return [];
    }
    String content = lines[0];
    return content.split(',');
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
