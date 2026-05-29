import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../services/fournisseur_service.dart';

class FournisseursProvider extends ChangeNotifier {
  final FournisseurService fournisseurService;

  FournisseursProvider({required this.fournisseurService});

  List<Fournisseur> _fournisseurs = [];
  bool _isLoading = false;
  String? _error;

  List<Fournisseur> get fournisseurs => _fournisseurs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _fournisseurs = await fournisseurService.fetchAll();
    } catch (_) {
      _error = 'Impossible de charger les fournisseurs.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> create(Fournisseur fournisseur) async {
    try {
      final created = await fournisseurService.create(fournisseur);
      _fournisseurs.insert(0, created);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erreur lors de la création du fournisseur';
    }
  }

  Future<String?> update(int id, Fournisseur fournisseur) async {
    try {
      final updated = await fournisseurService.update(id, fournisseur);
      final idx = _fournisseurs.indexWhere((f) => f.id == id);
      if (idx != -1) _fournisseurs[idx] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erreur lors de la modification du fournisseur';
    }
  }
}