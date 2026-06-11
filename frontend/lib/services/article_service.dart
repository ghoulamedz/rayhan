import 'api_client.dart';
import '../models/article.dart';
import '../models/production_order.dart';

abstract class ArticleService {
  Future<List<Article>> fetchAll();
  Future<List<Article>> fetchByType(String type);
  Future<Article> create(Article article, {List<Map<String, dynamic>>? bomLines});
  Future<Article> update(int id, Article article, {List<Map<String, dynamic>>? bomLines});
  Future<void> delete(int id);
  Future<List<BomLine>> fetchBom(int articleId);
}

class RealArticleService implements ArticleService {
  @override
  Future<List<Article>> fetchAll() async {
    final res = await ApiClient.instance.get('/articles');
    return (res.data as List).map((e) => Article.fromJson(e)).toList();
  }

  @override
  Future<List<Article>> fetchByType(String type) async {
    final res = await ApiClient.instance.get('/articles/type/$type');
    return (res.data as List).map((e) => Article.fromJson(e)).toList();
  }

  @override
  Future<Article> create(Article article, {List<Map<String, dynamic>>? bomLines}) async {
    final data = <String, dynamic>{
      'article': article.toJson(),
      'bomLines': bomLines ?? [],
    };
    final res = await ApiClient.instance.post('/articles', data: data);
    return Article.fromJson(res.data);
  }

  @override
  Future<Article> update(int id, Article article, {List<Map<String, dynamic>>? bomLines}) async {
    final data = <String, dynamic>{
      'article': article.toJson(),
      'bomLines': bomLines ?? [],
    };
    final res = await ApiClient.instance.put('/articles/$id', data: data);
    return Article.fromJson(res.data);
  }

  @override
  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/articles/$id');
  }

  @override
  Future<List<BomLine>> fetchBom(int articleId) async {
    final res = await ApiClient.instance.get('/production/bom/$articleId');
    return (res.data as List).map((e) => BomLine.fromJson(e)).toList();
  }
}
