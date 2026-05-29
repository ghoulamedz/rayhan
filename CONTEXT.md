# Rayhan ERP — Domain Glossary

## Stock & Inventory

**Stock d'alerte**
État d'un article dont le `stockActuel` est inférieur à son `stockMinimum` (seuil configurable par article). Ne pas confondre avec la rupture (`stockActuel <= 0`).

**Rupture de stock**
État d'un article dont `stockActuel <= 0`. Cas particulier du stock d'alerte, mais pas l'inverse.

## Orders

**Commande vente (SalesOrder)**
Engagement de vendre des articles à un client. Statuts : EN_ATTENTE, CONFIRMEE, COMPLETEMENT_LIVREE, PARTIELLEMENT_LIVREE, ANNULEE.

**Commande achat (PurchaseOrder)**
Engagement d'acheter des articles chez un fournisseur. Statuts : EN_ATTENTE, CONFIRMEE, COMPLETEMENT_RECUE, PARTIELLEMENT_RECUE, ANNULEE.

**Ligne de commande (OrderLine)**
Un article avec une quantité, un prix, un taux TVA. Les montants HT/TVA/TTC sont calculés par ligne et sommés au niveau commande.

**Bon de livraison (DeliveryNote) / Bon de réception (GoodsReceipt)**
Document qui exécute partiellement ou totalement une commande. Déduit (vente) ou ajoute (achat) au stock.

## Clients & Comptes

**Client (entité)**
Entreprise cliente, sous-type de Tiers (JOINED inheritance). Porte les infos commerciales : raison sociale, MF, adresse, type client, plafond crédit, délai paiement, contact représentant.

**Compte client (User avec ROLE_CLIENT)**
Utilisateur qui peut se connecter à l'ERP pour accéder à son portail client. Lié en 1:1 à un Client. Le username est l'email du client. Créé via l'écran Clients par PDG/Responsable Ventes.

**ROLE_CLIENT**
Rôle dans le système (enum ERole). Pour l'instant, aucun accès aux écrans — réservé à un futur portail client. Créé automatiquement par DataInitializer.

## Staff / Employés

**Compte staff (User avec un rôle interne)**
Utilisateur interne de l'ERP — PDG, Responsable Ventes, Responsable Achats, Responsable Production ou Magasinier. Pas lié à un Client. Créé et géré exclusivement par le PDG depuis l'écran Utilisateurs.

**Rôles staff (internes)**
ROLE_PDG, ROLE_RESPONSABLE_VENTE, ROLE_RESPONSABLE_ACHAT, ROLE_RESPONSABLE_PRODUCTION, ROLE_MAGASINIER. Les rôles ROLE_CLIENT et ROLE_FOURNISSEUR sont des rôles externes (portail), pas gérés depuis cet écran.

**Accès par rôle**
| Rôle | Écrans accessibles |
|---|---|
| ROLE_PDG | Tous (dashboard, articles, ventes, clients, achats, fournisseurs, production, stock, rapports, utilisateurs) |
| ROLE_RESPONSABLE_VENTE | Ventes, Clients, Stock |
| ROLE_RESPONSABLE_ACHAT | Achats, Fournisseurs, Stock |
| ROLE_RESPONSABLE_PRODUCTION | Production, Stock |
| ROLE_MAGASINIER | Stock |

