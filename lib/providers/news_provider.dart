import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsProvider extends ChangeNotifier {
  Future getTrendingNews() async {
    String url =
        "https://newsapi.org/v2/top-headlines?country=us&apiKey=c0a8fe7d946c41a79725fe5c4add934d";
  }
}

