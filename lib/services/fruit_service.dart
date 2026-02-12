import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:treez/models/fruit_model.dart';

class FruitService {
  static Future<List<Fruit>> loadFruits() async {
    final String response = await rootBundle.loadString('assets/fruits.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Fruit.fromJson(json)).toList();
  }
}
