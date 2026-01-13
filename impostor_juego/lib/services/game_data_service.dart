import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class WordData {
  final String palabra;
  final String pista;
  final String categoria;

  WordData({
    required this.palabra,
    required this.pista,
    required this.categoria,
  });
}

class GameDataService {
  static Map<String, dynamic>? _cachedData;
  static List<String>? _categories;

  static Future<void> loadData() async {
    if (_cachedData != null) return;

    final jsonString = await rootBundle.loadString('assets/data/data_impostor');
    _cachedData = jsonDecode(jsonString);
    _categories =
        (_cachedData!['categorias'] as Map<String, dynamic>).keys.toList();
  }

  static List<String> get categories => _categories ?? [];

  static WordData getRandomWord({String? category}) {
    if (_cachedData == null) {
      return WordData(palabra: "Error", pista: "Carga fallida", categoria: "");
    }

    final categorias = _cachedData!['categorias'] as Map<String, dynamic>;
    final random = Random();

    // Pick category
    String selectedCategory;
    if (category != null && categorias.containsKey(category)) {
      selectedCategory = category;
    } else {
      selectedCategory = _categories![random.nextInt(_categories!.length)];
    }

    // Pick random word from category
    final words = categorias[selectedCategory] as List<dynamic>;
    final wordEntry =
        words[random.nextInt(words.length)] as Map<String, dynamic>;

    return WordData(
      palabra: wordEntry['palabra'] as String,
      pista: wordEntry['pista'] as String,
      categoria: _formatCategoryName(selectedCategory),
    );
  }

  static String _formatCategoryName(String raw) {
    // Convert snake_case to Title Case
    return raw
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
