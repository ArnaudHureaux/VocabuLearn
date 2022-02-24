import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import "package:yaml/yaml.dart";

import '2_account.dart';
import '2_trouver.dart';
import '2_settings.dart';

import '_global_functions.dart';
import '_global_variables.dart';
import '_http_data.dart' as http;

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
  bool timeout = false;
  bool display_popup = false;
  int index = 0;
  //ids
  String file_learning = get_file_learning();
  String file_notlearn = get_file_notlearn();
  String file_learned = get_file_learned();
  //mots en
  String file_en_learning = get_file_en_learning();
  String file_en_learned = get_file_en_learned();
  //mots fr
  String file_fr_learning = get_file_fr_learning();
  String file_fr_learned = get_file_fr_learned();
  //----fonctions intermédiaires----------------------------------------------
  create_all_files() async {
    await create_file(file_learning);
    await create_file(file_notlearn);
    await create_file(file_learned);
    await create_file(file_en_learning);
    await create_file(file_fr_learning);
    await create_file(file_en_learned);
    await create_file(file_fr_learned);
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

  create_all_occ(List all) {
    //input: la liste de liste all,
    //  Pour diffs = 1,2,6, par tranche de 5 de difficulté
    //       [IDs,    EN,   FR,    IMP,  DIFFs]-->[1D1,ID2],[EN1,EN2]...[D]
    //output:[[a,b,c],[d,e,f],[g,h,i],...,[1,2,6]]-->[[[a,b],[c]],[[d,e],[f]],...,[1,2],[6]]
    List new_liste = [...all];
    for (int i = 0; i < all.length; i++) {
      List new_sublist = [];
      for (int m = 0; m < 20; m++) {
        List new_subsublist = [];
        for (int j = 0; j < all[i].length; j++) {
          bool check = (all[4][j] >= (m) * 5) & (all[4][j] < (m + 1) * 5);
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

  import_setting_async() async {
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
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

  go_to_account() async {
    restart_home();
    create_setting();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Account(folderPath)));
  }

  go_to_settings() async {
    restart_home();
    create_all_files();
    List<String> liste_settings = await import_setting_async();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Settings(folderPath)));
  }

  got_to_trouver(all_brut, all_filter) async {
    create_setting();
    List<String> liste_settings = await import_setting_async();
    final folder = await getApplicationDocumentsDirectory();
    final folderPath = folder.path;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Trouver(folderPath, all_brut, all_filter)));
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
    create_all_files();
    List all_brut = await http.API_import_list_of_list();
    all_brut = await filter_list_of_list(
        all_brut, file_learning, file_notlearn, file_learned);
    List all_filter = await create_all_occ(all_brut);
    setState(() {
      loading = false;
    });
    got_to_trouver(all_brut, all_filter);
    return;
  }

  pushApprendre() async {
    create_all_files();
    List list_en_learning = await import_list_async('list_en_learning.txt');
    if (list_en_learning.length < 6) {
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
    create_all_files();
    List list_en_learning = await import_list_async('list_en_learning.txt');
    if (list_en_learning.length < 1) {
      setState(() {
        display_popup = true;
      });
    } else {
      go_to_account();
    }
    return;
  }

  Map loadYamlFileSync(String path) {
    File file = new File(path);
    return loadYaml(file.readAsStringSync());
  }

  pushSettings() async {
    go_to_settings();
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
    reinitializeFiles(file_en_learning);
    reinitializeFiles(file_fr_learning);
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
    ];
    List icons = [
      Icons.swap_horiz_outlined,
      Icons.videogame_asset_outlined,
      Icons.home,
      Icons.settings,
    ];
    List<String> texts = [
      'Trouver de nouveaux mots',
      'Apprendre mes mots',
      'Mes mots',
      'Mes paramètres'
    ];
    List<SizedBox> sized_box = [];
    List<bool> conditions = [
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup)),
      ((!loading) & (!display_popup))
    ];
    for (var i = 0; i < 4; i++) {
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
                    "Sélectionnez au moins 12 mots à apprendre avant de lancer les modules d'apprentissage."),
                actions: [
                  TextButton(
                    child: Text("Sélectionner des mots"),
                    onPressed: pushTrouver,
                  ),
                ],
              ),
            //ElevatedButton(onPressed: restart, child: Text('Restart')),
            // ElevatedButton(
            //     onPressed: reintializeAllFiles, child: Text('Reinitialize')),
          ],
        ),
      ),
    );
  }
}
