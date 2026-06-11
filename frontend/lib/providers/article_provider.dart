import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/production_order.dart';
import '../services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService articleService;

  ArticleProvider({required this.articleService});

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;
  String _filterType = 'TOUS';
  String _search = '';
  List<BomLine> _selectedBomLines = [];

  List<Article> get articles => _filtered();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterType => _filterType;
  List<BomLine> get selectedBomLines => _selectedBomLines;

  List<Article> _filtered() {
    return _articles.where((a) {
      final matchType = _filterType == 'TOUS' || a.type == _filterType;
      final matchSearch = _search.isEmpty ||
          a.reference.toLowerCase().contains(_search.toLowerCase()) ||
          a.designation.toLowerCase().contains(_search.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  void setFilter(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _articles = await articleService.fetchAll();
    } catch (_) {
      _error = 'Impossible de charger les articles.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Article article, {List<Map<String, dynamic>>? bomLines}) async {
    try {
      final created = await articleService.create(article, bomLines: bomLines);
      _articles.add(created);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(int id, Article article, {List<Map<String, dynamic>>? bomLines}) async {
    try {
      final updated = await articleService.update(id, article, bomLines: bomLines);
      final idx = _articles.indexWhere((a) => a.id == id);
      if (idx != -1) _articles[idx] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await articleService.delete(id);
      _articles.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchBomLines(int articleId) async {
    _selectedBomLines = await articleService.fetchBom(articleId);
    notifyListeners();
  }
}
