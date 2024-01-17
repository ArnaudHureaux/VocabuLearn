import 'package:flutter/material.dart';
import '_http_data.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'sort.dart';

class Fuzzy extends StatefulWidget {
  final folderPath;
  Fuzzy(this.folderPath);
  @override
  _FuzzyState createState() => _FuzzyState(this.folderPath);
}

class _FuzzyState extends State<Fuzzy> {
  final folderPath;
  _FuzzyState(this.folderPath);
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
  String file_en_learning = 'list_en_learning.txt';
  //mots fr
  String file_fr_learning = 'list_fr_learning.txt';
  // words
  late List<String> en_learning = import_list(file_en_learning);
  late List<String> fr_learning = import_list(file_fr_learning);
  late List<String> sub_fr_learning =
      process(fr_learning.getRange(0, 6).toList());
  late List<String> sub_en_learning =
      process(en_learning.getRange(0, 6).toList());
//----fonctions intermédiaires intro ---------------------------------------

  process(list) {
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i]
          .replaceAll('/ ', '/')
          .replaceAll('   ', ' ')
          .replaceAll('  ', ' ')
          .replaceAll(' /', '/');
    }
    return list;
  }

  shuffle(list) {
    list.shuffle();
    return list;
  }

  import_list(file_name) {
    final file = File('$folderPath/$file_name');
    List<String> lines = file.readAsLinesSync();
    String content = lines[0];
    return content.split(',');
  }

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
    if (ratio_rate > 80) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('Etape 3/4 : écriture des mots')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(sub_fr_learning[index]),
              TextFormField(
                onEditingComplete: () {},
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: 'Translate the word'),
                onFieldSubmitted: _submitPush,
                onChanged: _fuzzyMatch,
                //validator: (value) => value.length>20 ? null:"Input too long",
              ),
              if (text) Text(text_fail),
              if (spoil)
                ElevatedButton(
                    onPressed: _spoilPush, child: Text('Voir la solution')),
              if (sucess) Text(text_sucess),
              if (solution)
                Column(children: [
                  Text('La bonne réponse était:'),
                  SizedBox(height: 10),
                  Text(
                    sub_en_learning[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
            ])));
  }
}
  // bool next = false;
  // bool text = false;
  // bool spoil = false;
  // bool solution = false;