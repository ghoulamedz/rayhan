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
