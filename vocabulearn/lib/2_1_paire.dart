import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import '1_home.dart';
import '2_2_quizz.dart';
import '2_3_fuzzy.dart';
import '2_4_2_sort_one.dart';
import '2_4_1_sort_multi.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class Paire extends StatefulWidget {
  final folderPath;
  Paire(this.folderPath);
  @override
  _PaireState createState() => _PaireState(this.folderPath);
}

class _PaireState extends State<Paire> {
  final folderPath;
  _PaireState(this.folderPath) {
    print(
        "2_1_paire liste_settings ${liste_settings.length}, Accessing index: 19 & 21");
  }
  //settings
  //settings
  // late List<String> liste_settings = import_setting_sync(folderPath);
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = min(int.parse(liste_settings[1]), en_learning.length);
  late String speak = liste_settings[19];
  late String learn = liste_settings[21];
  //others
  bool is_red = false;
  int click_count = 0;
  int index_last_click = -1;
  int error = 0;
  int life_point = 5;
  int sucess = 0;
  late List<bool> display = List.filled(nb_batch * 2, true);
  late List<bool> green = List.filled(nb_batch * 2, false);
  String first_value = '';
  String scnd_value = '';
  late List<bool> is_english = french_or_english();
  // words
  late List<String> ids_learning = import_list_sync(file_learning, folderPath);
  late List<String> en_raw_learning =
      import_list_sync(file_learn_learning, folderPath);
  late List<String> fr_raw_learning =
      import_list_sync(file_speak_learning, folderPath);
  late List<List<String>> new_lists =
      remove_empty(en_raw_learning, fr_raw_learning);
  late List<String> en_learning = new_lists[0];
  late List<String> fr_learning = new_lists[1];

  late List<String> sub_ids_learning =
      ids_learning.getRange(0, nb_batch).toList();
  late List<String> sub_learn_learning =
      process(en_learning.getRange(0, nb_batch).toList());
  late List<String> sub_speak_learning =
      process(fr_learning.getRange(0, nb_batch).toList());
  late List<String> sub_shuffle =
      shuffle(sub_learn_learning + sub_speak_learning);

  //ids
  String values_learning = '';
  String values_notlearn = '';
  String values_learned = '';
  late String file_learning = get_file_learning(speak, learn);
  late String file_notlearn = get_file_notlearn(speak, learn);
  late String file_learned = get_file_learned(speak, learn);
  //mots en
  String values_learn_learning = '';
  String values_learn_learned = '';
  late String file_learn_learning = get_file_learn_learning(learn);
  late String file_learn_learned = get_file_learn_learned(learn);

  //mots fr
  String values_speak_learning = '';
  String values_speak_learned = '';

  late String file_speak_learned = get_file_speak_learned(speak);
  late String file_speak_learning = get_file_speak_learning(speak);
  //----fonctions intermédiaires intro ---------------------------------------
  french_or_english() {
    List<bool> is_english = [];
    for (var word in sub_shuffle) {
      if (sub_learn_learning.contains(word)) {
        is_english.add(true);
      } else {
        is_english.add(false);
      }
    }
    return is_english;
  }

  //----fonctions finales-----------------------------------------------------
  onPressed(i) async {
    if ((index_last_click == i) & green[i]) {
      setState(() {
        green[i] = false;
        click_count = 0;
      });
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
      if ((sub_learn_learning.indexOf(first_value) ==
              sub_speak_learning.indexOf(scnd_value)) &
          (sub_speak_learning.indexOf(first_value) ==
              sub_learn_learning.indexOf(scnd_value))) {
        setState(() {
          display[i] = false;
          display[index_last_click] = false;
          index_last_click = -1;
          sucess++;
        });
      } else {
        setState(() {
          green[index_last_click] = false;
          is_red = true;
          error++;
          life_point--;
          index_last_click = -1;
          if (error > 4) {
            green = List.filled(nb_batch * 2, false);
            display = List.filled(nb_batch * 2, true);
            setState(() {
              error = 0;
              life_point = 5;
            });
          }
        });
        await Future.delayed(const Duration(milliseconds: 200), () {});
        setState(() {
          is_red = false;
        });
      }
    }
    if (sucess == nb_batch) {
      go_to_quizz();
    }
  }

  go_to_quizz() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    bool step_1 = (liste_settings[7] == 'true');
    bool step_2 = (liste_settings[9] == 'true');
    bool step_3 = (liste_settings[11] == 'true');
    bool prefer_multi = (liste_settings[17] == 'true');
    if (step_2) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Quizz(folderPath)));
    }
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

  Future<bool> _willPopCallback() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(speak, learn)));
    return true; // return true if the route to be popped
  }

  //----fonctions de debug-----------------------------------------------------
  restart_paire() {
    setState(() {
      click_count = 0;
      index_last_click = -1;
      error = 0;
      life_point = 5;
      display = List.filled(nb_batch * 2, true);
      green = List.filled(nb_batch * 2, false);
      first_value = '';
      scnd_value = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Column> children_column = [];
    List<SizedBox> last_element = [];
    List<SizedBox> first_element = [];
    double height = 35;
    double width = 60;
    first_element.add(SizedBox(
        height: height,
        width: width * 1.7,
        child: Center(
            child: Card(
                margin: EdgeInsets.all(0.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: is_red ? Colors.red : Colors.white,
                child: Text(
                  'Lifes: $life_point',
                  style: TextStyle(fontSize: 20),
                )))));
    first_element.add(SizedBox(height: height, width: width, child: null));
    first_element.add(SizedBox(height: height, width: width, child: null));

    last_element.add(SizedBox(height: height, width: width, child: null));
    last_element.add(SizedBox(
        height: height,
        width: width + 25,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
            onPressed: go_to_quizz,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white,
              ),
            ))));
    last_element.add(SizedBox(height: height, width: width, child: null));

    for (var j = 0; j < 3; j++) {
      List<SizedBox> children_row = [];
      children_row.add(first_element[j]);
      for (var i = 0; i < nb_batch * 2 / 3; i++) {
        int l = (j * nb_batch * 2 / 3 + i).toInt();
        if ((display[l])) {
          children_row.add(SizedBox(
            height: 50,
            width: 90,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  primary: green[l]
                      ? Colors.green
                      : is_english[l]
                          ? Colors.deepPurple.shade300
                          : Colors.blue.shade400,
                  padding: EdgeInsets.all(4),
                ),
                onPressed: () => onPressed(l),
                child: Text(sub_shuffle[l],
                    style: TextStyle(
                      color: Colors.white,
                    ))),
          ));
        }
      }
      children_row.add(last_element[j]);
      children_column.add(Column(
        children: children_row,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ));
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
                  '1/4 Peer Group Game',
                  style: TextStyle(
                    color: Colors.white, // Set text color to black
                  ),
                ),
                Expanded(child: Container()),
                appLogo
              ]),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: (nb_batch < 12)
                          ? 0.9 * MediaQuery.of(context).size.height
                          : (nb_batch / 9) *
                              0.9 *
                              MediaQuery.of(context).size.height,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children_column,
                      ),
                    )))));
  }
}
