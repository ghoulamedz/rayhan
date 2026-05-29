# Rayhan ERP — Agent Guide

Two-module ERP for SUARL Rayhan (plastics manufacturing).

## Project structure

```
backend/   — Spring Boot 3.2.5 / Java 17 / Maven
frontend/  — Flutter Web / Dart
```

## Quick start

```bash
# Full stack (Docker Compose)
docker compose up -d --build

# Backend only (dev)
cd backend && ./mvnw spring-boot:run

# Frontend only (dev)
cd frontend && flutter run -d chrome
```

## Services (docker-compose.yml)

| Service  | Internal port | Mapped port |
|----------|--------------|-------------|
| MySQL    | 3306         | —           |
| Backend  | 8080         | 8090        |
| Frontend | 80           | 3013        |

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

### Key backend files

| Layer        | Notable files |
|-------------|---------------|
| Config      | `WebSecurityConfig.java` (CORS, JWT filter chain), `DataInitializer.java` (seeds roles + admin), `OpenApiConfig.java` |
| Controllers | `AuthController`, `ArticleController`, `ClientController`, `FournisseurController`, `StockController`, `SalesOrderController`, `PurchaseOrderController`, `ProductionOrderController`, `DashboardController` |
| Models      | `Article` (types: MP/PSF/PF), `Client`, `Fournisseur`, `SalesOrder`, `PurchaseOrder`, `ProductionOrder`, `BomLine`, `DeliveryNote`, `GoodsReceipt`, `StockMovement`, `User`, `Role`, `Tiers` |
| DTOs        | `LoginRequest`, `SignupRequest`, `JwtResponse`, `MessageResponse` |

### Environment variables (override `application.properties`)

- `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`
- `RAYHAN_ERP_JWTSECRET`, `RAYHAN_ERP_JWTEXPIRATIONMS`

### CORS origins allowed (in code)

- `https://rayhan-erp.bolbol.tn`, `https://api.bolbol.tn`, `https://*.bolbol.tn`
- `http://localhost:*`, `http://127.0.0.1:*`

## Frontend

- **Entry point**: `lib/main.dart`
- **State management**: `Provider` (7 `ChangeNotifierProvider`s)
- **Routing**: `GoRouter` — JWT-based redirect in `refreshListenable`
- **HTTP**: `Dio` with `_AuthInterceptor` (reads `jwt_token` from `SharedPreferences`)
- **API base URL**: configurable via `--dart-define=API_BASE_URL` (default: `http://127.0.0.1:8080/api`) in `lib/services/api_client.dart`
- **Dev**: `flutter run -d chrome` (Flutter Web), also `flutter build web --release`
- **Lint**: `flutter analyze` (uses `flutter_lints`)

### Frontend modules

| Directory    | Contents |
|-------------|----------|
| `screens/`  | 17 screens (dashboard, articles, ventes, achats, production, stock, forms/detail screens) |
| `providers/` | 7 providers (auth, dashboard, article, ventes, achats, production, stock) |
| `services/`  | 10 service classes matching backend controllers |
| `widgets/`   | Shared widgets (`app_drawer`, `gradient_card`, `role_guard`, `app_dialogs`) |
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
```

### Typography

- **Headings**: Manrope (weights 200–800, separate font files)
- **Body/UI**: Inter (regular + italic)
- Font assets must exist under `assets/fonts/`

## Notable conventions

- **Locale**: French (`fr_FR`, `fr_TN`) — date formatting initialized in `main()`
- **Article types** are plastics-specific: MP (matière première), PSF (produit semi-fini), PF (produit fini)
- **No tests** exist in either module yet
- **Swagger doc** says default password is `Rayhan2024!` but `DataInitializer.java` uses `123456` — trust the code
- **CORS** is restrictive in production (only `*.bolbol.tn`), permissive for localhost dev
