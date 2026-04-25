# Tenant Mobile App — Flutter

## Mandatory Style Guide

Before touching any file, read `../style.md` at repo root.
Use it as the baseline visual contract, then apply package-specific Flutter constraints from this file.

### CRITICAL: Dark Mode Support (MANDATORY)

**ALL UI code must support both light AND dark modes.**

- Always check `Theme.of(context).brightness == Brightness.dark`
- Provide separate colors/styles for dark mode
- Use `withOpacity()` to adjust colors for dark backgrounds
- Dark backgrounds: `#1F2937` (card), `#111827` (deeper areas)
- Light text on dark: use `Colors.white.withOpacity(0.8-0.9)`
- Test every component in both light and dark modes before submitting

Example:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
final textColor = isDark ? Colors.white : AppColors.textPrimary;
```

## Styling & UI Enhancements

### Color System (DO NOT CHANGE)

- **Primary**: `#7C3AED` (Violet) — main UI elements, buttons, appbar
- **Success/Paid**: `#16A34A` (Green) — successful transactions
- **Partial**: `#D97706` (Orange) — partial payments
- **Pending**: `#DC2626` (Red) — unpaid/overdue
- **Background**: `#F5F3FF` (Light Purple) — screen background
- **Card**: `#FFFFFF` (White) — cards, surfaces
- **Text Primary**: `#111827` (Dark Gray) — main text
- **Text Secondary**: `#6B7280` (Medium Gray) — secondary text

### Spacing System (8pt Grid)

```dart
AppSpacing.xs = 4px
AppSpacing.sm = 8px
AppSpacing.md = 16px
AppSpacing.lg = 24px
AppSpacing.xl = 32px
```

### Animations & Transitions

#### Animation Durations

```dart
AppAnimations.fast    = 200ms
AppAnimations.normal  = 300ms
AppAnimations.slow    = 500ms
```

#### Animation Curves

- **easeOutCubic**: For fade-in and scale transitions (smooth deceleration)
- **easeInOutCubic**: For complex animations
- **easeOutExpo**: For scale animations (quick snap-to-position)

#### Reusable Animation Widgets

1. **FadeSlideTransition**: Fade in + slide up

    ```dart
    FadeSlideTransition(
      duration: AppAnimations.normal,
      child: MyWidget(),
    )
    ```

2. **ScaleInAnimation**: Fade in + scale up

    ```dart
    ScaleInAnimation(
      duration: AppAnimations.normal,
      child: MyWidget(),
    )
    ```

3. **StaggeredListView**: Auto-animate list items with stagger
    ```dart
    StaggeredListView(
      children: myItems,
      staggerDuration: Duration(milliseconds: 50),
    )
    ```

### Card Styling Pattern

Always use this pattern for cards:

```dart
Container(
  margin: const EdgeInsets.only(bottom: AppSpacing.md),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.95),
      ],
    ),
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: [
      BoxShadow(
        color: AppColors.violet.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: AppColors.violet.withOpacity(0.03),
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

### Chart Styling Pattern

Charts must include:

- Container with gradient background
- Rounded corners (AppRadius.lg)
- Dual-layer shadow for depth
- Legend for multi-line charts
- Transparent grid lines
- Rounded axis borders

See: `lib/widgets/ui/chart_widgets.dart` for examples.

### Input Field Styling

```dart
InputDecoration(
  labelText: 'Label',
  labelStyle: TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(
      color: AppColors.violet.withOpacity(0.2),
      width: 1,
    ),
  ),
  enabledBorder: /* same as border */,
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: const BorderSide(
      color: AppColors.violet,
      width: 2,
    ),
  ),
  filled: true,
  fillColor: Colors.white,
)
```

### Typography Hierarchy

| Level   | Size | Weight | Color         |
| ------- | ---- | ------ | ------------- |
| H1      | 24   | w800   | textPrimary   |
| H2      | 18   | w800   | textPrimary   |
| H3      | 16   | w700   | textPrimary   |
| Body    | 14   | w500   | textPrimary   |
| Caption | 12   | w400   | textSecondary |

### Shadow Pattern (for depth)

- **Cards**: Light shadow + medium blur (6-12px)

    ```dart
    BoxShadow(
      color: AppColors.violet.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    )
    ```

- **Elevated Elements**: Dual layer shadow

    ```dart
    BoxShadow(color: ..., blurRadius: 12, offset: Offset(0, 2)),
    BoxShadow(color: ..., blurRadius: 24, offset: Offset(0, 8)),
    ```

- **Tooltips/Floating**: Stronger shadow
    ```dart
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    )
    ```

### When to Use Animations

✅ **DO**:

- Entrance animations for screens (fade + slide)
- Staggered animations for lists (50-100ms delay between items)
- Scale animations when showing modals/cards
- Smooth transitions between states
- Subtle hover/press feedback

❌ **DON'T**:

- Animate every single element (causes visual noise)
- Use animations > 500ms (feels laggy)
- Skip animations on page transitions (feels abrupt)
- Use overly complex animations (difficult to follow)

### File Organization

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_tokens.dart      (colors, spacing, theme)
│   │   ├── api_paths.dart       (all API endpoint paths)
│   │   └── tenant_screens.dart  (screen key constants — add new keys here)
│   └── utils/
│       └── animations.dart (reusable animation widgets)
├── widgets/
│   ├── ui/
│   │   ├── chart_widgets.dart (chart components)
│   │   └── ...
│   └── domain/
│       ├── rent_breakdown_card.dart
│       ├── notification_card.dart
│       └── ...
└── features/
    ├── dashboard/
    ├── history/
    └── ...
```

## Screen Visibility

All screens are optional, controlled per client by super admin.
`AuthState.enabledScreens` (from login response) drives which tabs show in `tab_shell.dart`.
`tab_shell.dart` filters `_allTabs` at runtime — only tabs whose `screenKey` is in `enabledScreens` are shown.

**When adding a new screen:** follow `../readme/FEATURES/tenant-screen-guide.md` exactly.
Key files to update when adding a screen:

- `lib/core/constants/tenant_screens.dart` — add key constant
- `lib/core/router/app_router.dart` — add GoRoute
- `lib/core/router/tab_shell.dart` — add entry to `_allTabs`
- `lib/core/constants/api_paths.dart` — add API path
- `lib/features/<screen>/` — create full feature module (data/providers/screens)

## Documentation References

Before implementing features, consult:

- `../readme/CORE/PRD.md` — Product requirements
- `../readme/CORE/implementation_requirements.md` — Frozen architecture decisions
- `../readme/FEATURES/tenant-screen-guide.md` — Screen implementation guide
- `../readme/FEATURES/mobile-activation.md` — Mobile app setup

### Testing UI Changes

1. Test on both light/dark backgrounds
2. Verify touch targets ≥ 44×44pt
3. Check accessibility (contrast ratio ≥ 4.5:1)
4. Test animations on lower-end devices (60fps target)
5. Verify shadows don't clip on edges

### Future Enhancements

- [x] Dark mode support (MANDATORY as of now — all new code must support it)
- [ ] Custom route transitions
- [ ] Gesture feedback (haptic)
- [ ] Loading state animations
- [ ] Empty state illustrations
- [ ] Swipe gestures for navigation
