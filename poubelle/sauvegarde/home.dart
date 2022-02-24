import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'paire.dart';
import 'account.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // pour gérer l'affichage
  bool loading = false;
  bool loading2 = false;
  bool choose = false;
  bool end = false;
  bool display_popup = false;
  int index = 0;
  int nb_learn = 0;
  int nb_notlearn = 0;
  int min_nb_word = 12;
  List all = [
    [],
    ['AAA']
  ];
  //ids
  String values_learning = '';
  String values_notlearn = '';
  String values_learned = '';
  String file_learning = 'list_learning.txt';
  String file_notlearn = 'list_notlearning.txt';
  String file_learned = 'list_learned.txt';
  //mots fr & en
  String values_en_learning = '';
  String values_fr_learning = '';
  String values_en_learned = '';
  String values_fr_learned = '';
  String file_en_learning = 'list_en_learning.txt';
  String file_fr_learning = 'list_fr_learning.txt';
  // a utiliser plus tard:
  // String file_en_learned = 'list_en_learned.txt';
  // String file_fr_learned = 'list_fr_learned.txt';
  // cette variable sert à gérer le cas où l'user parcourt la totalité des mots
  int max_length = 1;
  //----fonctions intermédiaires----------------------------------------------
  read_list_from_file_name(file_name) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    bool exist = await file.exists();
    if (!exist) {
      return [''];
    } else {
      List lines = file.readAsLinesSync();
      if (lines.length == 0) {
        return [''];
      } else {
        String content = lines[0];
        return content.split(',');
      }
    }
  }

  filter_list_of_list(list_of_list, String file_learning, String file_notlearn,
      String file_learned) async {
    List<String> list_learning = await read_list_from_file_name(file_learning);
    List<String> list_notlearn = await read_list_from_file_name(file_notlearn);
    List<String> list_learned = await read_list_from_file_name(file_learned);
    List<String> all_filters =
        await list_learning + await list_notlearn + await list_learned;
    var index_filter = [];
    for (var i = 0; i < list_of_list[0].length; i++) {
      if (all_filters.contains(list_of_list[0][i])) {
        index_filter.add(i);
      }
    }
    for (var i = 0; i < list_of_list.length; i++) {
      for (var j = 0; j < index_filter.length; j++) {
        list_of_list[i].removeAt(index_filter[j] - j);
      }
    }
    return list_of_list;
  }

  save_data_one(file_name, new_ids) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    if (new_ids.length != 0) {
      new_ids = new_ids.substring(0, new_ids.length - 1);
    }
    bool exist = await file.exists();
    if (!exist) {
      await file.writeAsString(new_ids);
    } else {
      List lines = file.readAsLinesSync();
      if (lines.length == 0) {
        await file.writeAsString(new_ids);
      } else {
        String content = lines[0];
        await file.writeAsString(content + ',' + new_ids);
      }
    }
  }

  import_list(file_name) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    bool exist = await file.exists();
    if (!exist) {
      await file.writeAsString('');
      return [];
    }
    List<String> lines = file.readAsLinesSync();
    if (lines.length == 0) {
      return [];
    } else {
      String content = lines[0];
      return content.split(',');
    }
  }

  go_to_paire() async {
    restart();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Paire(folderPath)));
  }

  go_to_account() async {
    restart();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Account(folderPath)));
  }

  //----fonctions finales-----------------------------------------------------
  chooseMyWords() async {
    List list_en_learning = await import_list('list_en_learning.txt');
    setState(() {
      loading = true;
      choose = true;
      display_popup = false;
      nb_learn = nb_learn + list_en_learning.length;
    });
    List all2 = await http.API_import_list_of_list();
    all2 = await filter_list_of_list(
        all2, file_learning, file_notlearn, file_learned);
    int max_length2 = all2[0].length;
    setState(() {
      all = all2;
      max_length = max_length2;
      loading = false;
      choose = true; // A SUPPRIMER ?
    });
  }

  rightPush() {
    setState(() {
      values_learning = values_learning + all[0][index] + ',';
      values_en_learning = values_en_learning + all[1][index] + ',';
      values_fr_learning = values_fr_learning + all[2][index] + ',';
      index = index + 1;
      nb_learn = nb_learn + 1;
    });
  }

  leftPush() {
    setState(() {
      values_notlearn = values_notlearn + all[0][index] + ',';
      index = index + 1;
      nb_notlearn = nb_notlearn + 1;
    });
  }

  saveData() async {
    setState(() {
      loading2 = true;
      choose = true; // A SUPPRIMER ?
    });
    await save_data_one(file_learning, values_learning);
    await save_data_one(file_notlearn, values_notlearn);
    await save_data_one(file_learned, values_learned);
    await save_data_one(file_en_learning, values_en_learning);
    await save_data_one(file_fr_learning, values_fr_learning);
    setState(() {
      loading2 = false;
      choose = false;
      end = true;
    });
    go_to_paire();
  }

  pushApprendre1() async {
    List list_en_learning = await import_list('list_en_learning.txt');
    if (list_en_learning.length < 6) {
      setState(() {
        display_popup = true;
      });
    } else {
      go_to_paire();
    }
    return;
  }

  pushAccount() async {
    List list_en_learning = await import_list('list_en_learning.txt');
    if (list_en_learning.length < 1) {
      setState(() {
        display_popup = true;
      });
    } else {
      go_to_account();
    }
    return;
  }

  //----fonctions de debug-----------------------------------------------------
  restart() {
    setState(() {
      loading = false;
      loading2 = false;
      choose = false;
      end = false;
      index = 0;
      nb_learn = 0;
      nb_notlearn = 0;
      all = [
        ['ddd', 'ccc'],
        ['AAA']
      ];
      max_length = 1;
      values_learning = '';
      values_notlearn = '';
      values_learned = '';
      values_en_learning = '';
      values_fr_learning = '';
    });
  }

  reinitializeFiles(file_name) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    await file.writeAsString('');
  }

  reintializeAllFiles() async {
    reinitializeFiles(file_learning);
    reinitializeFiles(file_notlearn);
    reinitializeFiles(file_learned);
    reinitializeFiles(file_en_learning);
    reinitializeFiles(file_fr_learning);
    restart();
  }

  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("My title"),
    content: Text("This is my message."),
    actions: [
      TextButton(
        child: Text("OK"),
        onPressed: () {},
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Acceuil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!display_popup & !choose & !end)
              ElevatedButton(
                  onPressed: chooseMyWords,
                  child: Text('Trouver de nouveaux mots')),
            if (choose & !loading & !loading2)
              ElevatedButton(
                  onPressed: (nb_learn >= min_nb_word) ? saveData : null,
                  child: Text('Apprendre les $nb_learn mots')),
            if (choose & !loading & (index < max_length)) Text(all[1][index]),
            if (loading) CircularProgressIndicator(),
            if (loading2) CircularProgressIndicator(),
            if (choose & !loading & (index < max_length))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: leftPush,
                      child: const Text('Je le connais déjà')),
                  ElevatedButton(
                      onPressed: rightPush,
                      child: const Text('Je veux l\'apprendre')),
                ],
              ),
            // ElevatedButton(onPressed: restart, child: Text('Restart')),
            // ElevatedButton(
            //     onPressed: reintializeAllFiles, child: Text('Reinitialize')),
            if (!display_popup & !choose)
              ElevatedButton(
                  onPressed: pushApprendre1, child: Text('Apprendre mes mots')),
            if (display_popup)
              AlertDialog(
                title: Text("Pas assez de mots à apprendre"),
                content: Text(
                    "Sélectionnez au moins 12 mots à apprendre avant de lancer les modules d'apprentissage."),
                actions: [
                  TextButton(
                    child: Text("Sélectionner des mots"),
                    onPressed: chooseMyWords,
                  ),
                ],
              ),
            if (!display_popup & !choose)
              ElevatedButton(onPressed: pushAccount, child: Text('Mon compte')),
            //ElevatedButton(onPressed: restart, child: Text('Restart')),
            ElevatedButton(
                onPressed: reintializeAllFiles, child: Text('Reinitialize')),
          ],
        ),
      ),
    );
  }
}
