# Tenant Mobile App — RentalFlow

Cross-platform Flutter app (iOS + Android) for tenants. Feature-equivalent to the tenant web portal with native mobile UX — push notifications (FCM), dark mode, and smooth animations.

---

## Tech Stack

| Concern        | Choice                                      |
| -------------- | ------------------------------------------- |
| Language       | Dart                                        |
| Framework      | Flutter (latest stable)                     |
| State mgmt     | Riverpod (flutter_riverpod)                 |
| Navigation     | go_router                                   |
| HTTP           | Dio (via DioClient singleton)               |
| Storage        | flutter_secure_storage (token)              |
| Push notifs    | Firebase Cloud Messaging (FCM)              |

---

## Getting Started

```bash
cd tenant-mobile
flutter pub get
flutter run           # connects to running device/emulator
flutter run -v        # verbose (shows all HTTP traffic)
flutter build apk --release
flutter build ios --release
```

Edit `lib/core/constants/env_config.dart` to point at your backend URL.

---

## Folder Structure

```
tenant-mobile/lib/
├── main.dart               App entry — Firebase init, ProviderScope, runApp
├── app.dart                MaterialApp.router setup (GoRouter + theme)
├── firebase_options.dart   Firebase project config (generated — do not edit manually)
├── core/
│   ├── constants/
│   │   ├── app_tokens.dart     Colors, spacing (8pt grid), typography — DO NOT change values
│   │   ├── api_paths.dart      All API endpoint paths — add new endpoints here
│   │   ├── tenant_screens.dart Screen key constants — add new screen keys here
│   │   ├── constants.dart      App version, base URLs
│   │   └── env_config.dart     Dev vs. prod base URL switching
│   ├── network/
│   │   ├── dio_client.dart     Singleton HTTP client — handles auth header, 401/403 logout
│   │   └── api_response.dart   Generic typed response wrapper (ApiResponse<T>)
│   ├── router/
│   │   ├── app_router.dart     All GoRouter route definitions + redirect guards
│   │   └── tab_shell.dart      Bottom nav — renders only enabled screen tabs
│   ├── storage/
│   │   └── secure_storage.dart Token read/write/delete (flutter_secure_storage)
│   └── utils/
│       └── animations.dart     FadeSlideTransition, StaggeredListView, ScaleInAnimation
├── services/
│   └── fcm_service.dart        FCM token registration + notification handler
├── widgets/
│   ├── ui/                     App-wide reusable widgets — always use these, never recreate
│   │   ├── app_button.dart         Gradient primary button
│   │   ├── app_loader.dart         Ripple loading animation
│   │   ├── app_toast.dart          SnackBar service
│   │   ├── app_modal.dart          Dialog helper
│   │   ├── app_bottom_sheet.dart   Bottom sheet helper
│   │   ├── status_chip.dart        Paid/Partial/Pending chips
│   │   ├── info_field.dart         Label + value display row
│   │   ├── empty_state_card.dart   Empty/error state — use for ALL empty states
│   │   ├── state_card.dart         Generic state display
│   │   ├── skeleton_card.dart      Loading skeleton placeholder
│   │   ├── flat_selector.dart      Multi-flat switcher
│   │   ├── rent_breakdown_card.dart Rent detail breakdown card
│   │   └── notification_card.dart  Notification list item
│   └── domain/                 Feature-specific widgets
└── features/                   One folder per screen/feature
    ├── auth/
    │   ├── providers/          auth_provider.dart — login, logout, session restore
    │   ├── data/               Login model + API call
    │   └── screens/            login_screen.dart, change_password_screen.dart
    ├── splash/                 SplashScreen — session restore + version check + routing
    ├── dashboard/              Current rent due card + maintenance breakdown
    ├── history/                Paginated month-wise rent history
    ├── notifications/          In-app notification list
    ├── documents/              Document viewer (S3 pre-signed URLs)
    ├── flat_details/           Flat specs and tenancy information
    ├── maintenance_issues/     Report and track maintenance issues
    ├── payment_proof/          Upload payment proof
    ├── profile/                Read-only tenant profile
    ├── alerts/                 System alerts
    ├── app_version/            Version check + force update flow
    ├── bug_reports/            In-app bug report submission
    └── settings/               App settings (theme toggle, logout)
```

---

## How to Read the Code — Entry Points

**App startup:**

1. `main.dart` → Firebase init → `runApp(ProviderScope(child: App()))`
2. `app.dart` → `MaterialApp.router` with GoRouter from `core/router/app_router.dart`
3. `features/splash/splash_screen.dart` → restores session from secure storage, runs version check in parallel with animation, then routes:
   - Token + no forced password change → `firstAvailablePath(enabledScreens)`
   - Token + `mustChangePassword` → `/change-password`
   - No token → `/login`

**Tracing a screen:**

1. Find route in `app_router.dart` (e.g., `/dashboard`)
2. `features/dashboard/screens/dashboard_screen.dart`
3. Screen watches Riverpod provider from `features/dashboard/providers/`
4. Provider calls data class in `features/dashboard/data/` via `DioClient`
5. Endpoint path from `core/constants/api_paths.dart` → backend `modules/tenant-mobile/`

**Tracing an API call:**

```dart
final response = await DioClient.instance.get<RentCardsResponse>(
  ApiPaths.dashboardCurrent,
  fromJson: (json) => RentCardsResponse.fromJson(json as Map<String, dynamic>),
);
```

`DioClient` automatically attaches `Authorization: Bearer <token>` from secure storage. On 401 or inactive-client 403, it fires `onUnauthorized` callback → `AuthNotifier.handleAccessDenied()` → clears session → GoRouter redirects to `/login`.

**Auth 401 vs 403 distinction:**

- **401** (token expired) → always logout
- **403 account disabled** → always logout  
- **403 screen disabled** (message contains `"Screen '"` or `"not enabled"`) → passes through as `ApiResponse.failure` — screen shows its own error state, no logout

---

## Key Concepts

### Screen Visibility (enabledScreens)

Screens are per-client optional. Super admin enables/disables them. Login response returns `enabledScreens: List<String>`. `auth_provider.dart` stores these. `tab_shell.dart` filters `_allTabs` to only render tabs whose `screenKey` is in `enabledScreens`. `app_router.dart` re-checks on every navigation.

### Dashboard vs. History Data Models — Keep Separate

Dashboard and History have **separate** endpoints and separate data models. Do not share them:

| | Dashboard | History |
|---|---|---|
| Filter | Last 3 months, unpaid/partial | Date range, paginated |
| Model location | `features/dashboard/data/models/rent_cards_response.dart` | `features/history/data/models/history_response.dart` |
| Purpose | Quick status view | Detailed audit trail |

### App-Version Check Deduplication

`checkForAppUpdate()` is called from both splash and dashboard. A module-level `_versionCheckedThisSession` flag ensures the network call fires only once per process lifetime.

### Theme System — Do Not Change Token Values

All colors, spacing, and typography live in `core/constants/app_tokens.dart`. Use only these tokens:

| Token              | Value    | Use                      |
| ------------------ | -------- | ------------------------ |
| `AppColors.violet` | #7C3AED  | Primary buttons, app bar |
| `AppColors.paid`   | #16A34A  | Paid status              |
| `AppColors.partial`| #D97706  | Partial payment          |
| `AppColors.pending`| #DC2626  | Unpaid/overdue           |
| `AppSpacing.md`    | 16px     | Default padding          |

### Dark Mode (Mandatory)

All screens must support light and dark mode. Pattern:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
final textColor = isDark ? Colors.white : AppColors.textPrimary;
```

Never hardcode colors in widgets. Test every screen in both modes.

### Empty States

Use `EmptyStateCard` for all empty/error states. Never create custom empty state UI:

```dart
EmptyStateCard(
  type: EmptyStateType.history,  // or maintenance, documents, notifications, etc.
  actionLabel: 'Retry',
  onActionPressed: () => ref.invalidate(myProvider),
)
```

### Card Styling

Use the project's standard card `BoxDecoration` (gradient + rounded + dual shadow). See existing cards in `widgets/domain/` for the exact pattern. Do not write one-off card styles.

---

## Adding a New Screen

Follow `readme/FEATURES/tenant-screen-guide.md` exactly. Quick checklist:

1. Add screen key to `lib/core/constants/tenant_screens.dart`
2. Add API path to `lib/core/constants/api_paths.dart`
3. Create `lib/features/{feature}/` with `providers/`, `data/`, `screens/`
4. Register `GoRoute` in `app_router.dart` + add to `screenPaths` map
5. Add tab entry in `tab_shell.dart` with matching screen key and branch index
6. Backend: add feature in `backend/src/modules/tenant-mobile/{feature}/`
7. Enable screen for demo client via super admin portal to test visibility gating
8. Test: dark mode ✓, light mode ✓, tab hidden when screen not in `enabledScreens` ✓

---

## Common Gotchas

- Do not hardcode colors or spacing — always use `AppTokens` constants.
- Do not call `DioClient` from inside widget `build()` — call from providers.
- Do not use `setState` for API data — Riverpod providers only.
- Do not forget dark mode on every new widget.
- Dashboard and history models are separate — do not merge or share them.
- FCM token is sent to backend on login — do not skip when adding auth flows.
