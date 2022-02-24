import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:Vocabulearn/2_2_quizz.dart';
import 'package:Vocabulearn/2_3_fuzzy.dart';
import 'package:Vocabulearn/2_4_sort.dart';
import 'package:Vocabulearn/2_settings.dart';
import '2_1_paire.dart';

create_setting() async {
  final folder = await getApplicationDocumentsDirectory();
  final folderPath = folder.path;
  final file = File('$folderPath/settings.txt');
  bool exist = await file.exists();
  if (!exist) {
    await file.writeAsString(
        'nb_batch,6,nb_questions,5,similarity_threshold,80,step_1,true,step_2,true,step_3,true,difficulty,2');
  }
  List<String> lines = file.readAsLinesSync();
  List<String> content_list = lines[0].split(',');
  if (content_list.length < 14) {
    await file.writeAsString(
        'nb_batch,6,nb_questions,5,similarity_threshold,80,step_1,true,step_2,true,step_3,true,difficulty,2');
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

go_to_paire(context) async {
  create_setting();
  List<String> liste_settings = await import_setting_async();

  final folder = await getApplicationDocumentsDirectory();
  final folderPath = folder.path;
  bool step_1 = (liste_settings[7] == 'true');
  bool step_2 = (liste_settings[9] == 'true');
  bool step_3 = (liste_settings[11] == 'true');
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
  } else {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Sort(folderPath)));
  }
}
