// import 'dart:io';
// import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

void main() async {
  var a = await API_import_list_of_list();
}

Future<String> makePostRequest(body) async {
  final url = Uri.parse('http://flaskapicsv.ew.r.appspot.com/');
  final encoding = Encoding.getByName('utf-8');
  var response = await http.post(
    url,
    body: body,
    encoding: encoding,
  );
  return response.body;
}

from_string_to_dict(String responseBody) {
  var responseBody_process = responseBody.replaceAll('\'', '\"');
  responseBody_process = responseBody_process.replaceAll('{', '{ ');
  final test = RegExp(r'\s\d+:');
  responseBody_process = responseBody_process.replaceAllMapped(test, (match) {
    return '"' +
        '${match.group(0)}'.replaceAll(':', '').replaceAll(' ', '') +
        '":';
  });
  var dict = jsonDecode(responseBody_process);
  return dict;
}
//------------------------------------------------------------------------

Future<Map> API_import() async {
  Map body = {'status': 'import'};
  var response = await makePostRequest(body);
  var dict_response = from_string_to_dict(response);
  return dict_response;
}

Future<List> API_import_list_of_list() async {
  var data = await API_import();

  List list_keys = [];
  for (var val in data.keys) {
    list_keys.add(val);
  }
  var list_of_list = [];
  var iter_ids = data[list_keys[0]].keys;
  List ids_list = [];
  for (var val in iter_ids) {
    ids_list.add(val);
  }
  list_of_list.add(ids_list);
  for (var key in data.keys) {
    var iter_eng = data[key].values;
    List del_list = [];
    for (var val in iter_eng) {
      del_list.add(val);
    }
    list_of_list.add(del_list);
  }
  //list_of_list[0] -> IDs
  //list_of_list[1] -> ENG
  //list_of_list[2] -> FR
  //list_of_list[3] -> THEME
  //list_of_list[4] -> OCCURENCE

  return list_of_list;
}

// Future<String> API_export(importance, id) async {
//   Map<String, dynamic> body = {
//     'status': 'export',
//     'importance': importance.toString(),
//     'id': id.toString()
//   };
//   String response = await makePostRequest(body);
//   return response;
// }

// Future<String> API_export_multiple(importances, ids) async {
//   Map<String, dynamic> body = {
//     'status': 'export_multiple',
//     'importance': importances.toString(),
//     'id': ids.toString()
//   };
//   String response = await makePostRequest(body);
//   return response;
// }


