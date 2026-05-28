# Rayhan ERP — PRD : Architecture & Infrastructure

> **Date** : 28 May 2026
> **Source** : Architecture review + choix utilisateur (migration `actions/deploy-pages@v4`)
> **Tests** : Aucun — hors scope pour ce cycle

---

## PRD 1 : Nettoyage du Code Mort

### Problem Statement
~41 fichiers dans `custom/`, `final/`, et `models/mock/` sont annotés `//UNUSED` et totalement inaccessibles depuis `main.dart`. Ces fichiers traînent un deuxième modèle de domaine concurrent (`models/mock/models.dart`) avec des définitions dupliquées de `Fournisseur`, `ProductionOrder`, etc. — mêmes noms, champs différents. Cela crée de la confusion : un développeur cherchant "Fournisseur" trouve deux définitions contradictoires.

### Solution
Supprimer les 4 répertoires morts. Vérifier que les imports ne persistent pas. Confirmer par `flutter analyze` et `flutter build web --release`.

### User Stories
1. En tant que développeur, je veux une seule définition de `Fournisseur` dans le codebase, pour ne pas avoir d'ambiguïté sur les champs à utiliser.
2. En tant que développeur, je veux que `flutter analyze` ne remonte pas de warnings de code mort, pour que les vrais problèmes soient visibles.
3. En tant que maintainer, je veux pouvoir supprimer `mock/` sans casser le `screens/final/` qui en dépend silencieusement.

### Implementation Decisions
- Supprimer : `lib/screens/custom/`, `lib/widgets/custom/`, `lib/screens/final/`, `lib/models/mock/`
- Vérification : `grep -r "models/mock" lib/` doit retourner zéro résultat
- Validation : `flutter analyze` zéro erreur + `flutter build web --release` succès

### Out of Scope
- Refactorer le mock système existant — il reste en place, juste débarrassé des fichiers morts

---

## PRD 2 : Injection de Dépendances — Provider Layer

### Problem Statement
Les 7 providers suivent tous le même pattern : `if (MockConfig.useMock) mockService.method() else realService.method()`. Aucune logique métier, ~200 lignes de boilerplate. Le toggle mock/real est une `const bool` compilée en dur. Impossible de tester un provider sans recompiler l'app. Ajouter un nouveau provider = copier-coller le pattern.

### Solution
Introduire une seam via injection de dépendances. Les providers acceptent un service dans leur constructeur. La décision mock/real est poussée dans `main.dart` (composition root). Utiliser `Provider` DI (déjà présent dans les dépendances du projet).

### User Stories
1. En tant que développeur, je veux passer d'une implémentation mock à une implémentation réelle sans recompilation, pour pouvoir tester les deux chemins rapidement.
2. En tant que développeur, je veux qu'ajouter un nouveau provider ne nécessite pas de copier le pattern de branching mock/real.
3. En tant que développeur, je veux pouvoir écrire un test unitaire sur un provider en lui injectant un faux service.

### Implementation Decisions
- Utiliser le multi-provider existant de `provider` (package déjà présent dans `pubspec.yaml`) — `ProxyProvider` ou passer les services dans les constructeurs
- Les providers deviennent : `class ArticleProvider extends ChangeNotifier { final ArticleServiceInterface service; ArticleProvider({required this.service}); ... }`
- Le branching mock/real se fait dans `main.dart` au niveau de la liste `MultiProvider`
- `MockConfig.useMock` devient un flag de build (`--dart-define=USE_MOCK`)
- Les services concrets (`ArticleService`, etc.) deviennent des classes instanciables (non plus statiques) — ou on garde le pattern statique mais on les enveloppe dans une interface

### Out of Scope
- Extraire des interfaces Dart pour les services (trop d'abstraction pour le gain réel en Dart)

---

## PRD 3 : Backend — Compléter le Service Layer

### Problem Statement
La moitié des controllers backend contournent la couche service : `ArticleController`, `AuthController`, `ClientController`, `FournisseurController` injectent les repositories directement. `DashboardController` contient 51 lignes de calcul KPI inline. `ArticleController.getArticlesEnAlerte` charge tous les articles en mémoire puis filtre avec streams au lieu d'une requête SQL ciblée. Incohérence avec `StockController`, `SalesOrderController`, etc. qui ont une couche service.

### Solution
Créer `ArticleService`, `ClientService`, `FournisseurService`, `DashboardService`. Déplacer la logique métier. Remplacer `findAll().stream().filter(...)` par une `@Query` Spring Data.

### User Stories
1. En tant que développeur, je veux que toute la logique métier soit dans les services, pas dans les controllers, pour pouvoir la tester unitairement.
2. En tant que développeur, je veux que `getArticlesEnAlerte` fasse une requête SQL ciblée, pour ne pas charger toutes les lignes en mémoire.

### Implementation Decisions
- `ArticleService` : extraire de `ArticleController` ; remplacer `findAll().stream().filter(a -> a.getStock() < a.getSeuilAlerte())` par `articleRepository.findByStockLessThanSeuilAlerte()` (dérived query)
- `DashboardService` : déplacer les KPIs du controller (aggregation par mois, statuts, toplist) vers le service
- `ClientService`, `FournisseurService` : déplacer la logique CRUD des controllers vers les services
- Conserver le pattern des services existants (`StockService`, `SalesOrderService`, etc.) : classe concrète `@Service`, pas d'interface

### Out of Scope
- Ajouter des interfaces aux services existants (non nécessaire sans tests)
- Changer les signatures des endpoints API

---

## PRD 4 : Configuration Environnement — `--dart-define`

### Problem Statement
`API_BASE_URL` est hardcodé `http://127.0.0.1:8080/api` dans `api_client.dart:5`. `USE_MOCK` est une `static const bool` dans `mock_config.dart:8`. Pour déployer sur un autre backend, il faut éditer le source. Le CI ne peut pas passer en mode réel sans patcher le code.

### Solution
Remplacer les deux par `--dart-define`. Valeurs par défaut pour le dev.

### User Stories
1. En tant que développeur, je veux builder l'app pour la prod avec `--dart-define=API_BASE_URL=https://api.rayhan.tn --dart-define=USE_MOCK=false`, sans modifier les sources.
2. En tant que CI, je veux pouvoir builder les deux modes (mock/real) avec des commandes différentes.

### Implementation Decisions
```dart
// api_client.dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8080/api',
);

// mock_config.dart
static const bool useMock = bool.fromEnvironment(
  'USE_MOCK',
  defaultValue: true,
);
```
- Mettre à jour `AGENTS.md` avec les commandes : `flutter run -d chrome --dart-define=USE_MOCK=false`
- Mettre à jour les GitHub Actions workflows si nécessaire

### Out of Scope
- Changer le mécanisme d'auth JWT (reste via `application.properties` / variables d'environnement)

---

## PRD 5 : Compteurs Statiques Mutables

### Problem Statement
`seqCC`, `seqBC`, `seqOF` dans `SalesOrderService` sont `private static int`. Ils se réinitialisent au redémarrage du serveur et sont partagés entre tous les threads. En scaling horizontal, les compteurs collisionnent. Impossible de tester en parallèle.

### Solution
Persister les séquences en base de données (table `sequence` ou `AUTO_INCREMENT`).

### User Stories
1. En tant qu'utilisateur, je veux que les numéros de commande ne se réinitialisent pas après un redémarrage du serveur.
2. En tant que développeur, je veux que les tests concurrents ne produisent pas des numéros en double.

### Implementation Decisions
- Créer une table `reference_sequences` avec les colonnes `type` (CC/BC/OF) et `last_value`
- Utiliser `SELECT ... FOR UPDATE` pour l'incrémentation atomique
- Alternative si la table est trop lourde : utiliser `GenerationType.TABLE` de JPA
- Supprimer les champs `static int` dans `SalesOrderService`

### Out of Scope
- Migrer vers un générateur distribué type Snowflake (surkill pour ce projet)

---

## PRD 6 : Docker & Déploiement — Simplification

### Problem Statement
La configuration Docker a plusieurs problèmes :
1. Deux fichiers compose (`docker-compose.yml` + `docker-compose.prod.yml`) qui divergent
2. `docker-compose.prod.yml` build encore le frontend depuis source (contredit le principe pre-built)
3. Aucun `.dockerignore` — le contexte envoyé au daemon inclut `target/` (backend) et `build/` (frontend)
4. Healthchecks manquants pour backend et frontend
5. Le frontend n'est pas poussé vers GHCR, donc pas disponible en pre-built

### Solution
Ajouter `.dockerignore`, healthchecks, unifier les compose files avec Docker Compose profiles, pousser aussi l'image frontend vers GHCR.

### User Stories
1. En tant qu'opérateur, je veux lancer `docker compose --profile prod up` pour la prod, `docker compose --profile dev up` pour le dev, avec un seul fichier compose.
2. En tant qu'opérateur, je veux que `docker compose up` attende que mysql soit prêt ET que le backend réponde.
3. En tant que développeur, je veux que `docker build backend` n'envoie pas 500 Mo de `target/` au daemon.

### Implementation Decisions
- Ajouter `backend/.dockerignore` : `target/`, `.git/`, `*.md`, `.gitignore`
- Ajouter `frontend/.dockerignore` : `build/`, `.dart_tool/`, `.packages`, `.git/`, `*.md`
- Backend healthcheck : Spring Actuator — exposer `/actuator/health` et configurer `test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]`
- Frontend healthcheck : `test: ["CMD", "nginx", "-t"]` (vérifie que nginx est OK)
- Garder deux compose files mais cleaner :
  - `docker-compose.yml` : dev (build local, profiles dev par défaut)
  - `docker-compose.prod.yml` : prod (images GHCR, profiles prod)
- Pousser l'image frontend vers GHCR dans le workflow backend ou créer un workflow dédié

### Out of Scope
- Kubernetes / Swarm — Docker Compose suffit pour ce projet
- Chiffrement des variables d'environnement prod (à faire plus tard)

---

## PRD 7 : GitHub Pages — Migrer vers `actions/deploy-pages@v4`

### Problem Statement
Le frontend Flutter déployé sur `https://ghoulamedz.github.io/rayhan/` retourne 404. Cause : le workflow build avec `--base-href /` (par défaut), alors que le site est servi sur un sous-chemin `/rayhan/`. Assets chargés depuis `ghoulamedz.github.io/flutter.js` au lieu de `ghoulamedz.github.io/rayhan/flutter.js`. De plus, `peaceiris/actions-gh-pages` nécessite que GitHub Pages soit configuré manuellement sur "Deploy from a branch" dans les settings — un point de fragilité.

### Solution
Migrer vers `actions/deploy-pages@v4` (GitHub Actions comme source Pages) + ajouter `--base-href /rayhan/` + copier `index.html` en `404.html` pour le SPA routing.

### User Stories
1. En tant qu'utilisateur, je veux accéder à `https://ghoulamedz.github.io/rayhan/` et voir l'application, pas une page blanche ou 404.
2. En tant que développeur, je veux que le déploiement Pages fonctionne sans configuration manuelle dans les settings GitHub.

### Implementation Decisions
- Remplacer tout le job par :
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      - run: |
          cd frontend
          flutter pub get
          flutter build web --release --base-href /rayhan/
          cp build/web/index.html build/web/404.html
      - uses: actions/upload-pages-artifact@v3
        with:
          path: ./frontend/build/web
      - id: deployment
        uses: actions/deploy-pages@v4
```
- Le `404.html` copié depuis `index.html` permet au SPA routing de GitHub Pages de fonctionner (quand GitHub sert une page inexistante, il sert `404.html` → Flutter prend le relais)
- Ne PAS toucher au `frontend/Dockerfile` (qui garde `--base-href /` pour nginx)
- Action requise : dans les settings du repo GitHub, changer Pages de "Deploy from a branch" → "GitHub Actions"

### Notes
Le trigger `paths: ['frontend/**']` est conservé. Le workflow ne se déclenchera que pour les changements frontend, ce qui évite des déploiements inutiles.

### Out of Scope
- Déployer un sous-domaine personnalisé (type `rayhan.bolbol.tn`)
- Déploiements staging / preview (pour une prochaine itération)

---

## PRD 8 : Sauvegarde Automatisée de la Base de Données

### Problem Statement
La base MySQL (`rayhan_erp_db`) n'a aucun mécanisme de sauvegarde. Les données de production (articles, commandes, mouvements de stock) peuvent être perdues en cas de corruption, mise à jour ratée, ou erreur humaine.

### Solution
Script de backup via `docker exec mysqldump`, cron pour l'automatisation quotidienne.

### User Stories
1. En tant qu'administrateur, je veux lancer `./scripts/backup-db.sh` pour faire une sauvegarde immédiate.
2. En tant qu'administrateur, je veux une sauvegarde automatique chaque nuit à 3h du matin.
3. En tant qu'administrateur, je veux que les backups soient horodatés pour retrouver une version spécifique.

### Implementation Decisions
- Créer `scripts/backup-db.sh` :
```bash
#!/bin/bash
set -e
BACKUP_DIR="$(dirname "$0")/../backups"
mkdir -p "$BACKUP_DIR"
docker exec rayhan-mysql mysqldump \
  -u root -prayhan_erp_2024 \
  --databases rayhan_erp_db \
  --add-drop-database \
  --routines --triggers \
  > "$BACKUP_DIR/rayhan_$(date +%Y%m%d_%H%M%S).sql"
echo "Backup saved: $BACKUP_DIR/rayhan_$(date +%Y%m%d_%H%M%S).sql"
```
- Rendre exécutable : `chmod +x scripts/backup-db.sh`
- Créer `backups/.gitkeep`
- Pour l'automatisation : ajouter une entrée cron via `crontab -e` :
  ```
  0 3 * * * /home/medo/Desktop/rayhan/scripts/backup-db.sh
  ```
- Les backups sont exclus de git via `backups/*.sql` dans `.gitignore`

### Out of Scope
- Upload vers S3/object storage (backup local uniquement pour l'instant)
- Backup du dossier `assets/` (fichiers uploadés) — à traiter séparément
- Restauration automatisée (procédure manuelle documentée)

---

# Issues

---

## Issue 1 : Supprimer le code mort

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Supprimer les 4 répertoires de code mort dans `frontend/lib/` : `screens/custom/` (12 fichiers), `widgets/custom/` (18 fichiers), `screens/final/` (7 fichiers), `models/mock/` (4 fichiers). Ces fichiers sont annotés `//UNUSED` et totalement inaccessibles depuis `main.dart`. Leur suppression élimine la duplication de modèles de domaine (`Fournisseur`, `ProductionOrder` existent en double).

### Acceptance criteria
- [ ] `git rm -r frontend/lib/screens/custom/ frontend/lib/widgets/custom/ frontend/lib/screens/final/ frontend/lib/models/mock/`
- [ ] `grep -r "models/mock" frontend/lib/` retourne zéro résultat
- [ ] `flutter analyze` zéro erreur
- [ ] `flutter build web --release` réussit

---

## Issue 2 : `--dart-define` pour API_URL et USE_MOCK

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Remplacer les valeurs hardcodées `http://127.0.0.1:8080/api` (dans `api_client.dart`) et `static const bool useMock = true` (dans `mock_config.dart`) par des `String.fromEnvironment()` / `bool.fromEnvironment()` lues depuis `--dart-define`. Valeurs par défaut conservées pour le dev.

### Acceptance criteria
- [ ] `api_client.dart` utilise `const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080/api')`
- [ ] `mock_config.dart` utilise `const bool.fromEnvironment('USE_MOCK', defaultValue: true)`
- [ ] `flutter build web --release --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.rayhan.tn` build sans erreur
- [ ] `AGENTS.md` mis à jour avec les nouvelles commandes

---

## Issue 3 : Ajouter `.dockerignore`

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `backend/.dockerignore` et `frontend/.dockerignore` pour exclure les artefacts de build et fichiers inutiles du contexte Docker. Réduit le temps de build et la taille du contexte envoyé au daemon.

### Acceptance criteria
- [ ] `backend/.dockerignore` exclut : `target/`, `.git/`, `*.md`, `.gitignore`
- [ ] `frontend/.dockerignore` exclut : `build/`, `.dart_tool/`, `.packages`, `.git/`, `*.md`
- [ ] `docker build backend/` et `docker build frontend/` fonctionnent correctement

---

## Issue 4 : Ajouter healthchecks docker-compose

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Ajouter des healthchecks pour les services `backend` et `frontend` dans `docker-compose.yml`. Backend : Spring Actuator `/actuator/health`. Frontend : `nginx -t`. Le service frontend doit dépendre du backend sain.

### Acceptance criteria
- [ ] Service `backend` a un healthcheck : `curl -f http://localhost:8080/actuator/health`
- [ ] Service `frontend` a un healthcheck : `nginx -t`
- [ ] `depends_on` avec `condition: service_healthy` pour les dépendances

---

## Issue 5 : Script de backup DB + cron

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `scripts/backup-db.sh` qui utilise `docker exec mysqldump` pour sauvegarder la base `rayhan_erp_db` dans `backups/` avec un horodatage. Ajouter une entrée cron pour une sauvegarde quotidienne à 3h du matin.

### Acceptance criteria
- [ ] `scripts/backup-db.sh` existe, exécutable, et produit un fichier `.sql` valide
- [ ] `backups/.gitkeep` existe
- [ ] `.gitignore` contient `backups/*.sql`
- [ ] La cron entry `0 3 * * * /home/medo/Desktop/rayhan/scripts/backup-db.sh` est documentée dans le script

---

## Issue 6 : Infrastructure & Déploiement — migrer Pages + unifier docker-compose

**Type** : **HITL** (nécessite action manuelle dans les settings GitHub)
**Blocked by** : Issue 3, Issue 4

### What to build
Deux changements regroupés :
1. **Migrer GitHub Pages** vers `actions/deploy-pages@v4` : remplacer `peaceiris/actions-gh-pages@v3` par `actions/configure-pages@v4` + `actions/upload-pages-artifact@v3` + `actions/deploy-pages@v4`. Ajouter `--base-href /rayhan/` à `flutter build web --release` et copier `index.html` en `404.html` pour le SPA routing.
2. **Unifier docker-compose** en deux fichiers mais propres : `docker-compose.yml` (dev, build local) et `docker-compose.prod.yml` (prod, images GHCR). Utiliser Docker Compose profiles.

### Acceptance criteria
- [ ] Le workflow `deploy-frontend.yml` utilise `actions/deploy-pages@v4` (plus `configure-pages`, `upload-pages-artifact`)
- [ ] Le build utilise `--base-href /rayhan/`
- [ ] `404.html` est copié depuis `index.html` dans le workflow
- [ ] `docker-compose.yml` a les profiles `dev` et `prod`
- [ ] `docker-compose.prod.yml` tire l'image frontend depuis GHCR (pas de build local)
- [ ] Les healthchecks (Issue 4) sont intégrés
- [ ] ~~Action manuelle~~ : dans les settings GitHub, changer Pages de "Deploy from a branch" → "GitHub Actions"

---

## Issue 7 : Extraire `ArticleService`

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `ArticleService` (Spring `@Service`) et y déplacer la logique métier actuellement dans `ArticleController`. Remplacer `articleRepository.findAll().stream().filter(a -> a.getStock() < a.getSeuilAlerte()).toList()` par une dérived query Spring Data (`findByStockLessThanSeuilAlerte()`). Injecter `ArticleService` dans `ArticleController`.

### Acceptance criteria
- [ ] `ArticleService` existe avec les méthodes CRUD et `getArticlesEnAlerte`
- [ ] `ArticleService.getArticlesEnAlerte` utilise `@Query` ou dérived query (pas de stream filter en mémoire)
- [ ] `ArticleController` injecte `ArticleService`, pas `ArticleRepository`
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 8 : Extraire `ClientService`

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `ClientService` (Spring `@Service`) et y déplacer la logique CRUD actuellement dans `ClientController`. Injecter `ClientService` dans `ClientController` à la place de `ClientRepository`.

### Acceptance criteria
- [ ] `ClientService` existe avec les méthodes CRUD
- [ ] `ClientController` injecte `ClientService`, pas `ClientRepository`
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 9 : Extraire `FournisseurService`

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `FournisseurService` (Spring `@Service`) et y déplacer la logique CRUD actuellement dans `FournisseurController`. Injecter `FournisseurService` dans `FournisseurController` à la place de `FournisseurRepository`.

### Acceptance criteria
- [ ] `FournisseurService` existe avec les méthodes CRUD
- [ ] `FournisseurController` injecte `FournisseurService`, pas `FournisseurRepository`
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 10 : Extraire `DashboardService`

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `DashboardService` (Spring `@Service`) et y déplacer les ~51 lignes de calcul KPI (agrégation par mois, statuts, top clients/fournisseurs/articles) actuellement inline dans `DashboardController`. Injecter `DashboardService` dans `DashboardController`.

### Acceptance criteria
- [ ] `DashboardService` existe avec les méthodes de calcul KPI
- [ ] `DashboardController.getKpis()` appelle `DashboardService` et ne contient que la logique HTTP
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 11 : Injection de dépendances dans les providers

**Type** : AFK
**Blocked by** : Issue 2 (`--dart-define`必须先合并, 因为DI系统将使用`USE_MOCK`标志)

### What to build
Remplacer le pattern `if (MockConfig.useMock) ... else ...` dans les 7 providers par injection de dépendances. Les providers acceptent leur service dans le constructeur. Le branching mock/real est fait dans `main.dart` (composition root) via `--dart-define=USE_MOCK`. Extraire le pattern loading/error en une classe de base ou mixin.

### Acceptance criteria
- [ ] `ArticleProvider`, `DashboardProvider`, `VentesProvider`, `AchatsProvider`, `ProductionProvider`, `StockProvider`, `AuthProvider` acceptent leur service via constructeur
- [ ] `main.dart` résout le mock/real switching dans la configuration `MultiProvider`
- [ ] `MockConfig.useMock` n'est plus importé dans les providers (utilise `USE_MOCK` depuis Issue 2)
- [ ] `flutter analyze` zéro erreur
- [ ] `flutter build web --release` réussit en mode mock et real

---

## Issue 12 : Persister les compteurs séquence en DB

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Remplacer `private static int seqCC`, `seqBC`, `seqOF` dans `SalesOrderService` par une table `reference_sequences` en base de données. Incrémentation atomique avec `SELECT ... FOR UPDATE`. Supprimer les champs statiques.

### Acceptance criteria
- [ ] Table `reference_sequences` créée (via `schema.sql` ou `data.sql`)
- [ ] `SalesOrderService` lit et incrémente les compteurs via `SequenceRepository`
- [ ] Les compteurs survivent à un redémarrage du serveur
- [ ] `mvn clean package -DskipTests` réussit

---

## PRD 9 : Architecture — Concurrency, Dead Code & Consolidation

> **Date** : 29 May 2026
> **Source** : Architecture review (skills `improve-codebase-architecture`)
> **Tests** : Aucun — hors scope pour ce cycle

---

### PRD 9.1 : Verrouiller le chemin de déduction de stock

#### Problem Statement
`StockService.sortieStock()` et `SalesOrderService.createSalesOrder()` vérifient le stock suffisant, puis le déduisent — mais sans aucun verrouillage. Deux requêtes concurrentes peuvent lire le même `stockActuel`, le trouver suffisant, et toutes deux déduire. Résultat : stock négatif. La TOCTOU (time-of-check-time-of-use) est ouverte.

#### Solution
Ajouter `@Lock(PESSIMISTIC_WRITE)` sur la requête de lecture de l'article dans `StockService`. La vérification et la déduction se font dans la même transaction verrouillée.

#### User Stories
1. En tant que magasinier, je veux que deux livraisons concurrentes ne puissent pas vendre le même article en double, pour que le stock physique corresponde au stock système.
2. En tant que responsable production, je veux que le lancement d'OF ne puisse pas consommer des matières déjà allouées à une autre commande.

#### Implementation Decisions
- Ajouter une méthode `findByIdWithLock(Long id)` dans `ArticleRepository` avec `@Lock(PESSIMISTIC_WRITE)` et `@Query("SELECT a FROM Article a WHERE a.id = :id")`
- Modifier `StockService.sortieStock()` pour appeler `findByIdWithLock` au lieu de `findById`
- `StockService.entreeStock()` n'a pas besoin de verrouillage (ajout monotone à une colonne, correct même en concurrence)
- La transaction doit englober la lecture ET l'écriture — `@Transactional` déjà présent sur la méthode
- Pas de changement d'interface : les callers (`SalesOrderService`, `PurchaseOrderService`, `ProductionOrderService`) ne changent pas

#### Out of Scope
- Migration vers un système de réservation (inventaire réservé vs disponible) — trop d'impact métier
- Optimistic locking avec `@Version` — plus complexe pour un gain discutable ici (les conflits sont rares mais doivent être évités, pas détectés)

---

### PRD 9.2 : Remplacer `synchronized` par incrémentation atomique DB

#### Problem Statement
`SequenceService.getNextValue()` utilise `synchronized` Java pour la thread-safety, réalisant un cycle read→increment→write non atomique. La méthode `incrementByType()` dans `ReferenceSequenceRepository` est une requête JPQL atomique `UPDATE ... SET lastValue = lastValue + 1` qui effectue l'opération correctement en base — mais elle n'est jamais appelée. `synchronized` ne scale pas horizontalement (multi-instances).

#### Solution
Remplacer le cycle read→increment→write par l'appel à `referenceSequenceRepository.incrementByType()`. Supprimer `synchronized`. Retourner la nouvelle valeur via l'`@Modifying` query.

#### User Stories
1. En tant qu'exploitant, je veux que les séquences de documents restent uniques même avec plusieurs instances backend.
2. En tant que développeur, je veux que le code mort (`incrementByType`) soit soit utilisé, soit supprimé.

#### Implementation Decisions
- Modifier `referenceSequenceRepository.incrementByType()` pour qu'elle retourne la nouvelle valeur (`@Query("UPDATE ReferenceSequence rs SET rs.lastValue = rs.lastValue + 1 WHERE rs.type = :type")` + `@Modifying(clearAutomatically = true, flushAutomatically = true)`)
- Pour récupérer la valeur après l'UPDATE, deux options :
  - Option A : `@Modifying` + re-lecture `findById` (deux requêtes)
  - Option B : `@Query` avec `RETURNING` (nécessite mysql 8.0.21+ avec `@Query("UPDATE ... RETURNING lastValue")` et `@Modifying`)
  - **Choisi** : Option A (compatible avec toutes les versions MySQL, plus lisible)
- `SequenceService.getNextValue(type)` devient non-`synchronized`, sans verrou Java
- La méthode `initDefaultSequences()` reste synchronisée (appelée une fois au démarrage)

#### Out of Scope
- Snowflake / UUID v7 — surkill pour ce volume
- Cache de séquences en mémoire avec allocate-batch pattern (trop complexe)

---

### PRD 9.3 : Supprimer les modules morts

#### Problem Statement
8 artefacts ne sont jamais utilisés mais encombrent le codebase :
- `frontend/lib/providers/notifications_provider.dart` — jamais instancié dans `main.dart`
- `frontend/lib/widgets/kpi_card.dart` — marqué `//UNUSED`
- `frontend/lib/widgets/animated_counter.dart` — marqué `//UNUSED`
- `frontend/lib/services/ai_suggestion_service.dart` — stub qui appelle `SuggestionService.generate()` comme fallback
- `pubspec.yaml` : `cached_network_image`, `flutter_svg`, `shimmer`, `package_info_plus` — importés nulle part
- `backend/.../model/ProductionOrder.java` : valeur d'enum `EN_COURS` jamais set
- `backend/.../security/UserDetailsImpl.isEnabled()` : ignore le champ `User.enabled`
- `backend/.../repository/ReferenceSequenceRepository.incrementByType()` : déjà adressé dans PRD 9.2

#### Solution
Supprimer les fichiers et packages morts. Chaque suppression peut être vérifiée par compilation.

#### User Stories
1. En tant que développeur, je veux que `flutter analyze` et `flutter pub outdated` reflètent l'état réel du projet.
2. En tant que développeur, je veux naviguer dans `lib/providers/` sans tomber sur du code qui n'a aucun effet.

#### Implementation Decisions
- Supprimer : `notifications_provider.dart`, `kpi_card.dart`, `animated_counter.dart`, `ai_suggestion_service.dart`
- Supprimer les 4 packages de `pubspec.yaml` : `cached_network_image`, `flutter_svg`, `shimmer`, `package_info_plus`
- Backend : marquer `EN_COURS` comme `@Deprecated` (ne pas supprimer — pourrait être utilisé par des données en DB)
- Backend : corriger `UserDetailsImpl.isEnabled()` pour lire `User.enabled` (`user.isEnabled()`)
- Vérification : `flutter analyze` zéro erreur, `mvn package -DskipTests` succès

#### Out of Scope
- Refactorer les `//UNUSED` form screens (`SalesOrderFormScreen`, `PurchaseOrderFormScreen`) — traité dans un PRD séparé si pertinent

---

### PRD 9.4 : Découpler le DashboardScreen

#### Problem Statement
`DashboardScreen` (1 073 lignes) cumule 5 responsabilités : orchestration de providers, rendu de 4 types de graphiques, layout KPI, fil d'activité, et cartes de suggestions. Les graphiques utilisent toujours `MockData.revenueByMonth()` et `MockData.ordersByDay()` — même en prod avec `USE_MOCK=false`. Impossible de tester un widget indépendamment.

#### Solution
Extraire 4 widgets : `KpiGrid`, `ChartSection`, `ActivityFeed`, `SuggestionCard`. Router les données des graphiques via le provider au lieu de `MockData`.

#### User Stories
1. En tant qu'utilisateur PDG, je veux voir les vrais chiffres d'affaires dans les graphiques du dashboard, pas des données de démo.
2. En tant que développeur, je veux pouvoir tester le rendu des graphiques sans charger tout le dashboard.

#### Implementation Decisions
- Créer `lib/widgets/dashboard/kpi_grid.dart` : grille responsive des 4 KPI cards (chiffre d'affaires, commandes, stock alertes, OF)
- Créer `lib/widgets/dashboard/chart_section.dart` : conteneur pour `RevenueChart` (line chart) + `OrdersChart` (bar chart), recevant les données en paramètres
- Créer `lib/widgets/dashboard/activity_feed.dart` : liste d'activités récentes
- Créer `lib/widgets/dashboard/suggestion_card.dart` : carte de suggestion individuelle
- `DashboardProvider` expose les données de chart (`revenueByMonth`, `ordersByDay`) chargées depuis `DashboardService.fetchKpis()`
- Supprimer les appels à `MockData.revenueByMonth()` et `MockData.ordersByDay()` dans `DashboardScreen`
- `DashboardScreen` orchestre les 4 widgets et passe les données
- `SuggestionService` reste inchangé (déjà injecté dans `DashboardProvider`)
- **Correction stock d'alerte** : remplacer `stockActuel <= 0` par `stockActuel < stockMinimum` dans le KPI dashboard ET dans `ArticleRepository.findByStockActuelLessThanEqualAndActifTrue` (ou créer une nouvelle derived query `findByStockActuelLessThanStockMinimumAndActifTrue`). Voir `CONTEXT.md` pour la définition du terme.

#### Out of Scope
- Ajouter de nouveaux types de graphiques (camembert, histogramme) — pour une version ultérieure
- Chargement paresseux des KPIs (lazy loading) — pas nécessaire à ce stade

---

### PRD 9.5 : Consolider le pipeline de commandes (transversal)

#### Problem Statement
Les pipelines Sales (ventes) et Purchase (achats) sont des copies structurelles quasi-identiques : 8 fichiers modèle (SalesOrder/PurchaseOrder, SalesOrderLine/PurchaseOrderLine, DeliveryNote/GoodsReceipt, DeliveryNoteLine/GoodsReceiptLine), 2 services, 2 providers, 2 écrans formulaire, 2 écrans détail — ~40% du codebase. La seule différence réelle est les noms, les valeurs d'enum, et `quantiteLivree` vs `quantiteRecue`. Ajouter un nouveau type de document (ex: bon de transfert) nécessite de tout dupliquer.

#### Solution
Introduire des classes de base abstraites `OrderModel<TLine>`, `ReceiptModel<TLine>` côté modèle, `OrderService<TOrder, TLine>` côté service, et `OrderProvider<TOrder>` côté provider. Les implémentations concrètes (SalesOrder, PurchaseOrder) n'ont que leurs enums et règles spécifiques.

#### User Stories
1. En tant que développeur, je veux ajouter un nouveau type de document (ex: bon de transfert inter-dépôt) en créant ~50 lignes de code, pas ~800.
2. En tant que développeur, je veux modifier la gestion des totaux TVA une seule fois, pas dans deux pipelines parallèles.
3. En tant que développeur, je veux pouvoir tester la logique d'arrondi des totaux dans une classe de base, pas dans deux implémentations jumelles.

#### Implémentation Decisions (validated in grill session — see ADR 0001)

**Stratégie d'héritage** : `@MappedSuperclass` (pas `SINGLE_TABLE`, pas `JOINED`). Voir `docs/adr/0001-mappedsuperclass-for-order-pipeline.md`.

**Côté backend (Java)** :
- Créer `OrderBase` (abstract, `@MappedSuperclass`) avec les champs communs : `reference`, `dateCommande`, `notes`, `creePar`, `totalHT`, `totalTVA`, `totalTTC`, `statut`, `@OneToMany List<OrderLineBase> lines`
- `SalesOrder extends OrderBase` : enum `StatutVente`, relation `@OneToMany List<SalesOrderLine> lines`
- `PurchaseOrder extends OrderBase` : enum `StatutAchat`, relation `@OneToMany List<PurchaseOrderLine> lines`
- Créer `OrderLineBase` (`@MappedSuperclass`) : `article`, `quantiteCommandee`, `prixUnitaireHT`, `tauxTVA`, `montantHT`, `montantTTC`
- `SalesOrderLine extends OrderLineBase` : ajoute `quantiteLivree`
- `PurchaseOrderLine extends OrderLineBase` : ajoute `quantiteRecue`
- Même refactoring pour `DeliveryNoteBase` / `GoodsReceiptBase`

**Côté frontend (Dart)** :
- Créer `abstract class OrderModel<TLine extends OrderLineModel>` : `reference`, `dateCommande`, `totalHT`, `totalTVA`, `totalTTC`, `lines`, `statut`, `statutLabel`, `statutColor`
- `class SalesOrderModel extends OrderModel<SalesOrderLineModel>` : enum `StatutVente`, mapping statut→label/color
- `class PurchaseOrderModel extends OrderModel<PurchaseOrderLineModel>` : enum `StatutAchat`, mapping statut→label/color
- Créer `abstract class OrderLineModel` : `article`, `quantiteCommandee`, `prixUnitaireHT`, `tauxTVA`, `montantHT`, `montantTTC`
- Même refactoring pour `abstract class ReceiptModel<TLine extends ReceiptLineModel>`
- Créer `abstract class OrderService<T>` : `fetchAll()`, `create()`, `getById()` — les méthodes spécifiques (`deliver`, `receive`) restent dans les implémentations concrètes

**Bugs intégrés dans le refactoring** :
- **TVA** : le calcul du `totalTVA` de la commande doit sommer les TVA des lignes (champ `tauxTVA` déjà stocké par ligne), pas appliquer 19% forfaitaire.
- **Livraison partielle** : `createDeliveryNote()` / `createGoodsReceipt()` doit set `PARTIELLEMENT_LIVREE` / `PARTIELLEMENT_RECUE` quand `quantiteLivree < quantiteCommandee`, au lieu de toujours mettre `COMPLETEMENT_*`.
- **Stock d'alerte KPI** : le dashboard utilise actuellement `stockActuel <= 0` au lieu de `stockActuel < stockMinimum`. Corrigé dans le cadre du découplage du dashboard (PRD 9.4 / Issue 16).

#### Out of Scope
- Refactorer les écrans de liste (VentesScreen, AchatsScreen) — ils partagent déjà un pattern similaire mais l'abstraction des écrans est prématurée sans troisième type de document
- Migration des données existantes en base (Hibernate `ddl-auto=update` gère la migration de schéma avec `@MappedSuperclass`)

---

### PRD 9.6 : Unifier le wiring des services frontend

#### Problem Statement
`main.dart` contient 9 ternaires `useMock ? MockX() : RealX()` pour instancier les services. `ClientsScreen` et `FournisseursScreen` contournent le Provider et lisent `ClientService` / `FournisseurService` directement via `context.read()`. `VentesProvider` consomme aussi `ClientService`, créant deux chemins d'accès aux données.

#### Solution
Introduire un `ServiceFactory` qui consolide la résolution mock/real en un seul switch. Convertir `ClientsScreen` et `FournisseursScreen` pour passer par un provider dédié.

#### User Stories
1. En tant que développeur, je veux qu'ajouter un nouveau service nécessite une ligne dans `ServiceFactory`, pas un ternary copié-collé dans `main.dart`.
2. En tant que développeur, je veux que tous les écrans accèdent aux données via le même pattern (Provider), pas deux chemins différents.

#### Implementation Decisions
- Créer `lib/services/service_factory.dart` :
```dart
class ServiceFactory {
  static T resolve<T>(T Function() real, T Function() mock) {
    return MockConfig.useMock ? mock() : real();
  }
}
```
- `main.dart` : les lignes `useMock ? MockArticleService() : RealArticleService(ApiClient.dio)` deviennent `ServiceFactory.resolve(() => RealArticleService(ApiClient.dio), () => MockArticleService())`
- Créer `ClientsProvider extends ChangeNotifier` : encapsule `ClientService` (fetchAll, create, update)
- Créer `FournisseursProvider extends ChangeNotifier` : encapsule `FournisseurService` (fetchAll, create, update)
- `ClientsScreen` utilise `context.read<ClientsProvider>()` au lieu de `context.read<ClientService>()`
- `FournisseursScreen` utilise `context.read<FournisseursProvider>()` au lieu de `context.read<FournisseurService>()`
- `VentesProvider.getClients()` : supprimer — remplacer par `ClientsProvider.fetchAll()`

#### Out of Scope
- Service locator global — `ServiceFactory` est statique mais la résolution est explicite

---

## Issues

---

## Issue 13 : Verrouiller le chemin de déduction de stock

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Ajouter `@Lock(PESSIMISTIC_WRITE)` sur la lecture de l'article dans `StockService.sortieStock()`. Créer `ArticleRepository.findByIdWithLock(Long id)`. Modifier `StockService` pour utiliser cette méthode. Vérifier que la transaction couvre lecture + écriture.

### Acceptance criteria
- [ ] `ArticleRepository` expose `findByIdWithLock(Long id)` avec `@Lock(PESSIMISTIC_WRITE)`
- [ ] `StockService.sortieStock()` utilise `findByIdWithLock` au lieu de `findById`
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 14 : Remplacer `synchronized` dans SequenceService

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Remplacer le cycle read→increment→write par un appel à `referenceSequenceRepository.incrementByType()`. Supprimer le mot-clé `synchronized`.

### Acceptance criteria
- [ ] `ReferenceSequenceRepository` a une méthode `@Modifying @Query` qui fait `UPDATE ... SET lastValue = lastValue + 1 WHERE type = :type`
- [ ] `SequenceService.getNextValue(type)` utilise l'UPDATE atomique et relit la valeur après
- [ ] `synchronized` supprimé de `getNextValue`
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 15 : Supprimer les modules morts

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Supprimer les fichiers et packages frontend inutilisés. Corriger `UserDetailsImpl.isEnabled()`.

### Acceptance criteria
- [ ] Fichiers supprimés : `notifications_provider.dart`, `kpi_card.dart`, `animated_counter.dart`, `ai_suggestion_service.dart`
- [ ] Packages retirés de `pubspec.yaml` : `cached_network_image`, `flutter_svg`, `shimmer`, `package_info_plus`
- [ ] `flutter pub get` réussit
- [ ] `flutter analyze` zéro erreur
- [ ] `UserDetailsImpl.isEnabled()` retourne `user.isEnabled()` (backend)
- [ ] `mvn clean package -DskipTests` réussit

---

## Issue 16 : Découpler le DashboardScreen

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Extraire 4 widgets du dashboard monolithique. Router les données des graphiques via le provider.

### Acceptance criteria
- [ ] `KpiGrid`, `ChartSection`, `ActivityFeed`, `SuggestionCard` existent dans `widgets/dashboard/`
- [ ] `DashboardScreen` passe les données du provider aux widgets (n'appelle plus `MockData.revenueByMonth()`)
- [ ] `DashboardProvider` expose revenueByMonth et ordersByDay
- [ ] KPI stock alerte utilise `stockActuel < stockMinimum` au lieu de `stockActuel <= 0`
- [ ] `ArticleRepository` a une derived query `findByStockActuelLessThanStockMinimumAndActifTrue` (ou équivalent)
- [ ] `flutter analyze` zéro erreur
- [ ] `flutter build web --release` réussit

---

## Issue 17 : Consolider le pipeline de commandes

**Type** : **HITL** (refactoring transverse impactant backend + frontend)
**Blocked by** : Issue 13, Issue 14, Issue 15 (cleanups d'abord)

### What to build
Introduire `OrderBase`/`OrderLineBase` (`@MappedSuperclass`) côté backend et `OrderModel<TLine>` côté frontend. Faire hériter SalesOrder/PurchaseOrder des bases. Refactorer les services pour utiliser le type générique.

### Acceptance criteria
- [ ] Backend : `OrderBase`, `OrderLineBase`, `DeliveryNoteBase`, `ReceiptLineBase` créés en `@MappedSuperclass`
- [ ] Backend : `SalesOrder extends OrderBase`, `PurchaseOrder extends OrderBase` (même pour les lignes et reçus)
- [ ] Backend : `SalesOrderService.createSalesOrder()` calcule le totalTVA comme somme des TVA lignes (pas 19% forfaitaire)
- [ ] Backend : `createDeliveryNote()` met `PARTIELLEMENT_LIVREE` si `quantiteLivree < quantiteCommandee` (au lieu de toujours `COMPLETEMENT_LIVREE`)
- [ ] Backend : `createGoodsReceipt()` met `PARTIELLEMENT_RECUE` si `quantiteRecue < quantiteCommandee` (au lieu de toujours `COMPLETEMENT_RECUE`)
- [ ] Frontend : `OrderModel<TLine>`, `OrderLineModel` abstraits créés
- [ ] Frontend : `SalesOrderModel extends OrderModel<SalesOrderLineModel>`
- [ ] Frontend : `PurchaseOrderModel extends OrderModel<PurchaseOrderLineModel>`
- [ ] Frontend : `OrderService<T>` abstrait + implémentations concrètes
- [ ] `flutter analyze` zéro erreur
- [ ] `mvn clean package -DskipTests` réussit
- [ ] Les données existantes en base ne sont pas perdues (Hibernate gère avec `ddl-auto=update`)

---

## Issue 18 : Unifier le wiring des services frontend

**Type** : AFK
**Blocked by** : Issue 15 (suppression modules morts)

### What to build
Créer `ServiceFactory` pour consolider les ternaires mock/real. Créer `ClientsProvider` et `FournisseursProvider`. Convertir les écrans clients/fournisseurs.

### Acceptance criteria
- [ ] `ServiceFactory.resolve<T>(real, mock)` existe
- [ ] `main.dart` utilise `ServiceFactory` pour tous les services
- [ ] `ClientsProvider` existe (ChangeNotifier, injecte ClientService)
- [ ] `FournisseursProvider` existe (ChangeNotifier, injecte FournisseurService)
- [ ] `ClientsScreen` utilise `ClientsProvider` au lieu de `ClientService` direct
- [ ] `FournisseursScreen` utilise `FournisseursProvider` au lieu de `FournisseurService` direct
- [ ] `VentesProvider.getClients()` supprimé (remplacé par `ClientsProvider`)
- [ ] `flutter analyze` zéro erreur

---

## PRD 10 : Correctifs — Logo carré blanc & Export PDF silencieux

> **Date** : 29 May 2026
> **Source** : Signalement utilisateur
> **Tests** : Aucun — hors scope pour ce cycle

---

### PRD 10.1 : Logo icône s'affiche en carré blanc

#### Problem Statement
`rayhan_icon.png` (1024×1024) est un PNG RGB sans canal alpha. Toutes les `Image.asset(…, color: Colors.white)` appliquent `BlendMode.srcIn` par défaut, qui colore chaque pixel en blanc → l'image entière devient un carré blanc opaque, quel que soit le fond.

#### Solution
Supprimer le paramètre `color:` de tous les `Image.asset()` qui chargent `rayhan_icon.png`. L'image s'affiche dans ses couleurs d'origine. C'est une correction purement code, sans outil graphique.

#### User Stories
1. En tant qu'utilisateur, je veux voir l'icône Rayhan dans l'appbar, le drawer et le footer, pas un carré blanc.

#### Implementation Decisions
- 4 endroits à modifier :
  - `brand_app_bar.dart:80` — supprimer `color: AppTheme.kWhite`
  - `app_drawer.dart:42` — supprimer `color: AppTheme.kWhite`
  - `landing_screen.dart:140` — supprimer `color: Color.lerp(Colors.white, AppTheme.kWhite, easedRatio)`
  - `landing_screen.dart:901` — supprimer `color: Colors.white`
- Vérification : `flutter analyze` zéro erreur, inspection visuelle de l'icône
- Note : si l'image a un fond blanc solide sans transparence, il faudra la recadrer/convertir en PNG alpha (hors scope de ce PRD)

#### Out of Scope
- Convertir le PNG en RGBA avec transparence — à faire séparément si le rendu sans `color` ne convient pas

---

### PRD 10.2 : Export PDF ne fait rien

#### Problem Statement
Tous les boutons d'export PDF (rapports, écrans détail commandes/stock/production) ne produisent aucun effet. Cause : `PdfService.init()` / `loadPdfAssets()` n'est jamais appelée. Les variables `late final` des polices (`_interFont`, etc.) ne sont jamais initialisées → `LateInitializationError` au moment de générer le PDF.

#### Solution
Ajouter `await PdfService.init();` dans `main.dart` après `WidgetsFlutterBinding.ensureInitialized()`.

#### User Stories
1. En tant qu'utilisateur, je veux cliquer sur "Exporter en PDF" et télécharger un fichier, pas voir rien se passer.

#### Implementation Decisions
- `PdfService.init()` est une méthode `static Future<void>` qui appelle `loadPdfAssets()` (chargement des polices Inter/Manrope + logo PNG)
- L'appel se fait dans `main()` de `main.dart`, juste après `WidgetsFlutterBinding.ensureInitialized()` et avant `Intl.defaultLocale`
- Vérification : `flutter analyze` zéro erreur, test manuel de chaque bouton PDF (7 emplacements)
- Note : `loadPdfAssets()` a déjà un fallback pour le logo (affiche "R" si pas chargé), mais pas pour les polices — elles sont essentielles

#### Out of Scope
- Migration vers un système d'export PDF sans `dart:html` (pour compatibilité mobile) — pour une version ultérieure

---

## Issues

---

## Issue 19 : Corriger l'affichage du logo (carré blanc)

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Supprimer le paramètre `color:` de tous les `Image.asset('assets/images/rayhan_icon.png', …)` dans le code frontend.

### Acceptance criteria
- [ ] `brand_app_bar.dart` : `color: AppTheme.kWhite` supprimé de l'`Image.asset(rayhan_icon.png)`
- [ ] `app_drawer.dart` : `color: AppTheme.kWhite` supprimé de l'`Image.asset(rayhan_icon.png)`
- [ ] `landing_screen.dart` : `color: Color.lerp(…)` supprimé de l'`Image.asset(rayhan_icon.png)` (appbar)
- [ ] `landing_screen.dart` : `color: Colors.white` supprimé de l'`Image.asset(rayhan_icon.png)` (footer)
- [ ] `flutter analyze` zéro erreur
- [ ] Vérification visuelle : l'icône n'est plus un carré blanc

---

## Issue 20 : Initialiser PdfService au démarrage

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Ajouter `await PdfService.init();` dans `main()` de `main.dart` après `WidgetsFlutterBinding.ensureInitialized()`.

### Acceptance criteria
- [ ] `main.dart` appelle `await PdfService.init();`
- [ ] `flutter analyze` zéro erreur
- [ ] Les 7 boutons PDF (rapports, écrans détail) produisent un téléchargement
