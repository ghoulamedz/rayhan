// All enumeration types derived from the Rayhan class diagram.

enum Role {
  responsableVente,
  magasinier,
  responsableAchat,
  responsableProduction,
  pdg,
  admin;

  String get label => switch (this) {
        Role.responsableVente => 'Responsable Vente',
        Role.magasinier => 'Magasinier',
        Role.responsableAchat => 'Responsable Achat',
        Role.responsableProduction => 'Responsable Production',
        Role.pdg => 'PDG',
        Role.admin => 'Administrateur',
      };
}

enum StatutCommande {
  enCours,
  valide,
  livre,
  annule;

  String get label => switch (this) {
        StatutCommande.enCours => 'En cours',
        StatutCommande.valide => 'Validé',
        StatutCommande.livre => 'Livré',
        StatutCommande.annule => 'Annulé',
      };
}

enum StatutProduction {
  planifie,
  enCours,
  termine,
  annule;

  String get label => switch (this) {
        StatutProduction.planifie => 'Planifié',
        StatutProduction.enCours => 'En cours',
        StatutProduction.termine => 'Terminé',
        StatutProduction.annule => 'Annulé',
      };
}

enum StatutAchat {
  enCours,
  livre,
  livraisonPartielle,
  refuse,
  annule;

  String get label => switch (this) {
        StatutAchat.enCours => 'En cours',
        StatutAchat.livre => 'Livré',
        StatutAchat.livraisonPartielle => 'Livraison partielle',
        StatutAchat.refuse => 'Refusé',
        StatutAchat.annule => 'Annulé',
      };
}

enum TypeMatiere {
  hdpe,
  ldpe,
  autre;

  String get label => switch (this) {
        TypeMatiere.hdpe => 'HDPE',
        TypeMatiere.ldpe => 'LDPE',
        TypeMatiere.autre => 'Autre',
      };
}

enum NiveauUrgence {
  info,
  avertissement,
  critique;

  String get label => switch (this) {
        NiveauUrgence.info => 'Info',
        NiveauUrgence.avertissement => 'Avertissement',
        NiveauUrgence.critique => 'Critique',
      };
}

enum CategorieNotif {
  vente,
  stock,
  achat,
  production;

  String get label => switch (this) {
        CategorieNotif.vente => 'Vente',
        CategorieNotif.stock => 'Stock',
        CategorieNotif.achat => 'Achat',
        CategorieNotif.production => 'Production',
      };
}
