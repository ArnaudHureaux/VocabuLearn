import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '2_1_paire.dart';
import '2_2_quizz.dart';
import '2_3_fuzzy.dart';
import '2_4_2_sort_one.dart';
import '2_4_1_sort_multi.dart';
import '2_pay.dart';

import '_global_variables.dart';

create_setting() async {
  String default_values = get_default_settings();
  final folder = await getApplicationDocumentsDirectory();
  final folderPath = folder.path;
  final file = File('$folderPath/settings.txt');
  bool exist = await file.exists();
  if (!exist) {
    await file.writeAsString(default_values);
  }
  List<String> lines = file.readAsLinesSync();
  if (lines.length == 0) {
    await file.writeAsString(default_values);
  } else {
    List<String> content_list = lines[0].split(',');
    if (content_list.length < 16) {
      await file.writeAsString(default_values);
    }
  }
}

import_setting_async() async {
  final folder = await getApplicationDocumentsDirectory();
  final folderPath = folder.path;
  final file = File('$folderPath/settings.txt');
  List<String> lines = file.readAsLinesSync();
  if (lines.length == 0) {
    String content_str = get_default_settings();
    file.writeAsString(content_str);
    return content_str.split(',');
  }
  if ((lines.length > 0) & (lines[0].split(',').length < 17)) {
    String content_str = get_default_settings();
    file.writeAsString(content_str);
    return content_str.split(',');
  } else {
    List<String> content_list = lines[0].split(',');
    return content_list;
  }
}

go_to_paire(context) async {
  create_setting();
  List<String> liste_settings = await import_setting_async();

  final folder = await getApplicationDocumentsDirectory();
  final folderPath = folder.path;
  bool step_1 = (liste_settings[7] == 'true');
  bool step_2 = (liste_settings[9] == 'true');
  bool step_3 = (liste_settings[11] == 'true');
  bool prefer_multi = (liste_settings[17] == 'true');
  if (step_1) {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Paire(folderPath)));
  }
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
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SortOne(folderPath)));
  }
}

import_list_sync(file_name, folderPath) {
  final file = File('$folderPath/$file_name');
  List<String> lines = file.readAsLinesSync();
  if (lines.length == 0) {
    return [''];
  }
  String content = lines[0];
  List<String> retour = content.split(',');
  return retour;
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

import_setting_sync(folderPath) {
  final file = File('$folderPath/settings.txt');
  List<String> lines = file.readAsLinesSync();
  if (lines.length == 0) {
    String content_str = get_default_settings();
    file.writeAsString(content_str);
    return content_str.split(',');
  } else {
    List<String> content_list = lines[0].split(',');
    return content_list;
  }
}

save_settings(liste_settings, folderPath) {
  String content_str = '';
  for (var val in liste_settings) {
    content_str = content_str + val + ',';
  }
  content_str = content_str.substring(0, content_str.length - 1);
  final file = File('$folderPath/settings.txt');
  List<String> lines = file.readAsLinesSync();
  file.writeAsString(content_str);
}

go_to_pay(context) async {
  final folder = await getApplicationDocumentsDirectory();
  final folderPath = folder.path;
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => Pay(folderPath)));
}

remove_empty(List<String> en_learning, List<String> fr_learning) {
  List<int> index_list = [];
  print(en_learning);
  print(fr_learning);
  for (var i = 0; i < en_learning.length; i++) {
    if ((en_learning[i] == '') | (fr_learning[i] == '')) {
      index_list.add(i);
    }
  }
  List<String> new_en_learning = [];
  List<String> new_fr_learning = [];
  for (var i = 0; i < en_learning.length; i++) {
    if (!index_list.contains(i)) {
      new_en_learning.add(en_learning[i]);
      new_fr_learning.add(fr_learning[i]);
    }
  }
  List<List<String>> new_lists = [new_en_learning, new_fr_learning];
  return new_lists;
}
