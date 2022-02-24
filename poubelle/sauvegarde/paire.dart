import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'quizz.dart';

class Paire extends StatefulWidget {
  final folderPath;
  Paire(this.folderPath);
  @override
  _PaireState createState() => _PaireState(this.folderPath);
}

class _PaireState extends State<Paire> {
  final folderPath;
  _PaireState(this.folderPath);

  //others
  int click_count = 0;
  int index_last_click = -1;
  int error = 0;
  int sucess = 0;
  List<bool> display = List.filled(12, true);
  List<bool> green = List.filled(12, false);
  String first_value = '';
  String scnd_value = '';

  // words
  late List<String> ids_learning = import_list(file_learning);
  late List<String> en_learning = import_list(file_en_learning);
  late List<String> fr_learning = import_list(file_fr_learning);
  late List<String> sub_ids_learning = ids_learning.getRange(0, 6).toList();
  late List<String> sub_en_learning =
      process(en_learning.getRange(0, 6).toList());
  late List<String> sub_fr_learning =
      process(fr_learning.getRange(0, 6).toList());
  late List<String> sub_shuffle = shuffle(sub_en_learning + sub_fr_learning);

  //ids
  String values_learning = '';
  String values_notlearn = '';
  String values_learned = '';
  String file_learning = 'list_learning.txt';
  String file_notlearn = 'list_notlearning.txt';
  String file_learned = 'list_learned.txt';
  //mots en
  String values_en_learning = '';
  String values_en_learned = '';
  String file_en_learning = 'list_en_learning.txt';
  String file_en_learned = 'list_en_learned.txt';
  //mots en
  String values_fr_learning = '';
  String values_fr_learned = '';
  String file_fr_learning = 'list_fr_learning.txt';
  String file_fr_learned = 'list_fr_learned.txt';

  //----fonctions intermédiaires intro ---------------------------------------
  process(list) {
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i]
          .replaceAll('/ ', '/')
          .replaceAll('   ', ' ')
          .replaceAll('  ', ' ')
          .replaceAll(' ', '\n');
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

  //----fonctions finales-----------------------------------------------------
  onPressed(i) {
    if (index_last_click == i) {
      return;
    }
    setState(() {
      click_count++;
    });
    if (click_count == 1) {
      setState(() {
        first_value = sub_shuffle[i];
        green[i] = true;
        index_last_click = i;
      });
    } else {
      setState(() {
        click_count = 0;
        scnd_value = sub_shuffle[i];
      });
      if ((sub_en_learning.indexOf(first_value) ==
              sub_fr_learning.indexOf(scnd_value)) &
          (sub_fr_learning.indexOf(first_value) ==
              sub_en_learning.indexOf(scnd_value))) {
        setState(() {
          display[i] = false;
          display[index_last_click] = false;
          index_last_click = -1;
          sucess++;
        });
      } else {
        setState(() {
          green[index_last_click] = false;
          error++;
          index_last_click = -1;
          if (error > 4) {
            green = List.filled(12, false);
            display = List.filled(12, true);
            setState(() {
              error = 0;
            });
          }
        });
      }
    }
    if (sucess == 6) {
      go_to_quizz();
    }
  }

  go_to_quizz() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Quizz(folderPath)));
  }

  //----fonctions de debug-----------------------------------------------------
  restart() {
    setState(() {
      click_count = 0;
      index_last_click = -1;
      error = 0;
      display = List.filled(12, true);
      green = List.filled(12, false);
      first_value = '';
      scnd_value = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Etape 1/4 : les paires'),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Erreurs: $error'),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                    ),
                    onPressed: go_to_quizz,
                    child: Text('Skip')),
                if (display[0])
                  Flexible(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: green[0] ? Colors.green : Colors.blue,
                          ),
                          onPressed: () => onPressed(0),
                          child: Text(sub_shuffle[0]))),
                if (display[1])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[1] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(1),
                        child: Text(sub_shuffle[1])),
                  ),
                if (display[2])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[2] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(2),
                        child: Text(sub_shuffle[2])),
                  ),
                if (display[3])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[3] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(3),
                        child: Text(sub_shuffle[3])),
                  ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Column(
              children: [
                if (display[4])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[4] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(4),
                        child: Text(sub_shuffle[4])),
                  ),
                if (display[5])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[5] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(5),
                        child: Text(sub_shuffle[5])),
                  ),
                if (display[6])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[6] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(6),
                        child: Text(sub_shuffle[6])),
                  ),
                if (display[7])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[7] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(7),
                        child: Text(sub_shuffle[7])),
                  ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Column(
              children: [
                if (display[8])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[8] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(8),
                        child: Text(sub_shuffle[8])),
                  ),
                if (display[9])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[9] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(9),
                        child: Text(sub_shuffle[9])),
                  ),
                if (display[10])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[10] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(10),
                        child: Text(sub_shuffle[10])),
                  ),
                if (display[11])
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: green[11] ? Colors.green : Colors.blue,
                        ),
                        onPressed: () => onPressed(11),
                        child: Text(sub_shuffle[11])),
                  ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            // Flexible(
            //     child:
            //         ElevatedButton(onPressed: restart, child: Text('Restart'))),
          ],
        ),
      ),
    );
  }
}
