import 'package:flutter/material.dart';

import 'enums.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Utilisateur
// ──────────────────────────────────────────────────────────────────────────────

class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.statut,
    required this.creeLe,
  });

  final String id;
  final String nom;
  final String prenom;
  final String email;
  final Role role;
  final String statut;
  final DateTime creeLe;

  String get nomComplet => '$prenom $nom';
}

// ──────────────────────────────────────────────────────────────────────────────
// Ligne Produit (embedded in Vente)
// ──────────────────────────────────────────────────────────────────────────────

class LigneProduit {
  const LigneProduit({
    required this.produitId,
    required this.designation,
    required this.quantite,
    required this.unite,
  });

  final String produitId;
  final String designation;
  final int quantite;
  final String unite;
}

// ──────────────────────────────────────────────────────────────────────────────
// Vente
// ──────────────────────────────────────────────────────────────────────────────

class Vente {
  const Vente({
    required this.id,
    required this.lignesProduits,
    required this.dateCommande,
    required this.dateLivraisonSouhaitee,
    required this.statut,
    required this.responsableVenteId,
    required this.creeLe,
    this.client = '',
    this.montantTTC = 0.0,
  });

  final String id;
  final List<LigneProduit> lignesProduits;
  final DateTime dateCommande;
  final DateTime dateLivraisonSouhaitee;
  final StatutCommande statut;
  final String responsableVenteId;
  final DateTime creeLe;
  final String client;
  final double montantTTC;
}

// ──────────────────────────────────────────────────────────────────────────────
// Ligne BOM (embedded in Produit)
// ──────────────────────────────────────────────────────────────────────────────

class LigneBOM {
  const LigneBOM({
    required this.matierePremiereid,
    required this.designation,
    required this.quantiteParUnite,
    required this.unite,
  });

  final String matierePremiereid;
  final String designation;
  final double quantiteParUnite;
  final String unite;
}

// ──────────────────────────────────────────────────────────────────────────────
// Produit
// ──────────────────────────────────────────────────────────────────────────────

class Produit {
  const Produit({
    required this.id,
    required this.designation,
    required this.type,
    required this.bom,
    required this.stockActuel,
    required this.seuilMinimal,
    required this.creeLe,
    this.skuCode = '',
    this.categorie = '',
  });

  final String id;
  final String designation;
  final String type;
  final List<LigneBOM> bom;
  final double stockActuel;
  final double seuilMinimal;
  final DateTime creeLe;
  final String skuCode;
  final String categorie;

  bool get isStockBas => stockActuel <= seuilMinimal;

  double get niveauReapprovisionnement => seuilMinimal > 0
      ? (stockActuel / (seuilMinimal * 2)).clamp(0.0, 1.0)
      : 1.0;
}

// ──────────────────────────────────────────────────────────────────────────────
// Matière Première
// ──────────────────────────────────────────────────────────────────────────────

class MatierePremiere {
  const MatierePremiere({
    required this.id,
    required this.designation,
    required this.type,
    required this.stockActuel,
    required this.seuilMinimal,
    required this.unite,
    required this.creeLe,
  });

  final String id;
  final String designation;
  final TypeMatiere type;
  final double stockActuel;
  final double seuilMinimal;
  final String unite;
  final DateTime creeLe;

  bool get isStockBas => stockActuel <= seuilMinimal;

  double get pourcentageStock => seuilMinimal > 0
      ? (stockActuel / (seuilMinimal * 2)).clamp(0.0, 1.0)
      : 1.0;
}

// ──────────────────────────────────────────────────────────────────────────────
// Production
// ──────────────────────────────────────────────────────────────────────────────

class Production {
  const Production({
    required this.id,
    required this.produitId,
    required this.quantite,
    required this.dateDebut,
    required this.statut,
    required this.responsableId,
    required this.creeLe,
    this.finDate,
    this.progression = 0.0,
    this.lotReference = '',
    this.responsableNom = '',
    this.produitDesignation = '',
  });

  final String id;
  final String produitId;
  final double quantite;
  final DateTime dateDebut;
  final DateTime? finDate;
  final StatutProduction statut;
  final String responsableId;
  final DateTime creeLe;
  final double progression;
  final String lotReference;
  final String responsableNom;
  final String produitDesignation;
}

// ──────────────────────────────────────────────────────────────────────────────
// Fournisseur
// ──────────────────────────────────────────────────────────────────────────────

class Fournisseur {
  const Fournisseur({
    required this.id,
    required this.nom,
    required this.contact,
    required this.materiauxLivres,
    required this.delaiMoyen,
    required this.score,
    required this.actif,
    required this.creeLe,
  });

  final String id;
  final String nom;
  final String contact;
  final List<String> materiauxLivres;
  final int delaiMoyen;
  final double score;
  final bool actif;
  final DateTime creeLe;
}

// ──────────────────────────────────────────────────────────────────────────────
// Achat
// ──────────────────────────────────────────────────────────────────────────────

class Achat {
  const Achat({
    required this.id,
    required this.matierePremiereid,
    required this.fournisseurId,
    required this.quantiteCommandee,
    required this.quantiteRecue,
    required this.dateLivraisonPrevue,
    required this.statut,
    required this.creeLe,
    this.dateReception,
  });

  final String id;
  final String matierePremiereid;
  final String fournisseurId;
  final double quantiteCommandee;
  final double quantiteRecue;
  final DateTime dateLivraisonPrevue;
  final DateTime? dateReception;
  final StatutAchat statut;
  final DateTime creeLe;
}

// ──────────────────────────────────────────────────────────────────────────────
// Notification
// ──────────────────────────────────────────────────────────────────────────────

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.destinataireId,
    required this.message,
    required this.categorie,
    required this.urgence,
    required this.lu,
    required this.dateEnvoi,
    this.lienModuleSource = '',
  });

  final String id;
  final String destinataireId;
  final String message;
  final CategorieNotif categorie;
  final NiveauUrgence urgence;
  final bool lu;
  final DateTime dateEnvoi;
  final String lienModuleSource;
}

// ──────────────────────────────────────────────────────────────────────────────
// Mouvement Stock
// ──────────────────────────────────────────────────────────────────────────────

class MouvementStock {
  const MouvementStock({
    required this.id,
    required this.matierePremiereid,
    required this.type,
    required this.quantite,
    required this.date,
    required this.sourceId,
    required this.sourceType,
    this.designation = '',
    this.lot = '',
    this.operateur = '',
  });

  final String id;
  final String matierePremiereid;

  /// 'entrée' | 'sortie'
  final String type;
  final double quantite;
  final DateTime date;
  final String sourceId;
  final String sourceType;
  final String designation;
  final String lot;
  final String operateur;

  bool get isEntree => type == 'entrée';
}

// ──────────────────────────────────────────────────────────────────────────────
// Maintenance
// ──────────────────────────────────────────────────────────────────────────────

enum StatutMaintenance {
  planifiee,
  enCours,
  terminee,
  annulee;

  String get label => switch (this) {
        StatutMaintenance.planifiee => 'Planifiée',
        StatutMaintenance.enCours => 'En cours',
        StatutMaintenance.terminee => 'Terminée',
        StatutMaintenance.annulee => 'Annulée',
      };
}

enum TypeMaintenance {
  preventive,
  corrective,
  predictive;

  String get label => switch (this) {
        TypeMaintenance.preventive => 'Préventive',
        TypeMaintenance.corrective => 'Corrective',
        TypeMaintenance.predictive => 'Prédictive',
      };
}

enum PrioriteMaintenance {
  basse,
  moyenne,
  haute,
  critique;

  String get label => switch (this) {
        PrioriteMaintenance.basse => 'Basse',
        PrioriteMaintenance.moyenne => 'Moyenne',
        PrioriteMaintenance.haute => 'Haute',
        PrioriteMaintenance.critique => 'Critique',
      };
}

class Equipement {
  const Equipement({
    required this.id,
    required this.nom,
    required this.ligne,
    required this.oeePct,
    required this.temperatureC,
    required this.vibration,
    required this.cadence,
    required this.statut,
    required this.heuresDepuisRevision,
    required this.heuresRevisionMax,
    this.alerte,
  });

  final String id;
  final String nom;
  final String ligne;

  /// 0.0 – 1.0
  final double oeePct;
  final double temperatureC;

  /// 'Nominal' | 'Élevée' | 'Critique'
  final String vibration;
  final double cadence;

  /// 'operationnel' | 'arret' | 'maintenance'
  final String statut;
  final int heuresDepuisRevision;
  final int heuresRevisionMax;
  final String? alerte;

  double get pctRevision =>
      (heuresDepuisRevision / heuresRevisionMax).clamp(0.0, 1.0);
}

class OrdreMaintenance {
  const OrdreMaintenance({
    required this.id,
    required this.equipementId,
    required this.equipementNom,
    required this.type,
    required this.priorite,
    required this.statut,
    required this.description,
    required this.technicien,
    required this.dateDebut,
    required this.creeLe,
    this.dateFin,
    this.dureeEstimeeH = 2,
    this.pieceRequise = '',
  });

  final String id;
  final String equipementId;
  final String equipementNom;
  final TypeMaintenance type;
  final PrioriteMaintenance priorite;
  final StatutMaintenance statut;
  final String description;
  final String technicien;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final DateTime creeLe;
  final int dureeEstimeeH;
  final String pieceRequise;
}

// ──────────────────────────────────────────────────────────────────────────────
// Contrôle Qualité
// ──────────────────────────────────────────────────────────────────────────────

enum StatutInspection {
  conforme,
  nonConforme,
  enAttente,
  conditionnel;

  String get label => switch (this) {
        StatutInspection.conforme => 'Conforme',
        StatutInspection.nonConforme => 'Non conforme',
        StatutInspection.enAttente => 'En attente',
        StatutInspection.conditionnel => 'Conditionnel',
      };
}

class Inspection {
  const Inspection({
    required this.id,
    required this.lotReference,
    required this.produitDesignation,
    required this.inspecteur,
    required this.dateInspection,
    required this.statut,
    required this.tolerancePositive,
    required this.toleranceNegative,
    required this.mesureReelle,
    required this.echantillonSize,
    required this.defautsDetectes,
    this.commentaire = '',
  });

  final String id;
  final String lotReference;
  final String produitDesignation;
  final String inspecteur;
  final DateTime dateInspection;
  final StatutInspection statut;
  final double tolerancePositive;
  final double toleranceNegative;
  final double mesureReelle;
  final int echantillonSize;
  final int defautsDetectes;
  final String commentaire;

  double get tauxDefaut =>
      echantillonSize > 0 ? defautsDetectes / echantillonSize : 0.0;
  bool get isConforme => statut == StatutInspection.conforme;
}

class ValueCardData {
  const ValueCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.hoverIconBg,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final Color hoverIconBg;
}

// ── KPI Metric ────────────────────────────────────────────────────────────────

class KpiData {
  const KpiData({
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.progressValue,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;

  /// 0.0 – 1.0; if non-null a progress bar is shown instead of the subtitle.
  final double? progressValue;
}

// ── Production Order ──────────────────────────────────────────────────────────

enum OrderStatus { inProgress, pending }

class ProductionOrder {
  const ProductionOrder({
    required this.orderNumber,
    required this.machine,
    required this.status,
    required this.statusDetail,
    required this.accentColor,
  });

  final String orderNumber;
  final String machine;
  final OrderStatus status;
  final String statusDetail;
  final Color accentColor;
}

// ── System Alert ──────────────────────────────────────────────────────────────

class SystemAlert {
  const SystemAlert({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class ModuleData {
  const ModuleData({
    required this.icon,
    required this.title,
    required this.features,
  });

  final IconData icon;
  final String title;
  final List<String> features;
}
