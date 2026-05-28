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

