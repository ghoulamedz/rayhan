import 'api_client.dart';
import '../models/fournisseur.dart';

abstract class FournisseurService {
  Future<List<Fournisseur>> fetchAll();
  Future<Fournisseur> create(Fournisseur f);
}

class RealFournisseurService implements FournisseurService {
  @override
  Future<List<Fournisseur>> fetchAll() async {
    final res = await ApiClient.instance.get('/fournisseurs');
    return (res.data as List).map((e) => Fournisseur.fromJson(e)).toList();
  }

  @override
  Future<Fournisseur> create(Fournisseur f) async {
    final res = await ApiClient.instance.post('/fournisseurs', data: f.toJson());
    return Fournisseur.fromJson(res.data);
  }
}
