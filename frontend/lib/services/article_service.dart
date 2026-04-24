import 'api_client.dart';
import '../models/article.dart';

class ArticleService {
  static Future<List<Article>> fetchAll() async {
    final res = await ApiClient.instance.get('/articles');
    return (res.data as List).map((e) => Article.fromJson(e)).toList();
  }

  static Future<List<Article>> fetchByType(String type) async {
    final res = await ApiClient.instance.get('/articles/type/$type');
    return (res.data as List).map((e) => Article.fromJson(e)).toList();
  }

  static Future<Article> create(Article article) async {
    final res = await ApiClient.instance.post('/articles', data: article.toJson());
    return Article.fromJson(res.data);
  }

  static Future<Article> update(int id, Article article) async {
    final res = await ApiClient.instance.put('/articles/$id', data: article.toJson());
    return Article.fromJson(res.data);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('/articles/$id');
  }
}
