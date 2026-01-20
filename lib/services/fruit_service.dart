
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:treesha/models/fruit_model.dart';

class FruitService {
  static Future<List<Fruit>> loadFruits([String? filter]) async {
    final String response = await rootBundle.loadString('assets/fruits.json');
    final List<dynamic> data = json.decode(response);
    List<Fruit> allFruits = data.map((json) => Fruit.fromJson(json)).toList();

    if (filter != null && filter.isNotEmpty) {
      return allFruits.where((fruit) => fruit.type.toLowerCase().contains(filter.toLowerCase())).toList();
    }
    return allFruits;
  }
}
