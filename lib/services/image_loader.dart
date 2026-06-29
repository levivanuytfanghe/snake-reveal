import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Loads an image from the app's assets
Future<ui.Image> loadImage(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Loads an image from a network URL
Future<ui.Image> loadNetworkImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode != 200) {
    throw Exception('Failed to load image: $imageUrl');
  }

  final bytes = Uint8List.fromList(response.bodyBytes);
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Loads theme data from themes.json asset
Future<Map<String, List<String>>> loadThemesJson() async {
  final jsonString = await rootBundle.loadString('assets/data/themes.json');
  final Map<String, dynamic> data = json.decode(jsonString);
  return data.map((key, value) => MapEntry(key, List<String>.from(value)));
}
