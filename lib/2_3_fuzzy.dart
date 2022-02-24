import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import '2_4_sort.dart';
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
  _FuzzyState(this.folderPath);

  //settings
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = int.parse(liste_settings[1]);
  late int similarity_threshold = int.parse(liste_settings[5]);
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
  String file_en_learning = get_file_en_learning();
  //mots fr
  String file_fr_learning = get_file_fr_learning();
  // words
  late List<String> en_learning =
      import_list_sync(file_en_learning, folderPath);
  late List<String> fr_learning =
      import_list_sync(file_fr_learning, folderPath);
  late List<String> sub_fr_learning =
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
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Sort(folderPath)));
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
    });
    if (index == sub_fr_learning.length - 1) {
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
                title: Row(children: [
              Text('Etape 3/4: Traduction'),
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
                                  sub_fr_learning[index],
                                  style: TextStyle(fontSize: 20),
                                )),
                              )),
                          TextFormField(
                            onEditingComplete: () {},
                            controller: _controller,
                            textAlign: TextAlign.center,
                            decoration:
                                InputDecoration(hintText: 'Traduire le mot'),
                            onFieldSubmitted: _submitPush,
                            onChanged: _fuzzyMatch,
                            //validator: (value) => value.length>20 ? null:"Input too long",
                          ),
                          if (text) Text(text_fail),
                          if (spoil)
                            ElevatedButton(
                                onPressed: _spoilPush,
                                child: Text('Voir la solution')),
                          if (sucess) Text(text_sucess),
                          if (solution)
                            Column(children: [
                              Text('La bonne réponse était:'),
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
                              ),
                              onPressed: go_to_sort,
                              child: Text('Skip'))
                        ]))))));
  }
}
  // bool next = false;
  // bool text = false;
  // bool spoil = false;
  // bool solution = false;