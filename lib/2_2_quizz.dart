import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '2_1_paire.dart';
import '2_3_fuzzy.dart';
import '2_4_2_sort_one.dart';
import '2_4_1_sort_multi.dart';

import '_global_functions.dart';
import '_global_variables.dart';

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
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = int.parse(liste_settings[1]);
  late int nb_questions = int.parse(liste_settings[3]);
  late String speak = liste_settings[19];
  late String learn = liste_settings[21];
  //others
  int index = 0;
  int error = 0;
  late List<bool> is_red = List.filled(nb_questions, false);
  //mots en
  late String file_learn_learning = get_file_learn_learning(learn);
  //mots fr
  late String file_speak_learning = get_file_speak_learning(speak);
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
  late List<String> sub_en_learning =
      process(en_learning.getRange(0, nb_batch).toList());
  late List<List<String>> quizz_words = get_quizz_words(sub_en_learning);
//----fonctions intermédiaires intro ---------------------------------------

  get_quizz_words(sub_speak_learning) {
    List<List<String>> quizz_words = [];
    for (int i = 0; i < nb_batch; i++) {
      List<String> del = [];
      del.add([...sub_speak_learning][i]);
      List<String> del_fr = [...sub_speak_learning];
      del_fr.remove(sub_speak_learning[i]);
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
    bool prefer_multi = (liste_settings[17] == 'true');
    if (step_3) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Fuzzy(folderPath)));
    }
    if (prefer_multi) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => SortMulti(folderPath)));
    } else {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => SortOne(folderPath)));
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
              onPressed: () => pushButton(i),
              child: Text(quizz_words[index][i],
                  style: TextStyle(
                    color: Colors.white,
                  )))));
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
                backgroundColor: Colors.blue,
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                title: Row(children: [
                  Text(
                    '2/4 Quizz Game',
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
                                sub_speak_learning[index],
                                style: TextStyle(
                                    fontSize: 25, color: Colors.black),
                              )),
                            )),
                        ...children_buttons,
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                )),
                            onPressed: go_to_fuzzy,
                            child: Text('Skip',
                                style: TextStyle(
                                  color: Colors.white,
                                )))
                      ],
                    ))))));
  }
}
