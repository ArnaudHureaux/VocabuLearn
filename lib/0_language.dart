import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import '1_home.dart';
import '2_2_quizz.dart';
import '2_3_fuzzy.dart';
import '2_4_2_sort_one.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
//settings
//late List<String> liste_settings = import_setting_async();

//prix et nb de mots
  List<String> speaks = [
    'PORTUGAIS',
    'ENGLISH',
    'CHINESE',
    'KOREAN',
    'JAPAN',
    'FRENCH',
    'HINDI',
    'DEUTSCH',
    'SPAIN',
    'POLONAIS',
    'TURC',
    'RUSSIAN',
    'ARABE',
    'DANOIS'
  ];
  List<String> learns = [
    'PORTUGAIS',
    'ENGLISH',
    'CHINESE',
    'KOREAN',
    'JAPAN',
    'FRENCH',
    'HINDI',
    'DEUTSCH',
    'SPAIN',
    'POLONAIS',
    'TURC',
    'RUSSIAN',
    'ARABE',
    'DANOIS'
  ];
  List<String> texts = ['I speak', 'I want to learn'];
  late List<List<String>> speaks_learns = [speaks, learns];
  late List current_values = ['FRENCH', 'ENGLISH'];
//fonctions finales
  liste_deroulantes_speak(newValue) {
    var value_notnull = newValue ?? 'FRENCH';
    setState(() {
      current_values[0] = value_notnull;
    });
  }

  liste_deroulantes_learn(newValue) {
    var value_notnull = newValue ?? 'ENGLISH';
    setState(() {
      current_values[1] = value_notnull;
    });
  }

  _pushContinue() async {
    await create_setting();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    late List<String> liste_settings = import_setting_sync(folderPath);
    liste_settings[19] = current_values[0];
    liste_settings[21] = current_values[1];
    save_settings(liste_settings, folderPath);

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Home(current_values[0], current_values[1])));
  }

  @override
  Widget build(BuildContext context) {
    Image appLogo2 = new Image(
        image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
        height: 28.0,
        width: 28.0,
        alignment: FractionalOffset.center);
    List<Widget> rows = [];
    for (var i = 0; i < 2; i++) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
          ),
          SizedBox(
              height: 40,
              width: 220,
              child: Card(
                  color: Colors.blue.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Center(
                      child: Text(texts[i],
                          style:
                              TextStyle(color: Colors.white, fontSize: 20))))),
          DropdownButton<String>(
              hint: Text(current_values[i]),
              items: speaks_learns[i].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(children: [appLogo2, Text(value)]),
                );
              }).toList(),
              onChanged:
                  (i == 0) ? liste_deroulantes_speak : liste_deroulantes_learn)
        ],
      ));
    }

    Image appLogo = new Image(
        image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
        height: 28.0,
        width: 28.0,
        alignment: FractionalOffset.center);
    // List<Image> speaks2 = [appLogo,appLogo,appLogo,appLogo,appLogo];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: Row(children: [
          Text('Select your language !'),
          Expanded(child: Container()),
          appLogo
        ]),
        centerTitle: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...rows,
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10)),
              icon: Icon(
                Icons.arrow_forward_outlined,
                color: Colors.white,
                size: 30.0,
              ),
              label: Text(
                'Continue !',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              onPressed: _pushContinue)
        ],
      ),
    );
  }
}
