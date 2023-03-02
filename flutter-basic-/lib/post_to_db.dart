// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

Future<bool> db_post(input) async {
  final String jsonstring = await rootBundle.loadString('config.json');
  final data = await json.decode(jsonstring);
  var url = Uri.parse(data["entry_url"]);

  try {
    await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'text': input}));
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> db_clear() async {
  final String jsonstring = await rootBundle.loadString('config.json');
  final data = await json.decode(jsonstring);
  var url = Uri.parse(data["clear_url"]);

  try {
    await http.post(url);
  } catch (e) {}
}
