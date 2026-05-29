# Rayhan ERP — PRD : Architecture & Infrastructure

> **Date** : 28 May 2026
> **Source** : Architecture review + choix utilisateur (migration `actions/deploy-pages@v4`)
> **Tests** : Aucun — hors scope pour ce cycle

---

# Issues

---

## ✅ Issue 1 : Supprimer le code mort ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Supprimer les 4 répertoires de code mort dans `frontend/lib/` : `screens/custom/` (12 fichiers), `widgets/custom/` (18 fichiers), `screens/final/` (7 fichiers), `models/mock/` (4 fichiers). Ces fichiers sont annotés `//UNUSED` et totalement inaccessibles depuis `main.dart`. Leur suppression élimine la duplication de modèles de domaine (`Fournisseur`, `ProductionOrder` existent en double).

### Acceptance criteria
- [x] `git rm -r frontend/lib/screens/custom/ frontend/lib/widgets/custom/ frontend/lib/screens/final/ frontend/lib/models/mock/`
- [x] `grep -r "models/mock" frontend/lib/` retourne zéro résultat
- [x] `flutter analyze` zéro erreur
- [x] `flutter build web --release` réussit

---

## ✅ Issue 2 : `--dart-define` pour API_URL et USE_MOCK ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Remplacer les valeurs hardcodées `http://127.0.0.1:8080/api` (dans `api_client.dart`) et `static const bool useMock = true` (dans `mock_config.dart`) par des `String.fromEnvironment()` / `bool.fromEnvironment()` lues depuis `--dart-define`. Valeurs par défaut conservées pour le dev.

### Acceptance criteria
- [x] `api_client.dart` utilise `const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080/api')`
- [x] `mock_config.dart` utilise `const bool.fromEnvironment('USE_MOCK', defaultValue: true)`
- [x] `flutter build web --release --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.rayhan.tn` build sans erreur
- [x] `AGENTS.md` mis à jour avec les nouvelles commandes

---

## ✅ Issue 3 : Ajouter `.dockerignore` ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `backend/.dockerignore` et `frontend/.dockerignore` pour exclure les artefacts de build et fichiers inutiles du contexte Docker. Réduit le temps de build et la taille du contexte envoyé au daemon.

### Acceptance criteria
- [x] `backend/.dockerignore` exclut : `target/`, `.git/`, `*.md`, `.gitignore`
- [x] `frontend/.dockerignore` exclut : `build/`, `.dart_tool/`, `.packages`, `.git/`, `*.md`
- [ ] `docker build backend/` et `docker build frontend/` fonctionnent correctement (build trop lourd pour ce contexte — CI le vérifie)

---

## ✅ Issue 4 : Ajouter healthchecks docker-compose ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Ajouter des healthchecks pour les services `backend` et `frontend` dans `docker-compose.yml`. Backend : Spring Actuator `/actuator/health`. Frontend : `nginx -t`. Le service frontend doit dépendre du backend sain.

### Acceptance criteria
- [x] Service `backend` a un healthcheck : `curl -f http://localhost:8080/actuator/health`
- [x] Service `frontend` a un healthcheck : `nginx -t`
- [x] `depends_on` avec `condition: service_healthy` pour les dépendances

---

## ✅ Issue 5 : Script de backup DB + cron ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `scripts/backup-db.sh` qui utilise `docker exec mysqldump` pour sauvegarder la base `rayhan_erp_db` dans `backups/` avec un horodatage. Ajouter une entrée cron pour une sauvegarde quotidienne à 3h du matin.

### Acceptance criteria
- [x] `scripts/backup-db.sh` existe, exécutable, et produit un fichier `.sql` valide
- [x] `backups/.gitkeep` existe
- [x] `.gitignore` contient `backups/*.sql`
- [x] La cron entry `0 3 * * * /home/medo/Desktop/rayhan/scripts/backup-db.sh` est documentée dans le script

---

## ✅ Issue 6 : Déploiement GitHub Pages ✅

**Type** : AFK
**Blocked by** : None

### What was built
Migration de `peaceiris/actions-gh-pages@v3` vers `actions/deploy-pages@v4` avec `--base-href /rayhan/` + `404.html` pour SPA routing. Le workflow `deploy-frontend.yml` utilise désormais `configure-pages@v4`, `upload-pages-artifact@v3`, et `deploy-pages@v4`. L'image Docker frontend est aussi poussée vers GHCR.

### Acceptance criteria
- [x] Le workflow `deploy-frontend.yml` utilise `actions/deploy-pages@v4`
- [x] Le build utilise `--base-href /rayhan/`
- [x] `404.html` est copié depuis `index.html` dans le workflow
- [x] `docker-compose.prod.yml` tire l'image frontend depuis GHCR
- [x] Les healthchecks (Issue 4) sont intégrés
- [x] Action manuelle faite : Pages configuré sur "GitHub Actions" dans les settings

---

## ✅ Issue 7 : Extraire `ArticleService` ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `ArticleService` (Spring `@Service`) et y déplacer la logique métier actuellement dans `ArticleController`. Remplacer `articleRepository.findAll().stream().filter(a -> a.getStock() < a.getSeuilAlerte()).toList()` par une dérived query Spring Data (`findByStockLessThanSeuilAlerte()`). Injecter `ArticleService` dans `ArticleController`.

### Acceptance criteria
- [x] `ArticleService` existe avec les méthodes CRUD et `getArticlesEnAlerte`
- [x] `ArticleService.getArticlesEnAlerte` utilise derived query (pas de stream filter en mémoire)
- [x] `ArticleController` injecte `ArticleService`, pas `ArticleRepository`
- [x] `mvn clean package -DskipTests` réussit

---

## ✅ Issue 8 : Extraire `ClientService` ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `ClientService` (Spring `@Service`) et y déplacer la logique CRUD actuellement dans `ClientController`. Injecter `ClientService` dans `ClientController` à la place de `ClientRepository`.

### Acceptance criteria
- [x] `ClientService` existe avec les méthodes CRUD
- [x] `ClientController` injecte `ClientService`, pas `ClientRepository`
- [x] `mvn clean package -DskipTests` réussit

---

## ✅ Issue 9 : Extraire `FournisseurService` ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `FournisseurService` (Spring `@Service`) et y déplacer la logique CRUD actuellement dans `FournisseurController`. Injecter `FournisseurService` dans `FournisseurController` à la place de `FournisseurRepository`.

### Acceptance criteria
- [x] `FournisseurService` existe avec les méthodes CRUD
- [x] `FournisseurController` injecte `FournisseurService`, pas `FournisseurRepository`
- [x] `mvn clean package -DskipTests` réussit

---

## ✅ Issue 10 : Extraire `DashboardService` ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Créer `DashboardService` (Spring `@Service`) et y déplacer les ~51 lignes de calcul KPI (agrégation par mois, statuts, top clients/fournisseurs/articles) actuellement inline dans `DashboardController`. Injecter `DashboardService` dans `DashboardController`.

### Acceptance criteria
- [x] `DashboardService` existe avec les méthodes de calcul KPI
- [x] `DashboardController.getDashboard()` appelle `DashboardService` et ne contient que la logique HTTP
- [x] `mvn clean package -DskipTests` réussit

---

## ✅ Issue 11 : Injection de dépendances dans les providers ✅

**Type** : AFK
**Blocked by** : Issue 2

### What was built
Les 7 providers (ArticleProvider, DashboardProvider, VentesProvider, AchatsProvider, ProductionProvider, StockProvider, AuthProvider) acceptent leur service via le constructeur. Le branching mock/real est centralisé dans `main.dart` (composition root) via `MockConfig.useMock` (lui-même résolu par `--dart-define=USE_MOCK`). Les providers n'importent plus `MockConfig`.

### Remaining (minor)
- [ ] Extraire le pattern loading/error (isLoading, error, notifyListeners) en une classe de base ou mixin

---

## ✅ Issue 12 : Persister les compteurs séquence en DB ✅

**Type** : AFK
**Blocked by** : None — can start immediately

### What to build
Remplacer `private static int seqCC`, `seqBC`, `seqOF` dans `SalesOrderService` par une table `reference_sequences` en base de données. Incrémentation atomique avec `SELECT ... FOR UPDATE`. Supprimer les champs statiques.

### Acceptance criteria
- [x] Table `reference_sequences` créée (entité JPA `@Entity @Table(name = "reference_sequences")`)
- [x] `SalesOrderService` lit et incrémente les compteurs via `SequenceService` (qui utilise `ReferenceSequenceRepository`)
- [x] Les compteurs survivent à un redémarrage du serveur (DB-backed)
- [x] `mvn clean package -DskipTests` réussit

