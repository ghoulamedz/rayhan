import 'api_client.dart';
import '../models/client.dart';

abstract class ClientService {
  Future<List<Client>> fetchAll();
  Future<Client> create(Client client);
}

class RealClientService implements ClientService {
  @override
  Future<List<Client>> fetchAll() async {
    final res = await ApiClient.instance.get('/clients');
    return (res.data as List).map((e) => Client.fromJson(e)).toList();
  }

  @override
  Future<Client> create(Client client) async {
    final res = await ApiClient.instance.post('/clients', data: client.toJson());
    return Client.fromJson(res.data);
  }
}
