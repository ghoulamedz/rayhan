# Rayhan ERP — Agent Guide

Two-module ERP for SUARL Rayhan (plastics manufacturing).

## Project structure

```
backend/   — Spring Boot 3.2.5 / Java 17 / Maven
frontend/  — Flutter Web / Dart
scripts/   — Utility scripts (db backup, etc.)
backups/   — MySQL dump output (excluded from git)
```

## Quick start

```bash
# Full stack (Docker Compose)
docker compose up -d --build

# Backend only (dev)
cd backend && ./mvnw spring-boot:run

# Frontend only (dev)
cd frontend && flutter run -d chrome --dart-define=USE_MOCK=true

# Frontend with real API
cd frontend && flutter run -d chrome --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://localhost:8090/api

# Frontend release build
cd frontend && flutter build web --release --dart-define=USE_MOCK=false
```

## Services (docker-compose.yml)

| Service  | Internal port | Mapped port | Healthcheck |
|----------|--------------|-------------|-------------|
| MySQL    | 3306         | —           | mysqladmin ping |
| Backend  | 8080         | 8090        | `/actuator/health` |
| Frontend | 80           | 3013        | `nginx -t` |

## Docker Compose

| File | Use | Frontend image |
|------|-----|----------------|
| `docker-compose.yml` | Dev (build from source) | `build: ./frontend` |
| `docker-compose.prod.yml` | Prod (pull pre-built) | `ghcr.io/ghoulamedz/rayhan-frontend:latest` |

## Backend

- **Base package**: `com.rayhan.erp`
- **Entry point**: `RayhanErpApplication.java` (`main()`)
- **API prefix**: `/api/...`
- **Swagger UI**: `http://localhost:8090/swagger-ui.html`
- **Auth**: JWT in `Authorization: Bearer <token>` header
- **Default admin**: `admin` / `123456` (creates on first boot via `DataInitializer`)
- **Roles**: `ROLE_PDG`, `ROLE_RESPONSABLE_VENTE`, `ROLE_RESPONSABLE_ACHAT`, `ROLE_RESPONSABLE_PRODUCTION`, `ROLE_MAGASINIER`, `ROLE_RH`
- **JPA DDL**: `spring.jpa.hibernate.ddl-auto=update` (Hibernate manages schema)
- **Layered structure**: `controller/` → `service/` → `repository/` → `model/`
- **Build**: `mvn clean package -DskipTests` (no tests exist — `backend/src/test/` is empty)
- **New**: `spring-boot-starter-actuator` added for Docker healthchecks

### Key backend files

| Layer        | Notable files |
|-------------|---------------|
| Config      | `WebSecurityConfig.java` (CORS, JWT filter chain), `DataInitializer.java` (seeds roles + admin), `OpenApiConfig.java` |
| Controllers | `AuthController`, `ArticleController`, `ClientController`, `FournisseurController`, `StockController`, `SalesOrderController`, `PurchaseOrderController`, `ProductionOrderController`, `DashboardController` |
| Services    | `ArticleService`, `ClientService`, `FournisseurService`, `DashboardService`, `StockService`, `SalesOrderService`, `PurchaseOrderService`, `ProductionOrderService`, `SequenceService` |
| Models      | `Article` (types: MP/PSF/PF), `Client`, `Fournisseur`, `SalesOrder`, `PurchaseOrder`, `ProductionOrder`, `BomLine`, `DeliveryNote`, `GoodsReceipt`, `StockMovement`, `User`, `Role`, `Tiers`, `ReferenceSequence` |
| DTOs        | `LoginRequest`, `SignupRequest`, `JwtResponse`, `MessageResponse` |

### Sequence Counters (Issue 12)

Les compteurs `seqCC`, `seqBL`, `seqBC`, `seqBR`, `seqOF` ne sont plus des `static int` en mémoire. Ils sont persistés dans la table `reference_sequences` via `SequenceService`. Plus de reset au redémarrage, thread-safe.

### Environment variables (override `application.properties`)

- `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`
- `RAYHAN_ERP_JWTSECRET`, `RAYHAN_ERP_JWTEXPIRATIONMS`

### CORS origins allowed (in code)

- `https://rayhan-erp.bolbol.tn`, `https://api.bolbol.tn`, `https://*.bolbol.tn`
- `http://localhost:*`, `http://127.0.0.1:*`

## Frontend

- **Entry point**: `lib/main.dart`
- **State management**: `Provider` (7 `ChangeNotifierProvider`s with constructor DI)
- **Routing**: `GoRouter` — JWT-based redirect in `refreshListenable`
- **HTTP**: `Dio` with `_AuthInterceptor` (reads `jwt_token` from `SharedPreferences`)
- **API base URL**: configurable via `--dart-define=API_BASE_URL=<url>`, defaults to `http://127.0.0.1:8080/api`
- **Mock mode**: configurable via `--dart-define=USE_MOCK=true/false`, defaults to `true`
- **Lint**: `flutter analyze` (uses `flutter_lints`)

### Service Architecture (Issue 11)

Chaque service backend a :
- Une **abstract class** (ex: `ArticleService`) définissant le contrat
- Une **implémentation réelle** (ex: `RealArticleService`) appelant l'API via Dio
- Une **implémentation mock** (ex: `MockArticleService`) dans `mock/mock_services.dart`

Les providers reçoivent leur service par **constructor injection**. Le choix mock/real est fait dans `main.dart` (composition root) via `MockConfig.useMock` (qui lit `--dart-define=USE_MOCK`).

### Frontend modules

| Directory    | Contents |
|-------------|----------|
| `screens/`  | Screens (dashboard, articles, ventes, achats, production, stock, detail screens, rapports) |
| `providers/` | 8 providers (auth, dashboard, article, ventes, achats, production, stock, notifications) — constructor DI |
| `services/`  | Abstract classes + `Real*` implementations for each backend controller |
| `mock/`      | `mock_config.dart`, `mock_data.dart`, `mock_services.dart` (instance-based, impl abstract classes) |
| `widgets/`   | Shared widgets (`app_drawer`, `kpi_card`, `professional_dialogs`, etc.) |
| `constants/` | `app_theme.dart` (colors, typography), `app_text.dart`, `custom_page_transition.dart` |

### Routing

```
/login       → LandingScreen
/dashboard   → DashboardScreen (requires auth)
/articles    → ArticlesScreen
/ventes      → VentesScreen
/achats      → AchatsScreen
/production  → ProductionScreen
/stock       → StockScreen
/rapports    → RapportsScreen
```

### Typography

- **Headings**: Manrope (weights 200–800, separate font files)
- **Body/UI**: Inter (regular + italic)
- Font assets must exist under `assets/fonts/`

## CI/CD

### GitHub Pages

- **URL**: `https://ghoulamedz.github.io/rayhan/`
- **Deploy**: `actions/deploy-pages@v4` via `.github/workflows/deploy-frontend.yml`
- **Trigger**: push to `master` with `frontend/**` changes
- **Base href**: `--base-href /rayhan/` + `404.html` copié pour SPA routing
- **Docker image**: Poussée vers `ghcr.io/ghoulamedz/rayhan-frontend:latest` dans le même workflow
- **Settings**: GitHub Pages source must be set to "GitHub Actions" (not "Deploy from a branch")

### Backend Docker

- **Image**: `ghcr.io/ghoulamedz/rayhan-backend:latest` poussée par `.github/workflows/deploy-backend.yml`
- **Trigger**: push to `master` with `backend/**` changes

## Database Backup

- **Script**: `./scripts/backup-db.sh` — utilise `docker exec mysqldump`
- **Output**: `backups/rayhan_YYYYMMDD_HHMMSS.sql`
- **Automation**: ajouter `0 3 * * * /path/to/scripts/backup-db.sh` dans crontab
- Les fichiers `.sql` sont exclus de git via `.gitignore`

## Notable conventions

- **Locale**: French (`fr_FR`, `fr_TN`) — date formatting initialized in `main()`
- **Article types** are plastics-specific: MP (matière première), PSF (produit semi-fini), PF (produit fini)
- **No tests** exist in either module yet
- **review-note.md** at root: PRDs + issues tracker for architecture/infrastructure improvements
