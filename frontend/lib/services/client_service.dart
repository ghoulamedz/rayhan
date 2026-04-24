import 'api_client.dart';
import '../models/client.dart';

class ClientService {
  static Future<List<Client>> fetchAll() async {
    final res = await ApiClient.instance.get('/clients');
    return (res.data as List).map((e) => Client.fromJson(e)).toList();
  }

  static Future<Client> create(Client client) async {
    final res = await ApiClient.instance.post('/clients', data: client.toJson());
    return Client.fromJson(res.data);
  }
}
