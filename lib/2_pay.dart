import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import '1_home.dart';
import '2_2_quizz.dart';
import '2_3_fuzzy.dart';
import '2_4_2_sort_one.dart';

import '_global_functions.dart';
import '_global_variables.dart';

class Pay extends StatefulWidget {
  final folderPath;
  Pay(this.folderPath);
  @override
  _PayState createState() => _PayState(this.folderPath);
}

class _PayState extends State<Pay> {
  final folderPath;
  _PayState(this.folderPath);
  //settings
//settings
  late List<String> liste_settings = import_setting_sync(folderPath);
  late int nb_words_max = int.parse(liste_settings[15]);
//prix et nb de mots
  List<String> prices = ['\$2', '\$3,50', '\$5', '\$7', '\$10'];
  List<String> nb_bought = ['100', '200', '300', '500', '1000'];
  late String default_nb_bought = nb_bought[0];

//fonctions finales
  liste_deroulantes_batch(newValue) {
    setState(() {
      default_nb_bought = newValue ?? 'strange';
    });
    print(default_nb_bought);
  }

  pay_words(nb_buy, price) {
    print(price);
    print(nb_buy);
  }

  Future<bool> _willPopCallback() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home()));
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    Image appLogo = new Image(
        image: new ExactAssetImage("assets/VOCABULEARN_ICON.png"),
        height: 28.0,
        width: 28.0,
        alignment: FractionalOffset.center);
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              //automaticallyImplyLeading: false,
              title: Row(children: [
                Text('Get more words !'),
                Expanded(child: Container()),
                appLogo
              ]),
              centerTitle: false,
            ),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 120,
                  child: Card(
                      child: Row(
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info,
                              size: 20.0,
                            ),
                          ]),
                      Flexible(
                        child: Text(
                            'You have selected the maximum number of words possible ($nb_words_max), if you want to select more words please buy an additional pack:',
                            style: TextStyle(fontSize: 16)),
                      )
                    ],
                  )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 90,
                        width: 220,
                        child: Card(
                            child: Center(
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                        elevation: 44,
                                        hint: Text(
                                          "+" + default_nb_bought + " words",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22),
                                        ),
                                        items: nb_bought.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: liste_deroulantes_batch))))),
                    SizedBox(
                        height: 90,
                        width: 100,
                        child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            child: Center(
                                child: Text(
                                    prices[
                                        nb_bought.indexOf(default_nb_bought)],
                                    style: TextStyle(fontSize: 25))))),
                  ],
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(10)),
                    icon: Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    label: Text(
                      "Buy $default_nb_bought more words for ${prices[nb_bought.indexOf(default_nb_bought)]}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => pay_words(default_nb_bought,
                        prices[nb_bought.indexOf(default_nb_bought)])),
              ],
            ))));
  }
}
