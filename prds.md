# PRD: Client Portal — Catalogue, Inscription, Commandes & Notifications

## Problem Statement

The Rayhan ERP system manages a plastics manufacturing workflow (MP → PSF → PF) entirely through staff roles (PDG, Responsable Vente, etc.). There is no way for external clients to browse products, register themselves, or submit purchase requests. The existing signup screen is a UI placeholder that never calls the backend. The only sales order entry point is through the Responsable Vente creating orders manually. Clients have no self-service access to the system.

## Solution

Build a client-facing portal inside the same ERP application. Clients sign up publicly, are auto-assigned `ROLE_CLIENT`, and get a dedicated top-bar navigation (no sidebar/drawer) with Catalogue, Mes commandes, and Mon profil. The catalogue shows only Produits Finis (PF) as a marketing grid. Clients can build multi-line orders, export a PDF devis (quote), and submit. Orders start `EN_ATTENTE` — the Responsable Vente reviews them in a new tab on the Ventes screen, re-checks stock, and approves or rejects. Status changes are pushed to the client via a polling-based in-app notification system.

## User Stories

1. As a prospective client, I want to browse the product catalogue without logging in, so that I can see what products are available.
2. As a prospective client, I want to see product details (image, price, description) when I tap a product card, so that I can evaluate the product.
3. As a prospective client, I want to sign up with my name, email, and password, so that I can create an account and place orders.
4. As a new client, I want to be automatically logged in after signup, so that I can immediately start using the portal without an extra login step.
5. As an authenticated client, I want to build a multi-line order (add several products with quantities), so that I can order everything I need in one request.
6. As a client placing an order, I want to export a PDF devis (quote) before submitting, so that I can review or print it.
7. As a client, I want to see my past orders in a "Mes commandes" list, so that I can track what I've ordered.
8. As a client, I want to see the status timeline of each order (EN_ATTENTE → CONFIRMÉE → EN_PRÉPARATION → LIVRÉE), so that I know where my order stands.
9. As a client, I want to cancel an order while it is still EN_ATTENTE, so that I can correct mistakes before the RV processes it.
10. As a client, I want to re-order from a previous order (duplicate its articles into the order form), so that I don't have to re-select everything.
11. As a client, I want to receive an in-app notification when my order status changes, so that I don't have to keep checking manually.
12. As a client, I want to edit my profile (phone, address, city), so that my contact details are up to date.
13. As the Responsable Vente, I want to see all EN_ATTENTE orders in a dedicated tab on the Ventes screen, so that I can review incoming requests.
14. As the Responsable Vente, I want to approve an EN_ATTENTE order with automatic stock re-check, so that I only confirm orders where stock is sufficient.
15. As the Responsable Vente, I want to reject an EN_ATTENTE order, so that I can decline invalid or problematic requests.
16. As the Responsable Vente, I want to be notified when a new EN_ATTENTE order arrives, so that I don't miss client requests.
17. As the PDG, I want to see and manage articles (CRUD) on a business screen separate from the public catalogue, so that I control pricing, stock thresholds, and product images.
18. As the PDG, I want to assign a local asset image to each article, so that the catalogue displays product photos.
19. As a staff member, I want the existing business screens (Articles, Ventes, Achats, etc.) unchanged with the sidebar drawer, so that my workflow is not disrupted by the client portal.

## Implementation Decisions

### Route Architecture
- `/articles` — PDG-only business screen for article CRUD (unchanged, side drawer)
- `/catalogue` — public product catalog (PF only, no auth required)
- `/catalogue/:id` — product detail page (public)
- `/catalogue/commander` — multi-line order form (requires auth; unauthenticated users are redirected to `/signup`)
- `/mes-commandes` — client's order history (ROLE_CLIENT)
- `/mes-commandes/:id` — order detail with status timeline (ROLE_CLIENT)
- `/mon-profil` — client profile editor (ROLE_CLIENT)

### New Status: EN_ATTENTE
A new `EN_ATTENTE` value is added to the `StatutCommande` enum (nested in `SalesOrder`), ordered before `CONFIRMEE`. This is the initial status for client-submitted orders. Staff-created orders still go directly to `CONFIRMEE`.

### Signup & Auto-Login
- Public `POST /api/auth/signup` accepts `firstName`, `lastName`, `email`, `username`, `password` (no role input)
- Backend creates a minimal `Client` entity (`raisonSociale = firstName + " " + lastName`, email copied)
- User is created with only `ROLE_CLIENT` (staff roles are blocked from public signup)
- After saving, the backend authenticates the user and returns a `JwtResponse` with token
- Frontend saves the token and navigates to `/catalogue`

### Client Entity Auto-Creation
- `Client` inherits from `Tiers` (shared with Fournisseur)
- Signup creates `Client` with `raisonSociale`, `email` only — phone, address, ville are null
- Missing fields are editable via "Mon profil" screen (phone, address, ville)
- `User.client` is set via `@OneToOne` relationship

### Public Catalog Endpoint
- `GET /api/public/articles` — no auth, returns only PF articles where `actif = true`
- `GET /api/public/articles/{id}` — no auth, returns single PF article
- Protected via `.requestMatchers("/api/public/**").permitAll()` in WebSecurityConfig
- Existing `GET /api/articles` stays PDG-only

### Client Order Flow
- `POST /api/sales-orders/client` (ROLE_CLIENT) — creates EN_ATTENTE order, sets client from authenticated user's linked Client, generates reference via `SequenceService`, calculates totals (HT/TVA/TTC), does NOT check stock
- `GET /api/sales-orders/client/mine` (ROLE_CLIENT) — returns orders filtered by client ID, ordered by date desc
- `PUT /api/sales-orders/client/{id}/cancel` (ROLE_CLIENT) — cancels only if status is EN_ATTENTE and order belongs to the authenticated client
- `GET /api/sales-orders/pending` (ROLE_PDG, ROLE_RESPONSABLE_VENTE) — returns all EN_ATTENTE orders
- `PUT /api/sales-orders/{id}/approve` (ROLE_PDG, ROLE_RESPONSABLE_VENTE) — re-checks stock for every line, fails with a message listing the short articles if insufficient; on success sets CONFIRMEE and notifies the client
- `PUT /api/sales-orders/{id}/reject` (ROLE_PDG, ROLE_RESPONSABLE_VENTE) — sets ANNULEE and notifies the client

### Order Form
- Simplified multi-line form at `/catalogue/commander`
- No price editing (prices are read-only from the article catalog)
- Article searchable dropdown (filters PF articles from CatalogProvider)
- Quantity input, auto-calculated line totals, HT/TVA/TTC totals
- Notes field and delivery date picker (optional)
- "Exporter Devis (PDF)" button generates a quote document (same layout as invoice but titled "Devis")
- "Soumettre la commande" button posts to the backend
- On success → navigates to `/mes-commandes`

### Client Navigation (ClientScaffold)
- Replaces `AppDrawer` for ROLE_CLIENT
- Top bar with logo, "Catalogue" link, "Mes commandes" link, notification bell with badge count, profile icon, logout
- Active link highlighted in amber (based on `currentRoute`)
- Wraps all client-facing screens

### Notification System
- `Notification` entity: id, user (ManyToOne), type (ORDER_STATUS_CHANGED, NEW_ORDER_PENDING), referenceId (order ID), message, read flag, createdAt
- `NotificationService` with: create(), getUnread(), getUnreadCount(), getAll(), markAsRead(), markAllAsRead(), notifyStaff() (batch-creates for all users with a given role)
- On client order creation → notification sent to all ROLE_RESPONSABLE_VENTE and ROLE_PDG
- On approve → notification sent to the order's client user
- On reject → notification sent to the order's client user
- Frontend: `NotificationProvider` polls `GET /api/notifications/unread-count` every 30 seconds + on mount
- Badge count shown in ClientScaffold notification bell

### Article Images
- Article model has an `assetImage` string field (local Flutter asset path, e.g. `products/chair.png`)
- Not used for image upload — PDG selects from predefined asset images in the article form
- Catalogue uses `Image.asset('assets/images/products/${article.assetImage}')` with a placeholder fallback
- Image included in Article CRUD (PDG screen)

### RV Approval Tab
- VentesScreen gets a `TabBar` with "Toutes" and "En attente" tabs
- "En attente" tab filters orders where `statut === 'EN_ATTENTE'`
- Each pending order shows Approve (green) and Reject (red outlined) buttons
- Approve calls `PUT /api/sales-orders/{id}/approve` — on failure (insufficient stock), shows error snackbar with details
- Reject calls `PUT /api/sales-orders/{id}/reject`

### RoleGuard Updates
- `getDefaultRoute('ROLE_CLIENT')` → `/catalogue`
- `AppDrawer` returns `SizedBox.shrink()` for ROLE_CLIENT
- `/catalogue*` routes are public (no auth needed)
- `/mes-commandes*`, `/mon-profil` routes require ROLE_CLIENT

### PDF Devis
- `PdfService.generateDevis(SalesOrder)` — same structure as `generateSalesInvoice` but titled "Devis", reference prefix "DEV-001"
- Generated client-side from the order form data before submission
- Uses existing `PdfBrandedHeader`, `PdfLineItemTable`, `PdfTotalsBox`, `PdfFooter` from `pdf_templates.dart`

## Testing Decisions

No tests exist in either module (backend `src/test/` is empty, frontend has no test directory). Testing is deferred — the project has no established test framework, runner, or conventions. When tests are introduced, they should:

- Test backend services (SalesOrderService, NotificationService, AuthController.signup) in isolation with mocked repositories
- Test frontend providers (CatalogProvider, ClientOrderProvider) with mocked services
- Not test screens/widgets until a widget test pattern is established

## Out of Scope

- Fournisseur portal (ROLE_FOURNISSEUR) — same pattern could be applied later
- Email notifications (SMTP relay) — only in-app notifications for now
- Image upload to backend — images are static Flutter assets
- Shopping cart (panier) — orders go directly to the multi-line form
- Password reset / forgot-password flow
- Admin dashboard for client analytics
- Pagination for order lists or catalogue (all results loaded at once)
- Partial stock check on approve (if insufficient stock for some lines, the entire approve is rejected)

## Further Notes

- The backend uses `spring.jpa.hibernate.ddl-auto=update` — new columns (`asset_image`, `notifications` table) are auto-created
- The frontend runs `flutter analyze` for linting (no `--fatal-infos` flag used)
- Default admin credentials remain `admin` / `123456`
- Mock services exist for development without a running backend; the new mock services (MockCatalogService, MockClientOrderService, MockNotificationService) return empty/static data
