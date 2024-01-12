import 'dart:io';
import 'package:VocabuLearn/0_language.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import "package:yaml/yaml.dart";

import '0_language_clone.dart';
import '2_account.dart';
import '2_trouver.dart';
import '2_settings.dart';
import '2_4_2_sort_one.dart';
import '2_4_1_sort_multi.dart';

import '_global_functions.dart';
import '_global_variables.dart';
import '_http_data copy.dart' as http;

class Home extends StatefulWidget {
  // const Home({Key? key}) : super(key: key);
  final speak;
  final learn;
  Home(this.speak, this.learn);

  @override
  _HomeState createState() => _HomeState(this.speak, this.learn);
}

class _HomeState extends State<Home> {
  final speak;
  final learn;
  _HomeState(this.speak, this.learn);
  // pour gérer l'affichage
  bool loading = false;
  bool loading2 = false;
  bool choose = false;
  bool end = false;
  bool timeout = false;
  bool display_popup = false;
  int index = 0;
  //ids
  late String file_learning = get_file_learning(speak, learn);
  late String file_notlearn = get_file_notlearn(speak, learn);
  late String file_learned = get_file_learned(speak, learn);
  //mots en
  late String file_learn_learning = get_file_learn_learning(learn);
  late String file_learn_learned = get_file_learn_learned(learn);
  //mots fr
  late String file_speak_learning = get_file_speak_learning(speak);
  late String file_speak_learned = get_file_speak_learned(speak);
  //----fonctions intermédiaires----------------------------------------------
  create_all_files() async {
    print('1_home create_all_files $file_learning');
    print('1_home create_all_files $file_notlearn');
    print('1_home create_all_files $file_learned');
    print('1_home create_all_files $file_learn_learning');
    print('1_home create_all_files $file_speak_learning');
    print('1_home create_all_files $file_learn_learned');
    print('1_home create_all_files $file_speak_learned');

    await create_file(file_learning);
    await create_file(file_notlearn);
    await create_file(file_learned);
    await create_file(file_learn_learning);
    await create_file(file_speak_learning);
    await create_file(file_learn_learned);
    await create_file(file_speak_learned);
    await create_setting();
  }

  create_file(file_name) async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    final file = File('$folderPath/$file_name');
    bool exist = await file.exists();
    if (!exist) {
      await file.writeAsString('');
    }
  }

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
    print('1_home filter_list_of_list $file_learning $list_learning');
    List<String> list_notlearn = await read_list_from_file_name(file_notlearn);
    print('1_home filter_list_of_list $file_notlearn $list_notlearn');
    List<String> list_learned = await read_list_from_file_name(file_learned);
    print('1_home filter_list_of_list $file_learned $list_learned');
    List<String> all_filters =
        await list_learning + await list_notlearn + await list_learned;
    var index_filter = [];
    for (var i = 0; i < list_of_list[0].length; i++) {
      if (all_filters.contains(list_of_list[0][i].toString())) {
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

  create_all_occ(List all) {
    //input:[[a,b,c],[d,e,f],[g,h,i],...,[1,2,6]]
    //-->output:[[[a,b],[c]],[[d,e],[f]],...,[1,2],[6]]
    //input: la liste de liste all,
    //  Pour diffs = 1,2,6, par tranche de 5 de difficulté
    //       [IDs,    EN,   FR,    IMP,  DIFFs]-->[1D1,ID2],[EN1,EN2]...[D]
    //elements non paramétrés : l'index de all est sur 4, il y a 20 tranches de diff
    List new_liste = [...all];
    for (int i = 0; i < all.length; i++) {
      //parcours des n listes de all (n x m)
      List new_sublist = []; //pour chaque liste de all je crée une liste
      for (int m = 0; m < 20; m++) {
        //parcours des 20 tranches de difficultés
        List new_subsublist =
            []; //pour chaque tranche de difficulté, je crée une liste
        for (int j = 0; j < all[i].length; j++) {
          //parcours des m éléments par liste de all (n x m)
          bool check = (all[3][j] >= (m) * 5) & (all[3][j] < (m + 1) * 5);
          if (check) {
            new_subsublist.add(all[i][j]);
          }
        }
        new_sublist.add(new_subsublist);
      }
      new_liste[i] = new_sublist;
    }
    return new_liste;
  }

  import_list_async(file_name) async {
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

  // My words
  go_to_account() async {
    restart_home();
    create_setting();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Account(folderPath)));
  }

  //settings
  go_to_settings() async {
    restart_home();
    await create_all_files();
    List<String> liste_settings = await import_setting_async();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Settings(folderPath)));
  }

  go_to_trouver(all_brut, all_filter) async {
    create_setting();
    List<String> liste_settings = await import_setting_async();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    // print("1_home go_to_trouver all_filter[0]");

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Trouver(folderPath, all_brut, all_filter)));
  }

  // languages ()
  go_to_languages() async {
    restart_home();
    await create_all_files();
    List<String> liste_settings = await import_setting_async();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => LanguageClone(folderPath)));
  }

  restart_home() {
    setState(() {
      loading = false;
    });
  }

  //----fonctions finales-----------------------------------------------------
  pushTrouver() async {
    setState(() {
      loading = true;
      display_popup = false;
    });
    await create_all_files();
    //settings
    List<String> liste_settings = await import_setting_async();
    int nb_words_max = int.parse(liste_settings[15]);
    //current number of words
    List list_learn_learning = await import_list_async(file_learn_learning);
    print('1_home pushTrouver: $file_learn_learning');
    int nb_learning = list_learn_learning.length;
    List list_learn_learned = await import_list_async(file_learn_learned);
    int nb_learned = list_learn_learned.length;
    int current_number = nb_learned + nb_learning;
    if (current_number >= nb_words_max) {
      setState(() {
        loading = false;
      });
      go_to_pay(context);
      return;
    } else {
      List all_brut = await http.API_import_list_of_list(speak, learn);
      //print(all_brut[3]);
      all_brut = await filter_list_of_list(
          all_brut, file_learning, file_notlearn, file_learned);
      List all_filter = await create_all_occ(all_brut);
      print("1_home pushTrouver $all_filter[0].length");
      print("1_home pushTrouver $all_filter[0][4].length");
      setState(() {
        loading = false;
      });
      go_to_trouver(all_brut, all_filter);
      return;
    }
  }

  pushApprendre() async {
    await create_all_files();
    List list_learn_learning = await import_list_async(file_learn_learning);
    print("1_home pushApprendre $list_learn_learning");
    print("1_home pushApprendre $list_learn_learning.length");
    if (list_learn_learning.length < 6) {
      setState(() {
        display_popup = true;
      });
    } else {
      restart_home();
      go_to_paire(context);
    }
    return;
  }

  pushAccount() async {
    await create_all_files();
    go_to_account();
    return;
  }

  Map loadYamlFileSync(String path) {
    File file = new File(path);
    return loadYaml(file.readAsStringSync());
  }

  pushSettings() async {
    go_to_settings();
  }

  pushLanguages() async {
    go_to_languages();
  }
  //----fonctions de debug-----------------------------------------------------

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
    reinitializeFiles(file_learn_learning);
    reinitializeFiles(file_speak_learning);
    reinitializeFiles(file_learn_learned);
    reinitializeFiles(file_speak_learned);
    reinitializeFiles('settings.txt');
    restart_home();
  }

  @override
  Widget build(BuildContext context) {
    Image appLogo = new Image(
        image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
        height: 28.0,
        width: 28.0,
        alignment: FractionalOffset.center);

    double height = 50;
    double width = 265;
    List functions = [
      pushTrouver,
      pushApprendre,
      pushAccount,
      pushSettings,
      pushLanguages
    ];
    List icons = [
      Icons.swap_horiz_outlined,
      Icons.videogame_asset_outlined,
      Icons.home,
      Icons.settings,
      Icons.flag
    ];
    List<String> texts = [
      'Find new words',
      'Learn my words',
      'My words',
      'My settings',
      'Languages ($speak/$learn)'
    ];
    List<SizedBox> sized_box = [];
    List<bool> conditions = [
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup))
    ];
    for (var i = 0; i < 5; i++) {
      if (conditions[i]) {
        sized_box.add(SizedBox(
            height: height,
            width: width,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(10)),
                icon: Icon(
                  icons[i],
                  color: Colors.white,
                  size: 30.0,
                ),
                label: Text(
                  texts[i],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: functions[i])));
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(children: [
          Text('VocabuLearn'),
          Expanded(child: Container()),
          appLogo
        ]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...sized_box,
            if (loading)
              Column(children: [
                SizedBox(
                    height: 150,
                    width: 300,
                    child: Card(
                        child: Center(
                            child: (timeout)
                                ? Text(
                                    'Echec de connection à la base de donnée en ligne... Veuillez relancer l\'application avec Internet.')
                                : Text(
                                    'Connection à la database \nde + de 30 000 mots...')))),
                CircularProgressIndicator(),
              ]),
            if (display_popup)
              AlertDialog(
                title: Text("Pas assez de mots à apprendre"),
                content: Text(
                    "Sélectionnez au moins 6 mots à apprendre avant de lancer les modules d'apprentissage ou de consulter vos mots."),
                actions: [
                  TextButton(
                    child: Text("Sélectionner des mots"),
                    onPressed: pushTrouver,
                  ),
                ],
              ),
            //ElevatedButton(onPressed: restart, child: Text('Restart')),
            ElevatedButton(
                onPressed: reintializeAllFiles, child: Text('Reinitialize')),
          ],
        ),
      ),
    );
  }
}
