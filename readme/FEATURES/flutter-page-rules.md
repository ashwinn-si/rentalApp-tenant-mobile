# Flutter Page Creation Rules

**Read this entire file before building any new page or screen.**
All rules are mandatory. No exceptions without explicit approval.

---

## 1. Page Scaffold

Every tab-level screen must use `ListPageTemplate` (for list/paginated pages) or
`Scaffold + buildPremiumAppBar` (for detail/form pages).

### List/Paginated pages → `ListPageTemplate`

```dart
ListPageTemplate(
  title: 'Screen Title',
  actions: _refreshAction,       // MANDATORY — see §6
  body: ...,                     // your content
  floatingActionButton: ...,     // if the page has a primary action
)
```

### Detail/Form pages → `Scaffold + buildPremiumAppBar`

```dart
Scaffold(
  appBar: buildPremiumAppBar(
    title: 'Screen Title',
    actions: [
      IconButton(
        onPressed: () => ref.invalidate(myProvider),
        icon: const Icon(Icons.refresh_outlined),
      ),
    ],
  ),
  body: ScreenBackground(child: ...),
)
```

---

## 2. Refresh Button (MANDATORY on every tab page)

Every tab-level screen must have a refresh `IconButton` in the AppBar that
invalidates **only the providers this screen uses**. No auto-refresh on
navigation; the user triggers it.

### Pattern for `ConsumerStatefulWidget`

```dart
List<Widget> get _refreshAction => [
  IconButton(
    onPressed: () {
      ref.invalidate(myPrimaryProvider);
      ref.invalidate(mySecondaryProvider); // only if this page uses it
    },
    icon: const Icon(Icons.refresh_outlined, color: Colors.white),
  ),
];
```

Pass `actions: _refreshAction` to every `ListPageTemplate` call in the
screen — including loading and error states — so the user can always retry.

### Pattern for `ConsumerWidget`

```dart
actions: [
  IconButton(
    onPressed: () => ref.invalidate(myProvider),
    icon: const Icon(Icons.refresh_outlined),
  ),
],
```

---

## 3. Pagination

Any screen with a list of more than a fixed number of items **must** use
`PaginationFooter`. Never implement custom prev/next buttons.

### State

```dart
int _currentPage = 1;           // 1-based, matches backend
static const int _pageSize = 5; // default; adjust per screen
```

### Provider call

```dart
final asyncItems = ref.watch(myProvider((page: _currentPage, limit: _pageSize)));
```

### `PaginationFooter` usage

```dart
PaginationFooter(
  currentPage: _currentPage,
  totalPages: totalPages,                           // from API response
  onPreviousPressed: _currentPage > 1
      ? () => setState(() => _currentPage--)
      : null,
  onNextPressed: _currentPage < totalPages
      ? () => setState(() => _currentPage++)
      : null,
),
```

`PaginationFooter` renders nothing when `totalPages <= 1` — no guard needed.

### Layout rule

Add bottom padding so the last item is never hidden behind the footer:

```dart
padding: EdgeInsets.only(bottom: totalPages > 1 ? 100 : AppSpacing.md),
```

---

## 4. Cards

### Standard content card → `PremiumCard`

Wrap any card-level content in `PremiumCard`. It handles light/dark gradients,
border, and shadow automatically.

```dart
PremiumCard(
  child: MyContent(),
)

// Custom spacing
PremiumCard(
  margin: const EdgeInsets.only(bottom: AppSpacing.md),
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: MyContent(),
)
```

### Custom card (when PremiumCard is not enough)

Follow this exact decoration — no raw `BoxDecoration` without both shadow layers:

```dart
Container(
  margin: const EdgeInsets.only(bottom: AppSpacing.md),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1D1A2B), const Color(0xFF171527)]
          : [Colors.white, Colors.white.withValues(alpha: 0.98)],
    ),
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE5E7EB),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.violet.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: AppColors.violet.withValues(alpha: 0.03),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: MyContent(),
  ),
)
```

---

## 5. Bottom-Sheet Modals

Use `showModalBottomSheet` with a transparent background and a rounded
`Container`. Never use `Dialog` for detail previews — always bottom-sheet.

### Caller

```dart
showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (ctx) => _MySheetContent(...),
);
```

### Sheet content skeleton

```dart
class _MySheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg    = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final handle = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl + MediaQuery.of(context).padding.bottom, // safe area
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── drag handle ──────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── content ──────────────────────────────────────────────────
          MyContent(),
        ],
      ),
    );
  }
}
```

Rules:
- Always include the drag handle (40×4 pill, centered).
- Always add `MediaQuery.of(context).padding.bottom` to bottom padding.
- `mainAxisSize: MainAxisSize.min` — sheet grows to fit content, never full-screen.
- If content might overflow, wrap `Column` in a `DraggableScrollableSheet`.

---

## 6. Action Buttons

### Primary action → `AppButton`

Use for the single most important action on a screen (submit, save, confirm).

```dart
AppButton(
  label: 'Submit',
  onPressed: _isLoading ? null : _handleSubmit,
  isLoading: _isLoading,
  fullWidth: true,           // stretch to container width
)

// Danger variant (e.g. delete)
AppButton(
  label: 'Delete',
  onPressed: _handleDelete,
  backgroundColor: AppColors.pending, // red
  fullWidth: true,
)
```

### Floating action button (FAB)

Use for "add / create" actions on list screens only.

```dart
FloatingActionButton(
  onPressed: () => context.push('/my-route'),
  backgroundColor: AppColors.violet,
  foregroundColor: Colors.white,
  elevation: 4,
  child: const Icon(Icons.add),
)
```

### Destructive confirmation

Always use `ConfirmationDialog.show` before irreversible actions. Never delete
or submit destructively without it.

```dart
final confirmed = await ConfirmationDialog.show(
  context,
  title: 'Delete Item',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  isDangerous: true,
);
if (confirmed && context.mounted) { ... }
```

### Secondary / inline button

For lower-priority actions inside cards or sheets, use a plain `TextButton` or
`OutlinedButton` with violet color — never raw `GestureDetector` for tappable text.

```dart
TextButton(
  onPressed: _handleAction,
  style: TextButton.styleFrom(foregroundColor: AppColors.violet),
  child: const Text('View Details'),
)
```

---

## 7. Empty & Error States

Use `StateCard` — never a raw `Text` for errors or empty messages.

```dart
// Error
StateCard(
  message: 'Failed to load items. Tap refresh to retry.',
  variant: StateCardVariant.error,
)

// Warning
StateCard(
  message: 'No data available for this period.',
  variant: StateCardVariant.warning,
)

// Info / empty
StateCard(
  message: 'Nothing here yet.',
)
```

---

## 8. Dark Mode (non-negotiable)

Every widget must support both light and dark.

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor    = isDark ? const Color(0xFF1F2937) : Colors.white;
final textColor  = isDark ? Colors.white : AppColors.textPrimary;
final subColor   = isDark ? const Color(0xFFD1D5DB) : AppColors.textSecondary;
```

Never hardcode `Colors.white` as a background or `Colors.black` as text.

---

## 9. Animations

Wrap screen content in `StaggeredListView` (for lists) or `FadeSlideTransition`
(for single-widget screens). Never skip entrance animations on new screens.

```dart
// List screens
StaggeredListView(
  children: myItems,
  staggerDuration: const Duration(milliseconds: 50),
)

// Single-widget / form screens
FadeSlideTransition(
  duration: AppAnimations.normal,
  child: MyContent(),
)
```

---

## 10. Screen Registration Checklist

When adding a **new tab screen**, update all four files or the screen will not appear:

| File | What to add |
|------|-------------|
| `lib/core/constants/tenant_screens.dart` | `static const String myScreen = 'my_screen';` |
| `lib/core/router/app_router.dart` | `GoRoute(path: '/my-screen', builder: ...)` |
| `lib/core/router/tab_shell.dart` | Entry in `_allTabs` |
| `lib/core/constants/api_paths.dart` | API path constant |

Full guide: `readme/FEATURES/tenant-screen-guide.md`
