import 'dart:convert';
import 'dart:developer' as logger;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NewsProvider extends ChangeNotifier {
  static const _apiKey = 'c0a8fe7d946c41a79725fe5c4add934d';

  List<Map<String, dynamic>> trendingNews = [];
  List<Map<String, dynamic>> categoryNews = [];
  bool isTrendingNewsLoading = false;
  bool isCategoryNewsLoading = false;

  Future<List<Map<String, dynamic>>> _fetchNews({String? category}) async {
    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'apiKey': _apiKey,
      if (category != null) 'category': category.toLowerCase(),
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('News request failed (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['articles'] ?? []);
  }

  Future<void> getTrendingNews() async {
    isTrendingNewsLoading = true;
    notifyListeners();
    try {
      trendingNews = await _fetchNews();
    } catch (error) {
      logger.log('Could not load trending news', error: error);
    } finally {
      isTrendingNewsLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCategoryNews(String category) async {
    isCategoryNewsLoading = true;
    categoryNews = [];
    notifyListeners();
    try {
      categoryNews = await _fetchNews(category: category);
    } catch (error) {
      logger.log('Could not load category news', error: error);
    } finally {
      isCategoryNewsLoading = false;
      notifyListeners();
    }
  }
}
