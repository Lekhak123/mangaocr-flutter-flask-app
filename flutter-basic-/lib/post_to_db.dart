// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'dart:io';
import 'package:dio/dio.dart';

Future<String> ocr(input) async {
  final String jsonstring = await rootBundle.loadString('config.json');
  final data = await json.decode(jsonstring);
  var url = data["ocr_url"];
  final dio = Dio();

  try {
    final response = await dio.post(url,
        data: jsonEncode({'imgString': input}));
    return response.data["text"];
  } catch (e) {
    return e.toString();
  }
}

// Future<void> db_clear() async {
//   final String jsonstring = await rootBundle.loadString('config.json');
//   final data = await json.decode(jsonstring);
//   var url = Uri.parse(data["clear_url"]);

//   try {
//     await http.post(url);
//   } catch (e) {}
// }
