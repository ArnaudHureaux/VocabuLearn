import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '_global_functions.dart';
import '_global_variables.dart';

class Settings extends StatefulWidget {
  final folderPath;
  Settings(this.folderPath);
  @override
  _SettingsState createState() => _SettingsState(this.folderPath);
}

class _SettingsState extends State<Settings> {
  final folderPath;
  _SettingsState(this.folderPath);
  //settings
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_batch = int.parse(liste_settings[1]);
  late int nb_questions = int.parse(liste_settings[3]);
  late int similarity_threshold = int.parse(liste_settings[5]);
  late bool step_1 = (liste_settings[7] == 'true');
  late bool step_2 = (liste_settings[9] == 'true');
  late bool step_3 = (liste_settings[11] == 'true');
  //others
  int nb_actions = 0;

  //fonctions finales
  liste_deroulantes_batch(newValue) {
    var value_notnull = newValue ?? '10';
    setState(() {
      nb_batch = int.parse(value_notnull);
      nb_actions++;
    });
  }

  liste_deroulantes_quizz(newValue) {
    var value_notnull = newValue ?? '10';
    setState(() {
      nb_questions = int.parse(value_notnull);
      nb_actions++;
    });
  }

  liste_deroulantes_fuzzy(newValue) {
    var value_notnull = newValue ?? '10';
    setState(() {
      similarity_threshold = int.parse(value_notnull);
      nb_actions++;
    });
  }

  check_box_paire(newValue) {
    setState(() {
      step_1 = newValue;
      nb_actions++;
    });
  }

  check_box_quizz(newValue) {
    setState(() {
      step_2 = newValue;
      nb_actions++;
    });
  }

  check_box_translation(newValue) {
    setState(() {
      step_3 = newValue;
      nb_actions++;
    });
  }

  push_save_settings() {
    setState(() {
      liste_settings[1] = (nb_batch).toString();
      liste_settings[3] = (nb_questions).toString();
      liste_settings[5] = (similarity_threshold).toString();
      liste_settings[7] = (step_1).toString();
      liste_settings[9] = (step_2).toString();
      liste_settings[11] = (step_3).toString();
      nb_actions = 0;
    });
    save_settings(liste_settings, folderPath);
  }

  push_set_default_values() {
    String content_str = get_default_settings();
    List<String> liste_settings_new = content_str.split(',');
    setState(() {
      liste_settings = liste_settings_new;
      nb_batch = int.parse(liste_settings[1]);
      nb_questions = int.parse(liste_settings[3]);
      similarity_threshold = int.parse(liste_settings[5]);
      step_1 = (liste_settings[7] == 'true');
      step_2 = (liste_settings[9] == 'true');
      step_3 = (liste_settings[11] == 'true');
      nb_actions++;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Row> children_column = [];
    List<String> textes = [
      'Nombre de mots par apprentissage',
      'Nombre de questions par quizz',
      '% de similarité nécessaire',
      '1/3: Jeu des Paires',
      '2/3: Jeu des Quizz',
      '3/3: Traduction directes',
    ];
    List<List<String>> values = [
      ['6', '9', '12', '15', '18', '21']
    ];
    values.add(List.generate(nb_batch - 3, (i) => (i + 3).toString()));
    values.add(['60', '70', '75', '80', '82', '85', '87', '90', '95', '100']);
    List<String> current_values = [
      nb_batch.toString(),
      nb_questions.toString(),
      similarity_threshold.toString()
    ];

    for (var i = 0; i < 3; i++) {
      children_column.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              width: 20,
            ),
            SizedBox(
                height: 40,
                width: 260,
                child: Card(
                    color: Colors.blue.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Center(
                        child: Text(textes[i],
                            style: TextStyle(color: Colors.white))))),
            DropdownButton<String>(
                hint: Text(current_values[i]),
                items: values[i].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (i == 0)
                    ? liste_deroulantes_batch
                    : (i == 1)
                        ? liste_deroulantes_quizz
                        : (i == 2)
                            ? liste_deroulantes_fuzzy
                            : null)
          ],
        ),
      );
    }
    List<SizedBox> children_column_check = [];
    for (var i = 0; i < 3; i++) {
      children_column_check.add(SizedBox(
          height: 50,
          width: 300,
          child: CheckboxListTile(
              title: Text(textes[3 + i]),
              value: (i == 0)
                  ? step_1
                  : (i == 1)
                      ? step_2
                      : (i == 2)
                          ? step_3
                          : step_1,
              onChanged: (i == 0)
                  ? check_box_paire
                  : (i == 1)
                      ? check_box_quizz
                      : (i == 2)
                          ? check_box_translation
                          : check_box_translation)));
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
          Text('Mes paramètres'),
          Expanded(child: Container()),
          appLogo
        ])),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...children_column,
            ...children_column_check,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: push_set_default_values,
                    child: Text('Paramètres par défaut')),
                ElevatedButton(
                    onPressed: (nb_actions > 0) ? push_save_settings : null,
                    child: Text('Sauvegarder'))
              ],
            )
          ],
        ));
  }
}
