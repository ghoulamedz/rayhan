import 'dart:math';
import '../models/dashboard_kpi.dart';
import '../models/article.dart';
import '../models/sales_order.dart';
import '../models/client.dart';
import '../models/purchase_order.dart';
import '../models/fournisseur.dart';
import '../models/production_order.dart';
import '../models/stock_movement.dart';
import 'mock_data.dart';
import 'mock_config.dart';

class MockDashboardService {
  static Future<DashboardKpi> fetchKpis() async {
    await MockData.delay();
    return MockData.dashboardKpi;
  }
}

class MockAuthService {
  static MockUser? _currentUser;

  static MockUser? get currentUser => _currentUser;

  static Future<Map<String, dynamic>> login(String username, String password) async {
    await MockData.delay();
    final user = MockConfig.findUser(username, password);
    if (user != null) {
      _currentUser = user;
      return {
        'token': '${MockConfig.mockTokenPrefix}${user.role}',
        'type': 'Bearer',
        'id': MockConfig.mockUsers.indexOf(user) + 1,
        'username': user.username,
        'email': user.email,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'roles': [user.role],
      };
    }
    throw Exception('Identifiants incorrects');
  }

  static Future<void> saveToken(String token, String role) async {}

  static Future<String?> getToken() async {
    if (_currentUser != null) return '${MockConfig.mockTokenPrefix}${_currentUser!.role}';
    return null;
  }

  static Future<String?> getRole() async => _currentUser?.role;

  static Future<void> logout() async {
    _currentUser = null;
  }
}

class MockArticleService {
  static List<Article> _articles = [];
  static int _nextId = 100;

  static Future<List<Article>> fetchAll() async {
    await MockData.delay();
    if (_articles.isEmpty) {
      _articles = MockData.articles.map((m) => Article(
        id: m['id'] as int,
        reference: m['reference'] as String,
        designation: m['designation'] as String,
        type: m['type'] as String,
        uniteMesure: m['uniteMesure'] as String? ?? 'unité',
        prixUnitaire: (m['prixUnitaire'] as num).toDouble(),
        stockActuel: (m['stockActuel'] as num).toDouble(),
        stockMinimum: (m['stockMinimum'] as num).toDouble(),
      )).toList();
      _nextId = 200;
    }
    return List.unmodifiable(_articles);
  }

  static Future<Article> create(Article article) async {
    await MockData.delay();
    final created = Article(
      id: _nextId++,
      reference: article.reference,
      designation: article.designation,
      type: article.type,
      uniteMesure: article.uniteMesure,
      prixUnitaire: article.prixUnitaire,
      stockActuel: article.stockActuel,
      stockMinimum: article.stockMinimum,
    );
    _articles.add(created);
    return created;
  }

  static Future<Article> update(int id, Article article) async {
    await MockData.delay();
    final idx = _articles.indexWhere((a) => a.id == id);
    if (idx == -1) throw Exception('Article non trouvé');
    final updated = Article(
      id: id,
      reference: article.reference,
      designation: article.designation,
      type: article.type,
      uniteMesure: article.uniteMesure,
      prixUnitaire: article.prixUnitaire,
      stockActuel: article.stockActuel,
      stockMinimum: article.stockMinimum,
    );
    _articles[idx] = updated;
    return updated;
  }

  static Future<void> delete(int id) async {
    await MockData.delay();
    _articles.removeWhere((a) => a.id == id);
  }
}

class MockClientService {
  static final List<Client> _clients = [
    Client(id: 1, raisonSociale: 'SOTUPLAST S.A.', matriculeFiscal: '123456789', adresse: 'Route de la Marsa'),
    Client(id: 2, raisonSociale: 'PLASTITUNISIE', matriculeFiscal: '987654321', adresse: 'Z.I. Charguia II'),
    Client(id: 3, raisonSociale: 'EMBALLAGES MODERNES', matriculeFiscal: '456123789', adresse: 'Megrine'),
    Client(id: 4, raisonSociale: 'AGRO-PACK S.A.R.L.', matriculeFiscal: '789456123', adresse: 'Technopole El Ghazala'),
  ];

  static Future<List<Client>> fetchAll() async {
    await MockData.delay();
    return List.unmodifiable(_clients);
  }
}

class MockFournisseurService {
  static final List<Fournisseur> _fournisseurs = [
    Fournisseur(id: 1, raisonSociale: 'POLYMERGY TUNISIE', matriculeFiscal: '111222333', adresse: 'Z.I. Ben Arous'),
    Fournisseur(id: 2, raisonSociale: 'CHIMIPLAST S.A.', matriculeFiscal: '444555666', adresse: 'Sfax'),
    Fournisseur(id: 3, raisonSociale: 'EUROPLAST GmbH', matriculeFiscal: '777888999', adresse: 'Hambourg, Allemagne'),
  ];

  static Future<List<Fournisseur>> fetchAll() async {
    await MockData.delay();
    return List.unmodifiable(_fournisseurs);
  }
}

class MockSalesOrderService {
  static int _idCounter = 100;

  static Future<List<SalesOrder>> fetchAll() async {
    await MockData.delay();
    return MockData.salesOrders.map((m) {
      final client = MockClientService._clients.firstWhere(
        (c) => c.raisonSociale == m['client'],
        orElse: () => MockClientService._clients.first,
      );
      return SalesOrder(
        id: _idCounter++,
        reference: m['reference'] as String,
        client: client,
        dateCommande: '2024-05-${m['date']?.toString().substring(0, 2) ?? '15'}',
        statut: _statusFromLabel(m['statutLabel'] as String),
        totalTTC: m['totalTTC'] as double,
        lignes: List.generate(m['lignes'] as int, (i) => SalesOrderLine(
          id: i + 1,
          quantiteCommandee: Random().nextInt(100) + 10,
          prixUnitaireHT: Random().nextDouble() * 50 + 5,
        )),
      );
    }).toList();
  }

  static Future<SalesOrder> create(SalesOrder order) async {
    await MockData.delay();
    return order;
  }

  static Future<void> deliver(int orderId, Map<String, dynamic> payload) async {
    await MockData.delay();
  }

  static String _statusFromLabel(String label) {
    switch (label) {
      case 'En cours': return 'EN_PREPARATION';
      case 'Livrée': return 'COMPLETEMENT_LIVREE';
      case 'En attente': return 'CONFIRMEE';
      default: return 'CONFIRMEE';
    }
  }
}

class MockPurchaseOrderService {
  static int _idCounter = 100;

  static Future<List<PurchaseOrder>> fetchAll() async {
    await MockData.delay();
    return MockData.purchaseOrders.map((m) {
      final fournisseur = MockFournisseurService._fournisseurs.firstWhere(
        (f) => f.raisonSociale == m['fournisseur'],
        orElse: () => MockFournisseurService._fournisseurs.first,
      );
      return PurchaseOrder(
        id: _idCounter++,
        reference: m['reference'] as String,
        fournisseur: fournisseur,
        dateCommande: '2024-05-${m['date']?.toString().substring(0, 2) ?? '10'}',
        statut: _statusFromLabel(m['statutLabel'] as String),
        totalTTC: m['totalTTC'] as double,
        lignes: List.generate(m['lignes'] as int, (i) => PurchaseOrderLine(
          id: i + 1,
          quantiteCommandee: Random().nextInt(500) + 50,
          prixUnitaireHT: Random().nextDouble() * 20 + 2,
        )),
      );
    }).toList();
  }

  static Future<PurchaseOrder> create(PurchaseOrder order) async {
    await MockData.delay();
    return order;
  }

  static Future<void> receive(int orderId, Map<String, dynamic> payload) async {
    await MockData.delay();
  }

  static String _statusFromLabel(String label) {
    switch (label) {
      case 'Reçue': return 'COMPLETEMENT_RECUE';
      case 'En cours': return 'CONFIRMEE';
      case 'En attente': return 'BROUILLON';
      default: return 'CONFIRMEE';
    }
  }
}

class MockProductionService {
  static int _idCounter = 100;

  static Future<List<ProductionOrder>> fetchAll() async {
    await MockData.delay();
    return MockData.productionOrders.map((m) => ProductionOrder(
      id: _idCounter++,
      reference: m['reference'] as String,
      quantitePlanifiee: (m['quantite'] as int).toDouble(),
      quantiteRealisee: (m['realisee'] as int).toDouble(),
      datePlanifiee: '2024-05-${m['date']?.toString().substring(0, 2) ?? '15'}',
      statut: _statusFromLabel(m['statutLabel'] as String),
    )).toList();
  }

  static Future<ProductionOrder> plan({
    required int produitFiniId,
    required double quantite,
    required String datePlanifiee,
  }) async {
    await MockData.delay();
    return ProductionOrder(
      id: _idCounter++,
      reference: 'OF-2024-${_idCounter.toString().padLeft(3, '0')}',
      statut: 'PLANIFIE',
      quantitePlanifiee: quantite,
      quantiteRealisee: 0,
      datePlanifiee: datePlanifiee,
    );
  }

  static Future<ProductionOrder> launch(int id) async {
    await MockData.delay();
    return ProductionOrder(
      id: id,
      reference: 'OF-2024-0$id',
      statut: 'LANCE',
      quantitePlanifiee: 100,
      quantiteRealisee: 0,
      datePlanifiee: '2024-05-20',
    );
  }

  static Future<ProductionOrder> complete(int id, double quantiteRealisee) async {
    await MockData.delay();
    return ProductionOrder(
      id: id,
      reference: 'OF-2024-0$id',
      statut: 'TERMINE',
      quantitePlanifiee: 100,
      quantiteRealisee: quantiteRealisee,
      datePlanifiee: '2024-05-20',
    );
  }

  static String _statusFromLabel(String label) {
    switch (label) {
      case 'Lancé': return 'LANCE';
      case 'Planifié': return 'PLANIFIE';
      case 'Terminé': return 'TERMINE';
      case 'En cours': return 'EN_COURS';
      default: return 'PLANIFIE';
    }
  }
}

class MockStockService {
  static int _idCounter = 200;

  static Future<List<StockMovement>> getHistorique(int articleId) async {
    await MockData.delay();
    return List.generate(5, (i) => StockMovement(
      id: _idCounter++,
      type: i % 2 == 0 ? 'IN' : 'OUT',
      quantite: (i + 1) * 10.0,
      motif: i % 2 == 0 ? 'Réception fournisseur' : 'Utilisation production',
      dateHeure: '2024-05-${15 - i}T10:00:00',
    ));
  }

  static Future<StockMovement> adjust({
    required int articleId,
    required double quantite,
    required String type,
    required String motif,
  }) async {
    await MockData.delay();
    return StockMovement(
      id: _idCounter++,
      type: type,
      quantite: quantite,
      motif: motif,
      dateHeure: DateTime.now().toIso8601String(),
    );
  }
}
