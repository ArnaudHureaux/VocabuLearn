import "package:flutter/material.dart";
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

// class Accueil extends StatelessWidget {
//   final String _title;
//   Accueil(this._title);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: Column(
//           children: [
//             Text('edddd $_title'),
//             Text('edddsd $_title'),
//             Icon(Icons.backup, size: 50.0, color: Colors.blue),
//             Text('eddddd $_title'),
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Icon(Icons.favorite),
//                   Text("dddddd $_title"),
//                   Icon(Icons.favorite)
//                 ]),
//             Text("ededdd $_title")
//           ],
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.center,
//         ));
//   }
// }
