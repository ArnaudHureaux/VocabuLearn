import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import '2_4_2_sort_one.dart';
import '2_4_1_sort_multi.dart';
import '2_2_quizz.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class Fuzzy extends StatefulWidget {
  final folderPath;
  Fuzzy(this.folderPath);
  @override
  _FuzzyState createState() => _FuzzyState(this.folderPath);
}

class _FuzzyState extends State<Fuzzy> {
  final folderPath;
  _FuzzyState(this.folderPath) {
    print("2_3_fuzzy _FuzzyState speak $speak");
    print("2_3_fuzzy _FuzzyState learn $learn");
    print("2_3_fuzzy _FuzzyState file_learn_learning $file_learn_learning");
    print("2_3_fuzzy _FuzzyState file_speak_learning $file_speak_learning");
  }

  //settings
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = int.parse(liste_settings[1]);
  late int similarity_threshold = int.parse(liste_settings[5]);
  late String speak = liste_settings[19];
  late String learn = liste_settings[21];
  //others
  bool next = false;
  bool text = false;
  bool spoil = false;
  bool sucess = false;
  bool solution = false;
  int index = 0;
  String text_fail = '';
  String text_sucess = '';
  var _controller = TextEditingController();
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
//----fonctions intermédiaires intro ---------------------------------------

  go_to_sort() async {
    setState(() {
      index = 0;
    });
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    bool prefer_multi = (liste_settings[17] == 'true');
    if (prefer_multi) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => SortMulti(folderPath)));
    } else {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => SortOne(folderPath)));
    }
  }

  //----fonctions finales-----------------------------------------------------
  _fuzzyMatch(value) {
    int ratio_rate = ratio(sub_en_learning[index], value);
    if (ratio_rate > similarity_threshold) {
      setState(() {
        next = true;
        text = false;
        solution = true;
        sucess = true;
        spoil = false;
        text_sucess = 'Bravo, la similarité est de $ratio_rate% !';
      });
      if (ratio_rate > 99) {
        _nextPush();
      }
    } else {
      setState(() {
        text_fail = 'La similarité n\'est que de $ratio_rate%, try again !';
        solution = false;
        sucess = false;
        text = true;
        spoil = true;
      });
    }
  }

  _spoilPush() {
    setState(() {
      spoil = false;
      solution = true;
      next = true;
    });
  }

  _nextPush() {
    setState(() {
      _controller.clear();
      text = false;
      spoil = false;
      solution = false;
      sucess = false;
      next = false;
      _controller.clear();
    });
    if (index == sub_speak_learning.length - 1) {
      setState(() {
        index = 0;
      });
      go_to_sort();
    } else {
      setState(() {
        index++;
      });
    }
  }

  _submitPush(value) {
    if (sucess) {
      _nextPush();
    } else {}
  }

  Future<bool> _willPopCallback() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Quizz(folderPath)));
    return true; // return true if the route to be popped
  }

  Image appLogo = new Image(
      image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
      height: 28.0,
      width: 28.0,
      alignment: FractionalOffset.center);
  @override
  Widget build(BuildContext context) {
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
                    '3/4 Direct Translation',
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
                      maxHeight: 0.8 * MediaQuery.of(context).size.height,
                    ),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          SizedBox(
                              height: 40,
                              width: 350,
                              child: Card(
                                child: Center(
                                    child: Text(
                                  sub_speak_learning[index],
                                  style: TextStyle(fontSize: 20),
                                )),
                              )),
                          TextFormField(
                            onEditingComplete: () {},
                            controller: _controller,
                            textAlign: TextAlign.center,
                            decoration:
                                InputDecoration(hintText: 'Translate the word'),
                            onFieldSubmitted: _submitPush,
                            onChanged: _fuzzyMatch,
                            //validator: (value) => value.length>20 ? null:"Input too long",
                          ),
                          if (text) Text(text_fail),
                          if (spoil)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                )),
                                onPressed: _spoilPush,
                                child: Text('See the answer')),
                          if (sucess) Text(text_sucess),
                          if (solution)
                            Column(children: [
                              Text('The correct answer was:'),
                              SizedBox(height: 10),
                              Text(
                                sub_en_learning[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          if (next)
                            ElevatedButton(
                                onPressed: _nextPush,
                                child: Icon(Icons.arrow_forward_outlined)),
                          SizedBox(height: 200),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )),
                              onPressed: go_to_sort,
                              child: Text('Skip',
                                  style: TextStyle(
                                    color: Colors.white,
                                  )))
                        ]))))));
  }
}
