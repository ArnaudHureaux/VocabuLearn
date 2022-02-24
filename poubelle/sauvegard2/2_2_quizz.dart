import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '2_3_fuzzy.dart';
import 'package:Vocabulearn/2_4_sort.dart';
import '2_1_paire.dart';

class Quizz extends StatefulWidget {
  final folderPath;
  Quizz(this.folderPath);
  @override
  _QuizzState createState() => _QuizzState(this.folderPath);
}

class _QuizzState extends State<Quizz> {
  final folderPath;
  _QuizzState(this.folderPath);

  //to dynamise
  late List<String> liste_settings = import_setting_sync();
  late int nb_batch = int.parse(liste_settings[1]);
  late int nb_questions = int.parse(liste_settings[3]);
  //others
  int index = 0;
  int error = 0;
  late List<bool> is_red = List.filled(nb_questions, false);
  //mots en
  String file_en_learning = 'list_en_learning.txt';
  //mots fr
  String file_fr_learning = 'list_fr_learning.txt';
  // words
  late List<String> en_learning = import_list_sync(file_en_learning);
  late List<String> fr_learning = import_list_sync(file_fr_learning);
  late List<String> sub_fr_learning =
      process(fr_learning.getRange(0, nb_batch).toList());
  late List<String> sub_en_learning =
      process(en_learning.getRange(0, nb_batch).toList());
  late List<List<String>> quizz_words = get_quizz_words(sub_en_learning);
//----fonctions intermédiaires intro ---------------------------------------
  import_setting_sync() {
    final file = File('$folderPath/settings.txt');
    List<String> lines = file.readAsLinesSync();
    if (lines.length == 0) {
      String content_str =
          'nb_batch,6,nb_questions,5,similarity_threshold,80,step_1,true,step_2,true,step_3,true,difficulty,2';
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

  get_quizz_words(sub_fr_learning) {
    List<List<String>> quizz_words = [];
    for (int i = 0; i < nb_batch; i++) {
      List<String> del = [];
      del.add([...sub_fr_learning][i]);
      List<String> del_fr = [...sub_fr_learning];
      del_fr.remove(sub_fr_learning[i]);
      del_fr.shuffle();
      for (var j = 0; j < nb_questions - 1; j++) {
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
    bool step_1 = (liste_settings[7] == 'true');
    bool step_2 = (liste_settings[9] == 'true');
    bool step_3 = (liste_settings[11] == 'true');
    if (step_3) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Fuzzy(folderPath)));
    } else {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Sort(folderPath)));
    }
  }

  //----fonctions finales-----------------------------------------------------
  pushButton(i) async {
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
        is_red[i] = true;
      });
      await Future.delayed(const Duration(milliseconds: 200), () {});
      setState(() {
        is_red[i] = false;
      });
    }
  }

  Future<bool> _willPopCallback() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Paire(folderPath)));
    return true; // return true if the route to be popped
  }

  //----fonctions de debug-----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    List<SizedBox> children_buttons = [];
    for (int i = 0; i < nb_questions; i++) {
      children_buttons.add(SizedBox(
          height: 35,
          width: 200,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: is_red[i] ? Colors.red : Colors.blue,
                padding: EdgeInsets.all(4),
              ),
              onPressed: () => pushButton(i),
              child: Text(quizz_words[index][i]))));
    }
    Image appLogo = new Image(
        image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
        height: 28.0,
        width: 28.0,
        alignment: FractionalOffset.center);
    ;
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                //automaticallyImplyLeading: false,
                title: Row(children: [
              Text('Etape 2/4: Jeu des Quizz'),
              Expanded(child: Container()),
              appLogo
            ])),
            body: SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: (nb_questions < 9)
                          ? 0.8 * MediaQuery.of(context).size.height
                          : nb_questions /
                              9 *
                              0.8 *
                              MediaQuery.of(context).size.height,
                    ),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 70,
                            width: 200,
                            child: Card(
                              child: Center(
                                  child: Text(
                                sub_fr_learning[index],
                                style: TextStyle(fontSize: 25),
                              )),
                            )),
                        ...children_buttons,
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                            ),
                            onPressed: go_to_fuzzy,
                            child: Text('Skip'))
                      ],
                    ))))));
  }
}
