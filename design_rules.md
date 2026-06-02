# Tenant Mobile App Design Rules

Reference documentation for consistent UI/UX design across all screens. **All new pages MUST follow these rules.**

## Color System

### Primary Colors
- **Violet (Primary)**: `Color(0xFF5D3FD3)` = `AppColors.violet`
  - Used for: app bars, primary buttons, links, accents
  - Dark variant: `Color(0xFF4B32A8)` = `AppColors.violetDark`

### Status Colors
- **Paid/Success (Green/Emerald)**: `Color(0xFF10B981)` = `AppColors.emerald` / `AppColors.paid`
  - Used for: paid rent badges, success messages
- **Partial (Orange)**: `Color(0xFFD97706)` = `AppColors.orange`
  - Used for: partial payment indicators
- **Pending/Overdue (Red)**: `Color(0xFFEF4444)` = `AppColors.red`
  - Used for: unpaid/overdue warnings, error states
- **Warning/Pending (Amber)**: `Color(0xFFF59E0B)` = `AppColors.pending`
  - Used for: pending status badges

### Text Colors
- **Primary Text**: `Color(0xFF111827)` = `AppColors.textPrimary`
  - Used for: main headings, body copy
- **Secondary Text**: `Color(0xFF6B7280)` = `AppColors.textSecondary`
  - Used for: labels, helper text, metadata

### Background Colors
- **Screen Background (Light)**: `Color(0xFFF8F9FA)` = `AppColors.screenBg`
- **Card Background (Light)**: `Color(0xFFFFFFFF)` = `Colors.white`
- **Screen Background (Dark)**: `Color(0xFF100E1A)`
- **Card Background (Dark)**: `Color(0xFF171527)`

## Typography System

### Font Family
**Always use GoogleFonts.sora** (applied via `Theme.of(context).textTheme`). Never specify `fontFamily` inline.

### Text Styles — Use Theme TextTheme
Always use `Theme.of(context).textTheme.X` instead of raw `TextStyle()`. Design system defines 5 levels:

| Level | Size | Weight | Color | Usage |
|-------|------|--------|-------|-------|
| **headlineLarge** (H1) | 24px | w800 | textPrimary | Page titles, major headings |
| **headlineMedium** (H2) | 18px | w700 | textPrimary | Section headers, modal titles |
| **titleMedium** (H3) | 16px | w600 | textPrimary | Card titles, bold labels |
| **bodyMedium** | 14px | w500 | textPrimary | Main body copy, standard text |
| **bodySmall** | 12px | w400 | textSecondary | Labels, captions, helper text |

### Weight Mappings
❌ **NEVER**: Use `FontWeight.bold`, `FontWeight.w900`, or off-scale weights
✅ **DO**: Use exact values:
- w400 (regular) = `bodySmall` default
- w500 (medium) = `bodyMedium` default
- w600 (semi-bold) = `titleMedium` default
- w700 (bold) = `headlineMedium` default, emphasis text
- w800 (extra-bold) = `headlineLarge` default

Example:
```dart
// ❌ Wrong
Text('Hello', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))

// ✅ Correct
Text('Hello', style: Theme.of(context).textTheme.titleMedium)

// ✅ Correct with custom color
Text('Hello', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  color: AppColors.violet,
))
```

## Spacing System (8px Grid)

All spacing uses 8px increments via `AppSpacing`:

| Token | Size | Usage |
|-------|------|-------|
| `xs` | 4px | Minimal gaps (line height adjustments) |
| `sm` | 8px | Tight spacing (between inline elements) |
| `md` | 16px | Standard spacing (sections, cards) |
| `lg` | 24px | Large gaps (between major sections) |
| `xl` | 32px | Extra large (page padding) |

## Border Radius System

Use `AppRadius` tokens:

| Token | Size | Usage |
|-------|------|-------|
| `sm` | 8px | Small elements (chips, buttons) |
| `md` | 12px | Input fields, small cards |
| `lg` | 16px | Cards, containers, modals |

## Dark Mode (MANDATORY)

Every screen MUST support both light and dark modes. All color choices must be responsive to theme.

### Required Pattern
```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
  final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.textPrimary;
  final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.violet.withValues(alpha: 0.12);
  
  return Container(
    color: cardBg,
    child: Text('Content', style: TextStyle(color: textColor)),
  );
}
```

**Never hardcode `Colors.white`, `Colors.black`, or hex colors for light-mode-only text/bg.** All colors must adapt.

### Dark Mode Colors
- Card backgrounds: `0xFF171527`
- Page backgrounds: `0xFF100E1A`
- Light text on dark: `Colors.white.withValues(alpha: 0.85-0.9)`
- Borders on dark: `Colors.white.withValues(alpha: 0.08-0.1)`

## Card Styling Pattern

Use `PremiumCard` widget OR follow this exact decoration pattern:

```dart
Container(
  margin: const EdgeInsets.only(bottom: AppSpacing.md),
  decoration: BoxDecoration(
    color: cardBg,  // Dark-mode aware
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(
      color: borderColor,  // Dark-mode aware
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.violet.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: YourContent(),
  ),
)
```

**Never use `Colors.grey.shade50/100/200/...` for card styling** — use AppColors or the dark-mode-aware color variables defined at the top of build().

## Input Field Styling

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint...',
    filled: true,
    fillColor: fillColor,  // Dark-mode aware
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.violet, width: 2),
    ),
  ),
)
```

## Anti-Patterns (DO NOT DO)

### Typography
- ❌ `FontWeight.bold` — use `w700` or `w800`
- ❌ `FontWeight.w900` — max is `w800`
- ❌ `fontSize: 11, 13, 15, 20, 28` — snap to: 12, 14, 16, 18, 24
- ❌ `textTheme.labelSmall`, `headlineSmall` — use `bodySmall` or `headlineMedium`
- ❌ Raw `TextStyle(fontSize: 14, fontWeight: w500)` — use `Theme.of(context).textTheme.bodyMedium`

### Colors
- ❌ `Colors.grey.shade50/100/200/...` — use AppColors or dark-aware variables
- ❌ `Colors.red`, `Colors.white` for non-icon contexts — use AppColors.red, AppColors.cardBg
- ❌ `Color(0xFFE2E8F0)`, `Color(0xFFDC2626)` — use AppColors tokens or computed colors
- ❌ Hardcoding light-only colors without `isDark` check

### Structure
- ❌ Not checking `isDark` before applying theme-dependent colors
- ❌ Mixing light/dark specific code without abstraction
- ❌ Custom card shadows that don't match AppRadius/AppSpacing/AppColors

## Page Creation Checklist

Before submitting any new page:

- [ ] All text uses `Theme.of(context).textTheme.X` (not raw TextStyle)
- [ ] Font weights are w400, w500, w600, w700, or w800 only
- [ ] Font sizes snap to: 12, 14, 16, 18, or 24
- [ ] All colors use AppColors constants or dark-mode-aware variables
- [ ] Dark mode supported: `isDark` check at top of build(), light/dark colors defined
- [ ] Cards follow PremiumCard or exact BoxDecoration pattern
- [ ] No `Colors.grey.shade*` used
- [ ] Input fields follow InputDecoration pattern
- [ ] Spacing uses AppSpacing tokens (xs, sm, md, lg, xl)
- [ ] Border radius uses AppRadius tokens (sm, md, lg)
- [ ] No `FontWeight.bold` — use w700 or w800
- [ ] No hardcoded hex colors like `Color(0xFFE2E8F0)`

## Testing

Before considering a page complete:

1. **Light Mode**: Toggle to light in Settings → verify all text legible, colors correct
2. **Dark Mode**: Toggle to dark in Settings → verify no broken contrast, text visible, backgrounds distinct
3. **Small Device**: Test on phone (small screen)
4. **Large Device**: Test on tablet (large screen)
5. **Contrast**: Use a contrast checker (WCAG AA: 4.5:1 minimum for text)

## References

- **Colors**: `lib/core/constants/app_tokens.dart` → `AppColors`
- **Spacing**: `lib/core/constants/app_tokens.dart` → `AppSpacing`
- **Radius**: `lib/core/constants/app_tokens.dart` → `AppRadius`
- **Theme**: `lib/core/constants/app_tokens.dart` → `buildAppTheme()`, `buildAppDarkTheme()`
- **CLAUDE.md**: `tenant-mobile/CLAUDE.md` (project-level rules)
