import 'api_client.dart';
import '../models/fournisseur.dart';

class FournisseurService {
  static Future<List<Fournisseur>> fetchAll() async {
    final res = await ApiClient.instance.get('/fournisseurs');
    return (res.data as List).map((e) => Fournisseur.fromJson(e)).toList();
  }

  static Future<Fournisseur> create(Fournisseur f) async {
    final res = await ApiClient.instance.post('/fournisseurs', data: f.toJson());
    return Fournisseur.fromJson(res.data);
  }
}
