import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'fuzzy.dart';

class Quizz extends StatefulWidget {
  final folderPath;
  Quizz(this.folderPath);
  @override
  _QuizzState createState() => _QuizzState(this.folderPath);
}

class _QuizzState extends State<Quizz> {
  final folderPath;
  _QuizzState(this.folderPath);

  //others
  int index = 0;
  int error = 0;
  //mots en
  String file_en_learning = 'list_en_learning.txt';
  //mots fr
  String file_fr_learning = 'list_fr_learning.txt';
  // words
  late List<String> en_learning = import_list(file_en_learning);
  late List<String> fr_learning = import_list(file_fr_learning);
  late List<String> sub_fr_learning =
      process(fr_learning.getRange(0, 6).toList());
  late List<String> sub_en_learning =
      process(en_learning.getRange(0, 6).toList());
  late List<List<String>> quizz_words = get_quizz_words(sub_en_learning);
//----fonctions intermédiaires intro ---------------------------------------
  process(list) {
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i]
          .replaceAll('/ ', '/')
          .replaceAll('   ', ' ')
          .replaceAll('  ', ' ')
          .replaceAll(' /', '/');
    }
    return list;
  }

  shuffle(list) {
    list.shuffle();
    return list;
  }

  import_list(file_name) {
    final file = File('$folderPath/$file_name');
    List<String> lines = file.readAsLinesSync();
    String content = lines[0];
    return content.split(',');
  }

  get_quizz_words(sub_fr_learning) {
    List<List<String>> quizz_words = [];
    for (int i = 0; i < 6; i++) {
      List<String> del = [];
      del.add([...sub_fr_learning][i]);
      List<String> del_fr = [...sub_fr_learning];
      del_fr.remove(sub_fr_learning[i]);
      del_fr.shuffle();
      for (var j = 0; j < 3; j++) {
        del.add(del_fr[j]);
      }
      del.shuffle();
      quizz_words.add(del);
    }
    return quizz_words;
  }

  go_to_fuzzy() async {
    setState(() {
      index = 0;
      error = 0;
    });
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Fuzzy(folderPath)));
  }

  //----fonctions finales-----------------------------------------------------
  pushButton(i) {
    if (sub_en_learning.indexOf(quizz_words[index][i]) == index) {
      if (index >= sub_en_learning.length - 1) {
        go_to_fuzzy();
      } else {
        setState(() {
          index++;
        });
      }
    } else {
      setState(() {
        error++;
      });
    }
  }

  //----fonctions de debug-----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('Etape 2/4 : les quizz')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(sub_fr_learning[index]),
            ElevatedButton(
                onPressed: () => pushButton(0),
                child: Text(quizz_words[index][0])),
            ElevatedButton(
                onPressed: () => pushButton(1),
                child: Text(quizz_words[index][1])),
            ElevatedButton(
                onPressed: () => pushButton(2),
                child: Text(quizz_words[index][2])),
            ElevatedButton(
                onPressed: () => pushButton(3),
                child: Text(quizz_words[index][3])),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                ),
                onPressed: go_to_fuzzy,
                child: Text('Skip'))
          ],
        )));
  }
}
