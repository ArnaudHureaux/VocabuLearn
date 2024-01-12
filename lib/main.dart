import 'package:VocabuLearn/0_language.dart';
import "package:flutter/material.dart";
import '0_language.dart';
import '1_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocabuLearn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Language(),
    );
  }
}
