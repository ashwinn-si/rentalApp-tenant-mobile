# Tenant Mobile App — Complete Styling Guide

## 1. Design Principles

- **Simplicity**: Minimal visual noise, focus on content
- **Consistency**: Same patterns across all screens
- **Accessibility**: WCAG AA compliant (4.5:1 contrast)
- **Performance**: Animations under 500ms, smooth 60fps
- **Hierarchy**: Clear visual importance through size, color, weight

---

## 2. Color Palette

### Core Colors
| Name | Hex | Use Case |
|------|-----|----------|
| Violet (Primary) | #7C3AED | Buttons, links, primary UI, appbar |
| Green (Success) | #16A34A | Payment status, completed actions |
| Orange (Partial) | #D97706 | Partial payments, warnings |
| Red (Pending) | #DC2626 | Unpaid, overdue, errors |
| Light Purple (BG) | #F5F3FF | Screen background |
| White (Card) | #FFFFFF | Cards, surfaces, modals |
| Dark Gray (Text) | #111827 | Primary text |
| Medium Gray (Text) | #6B7280 | Secondary text, hints |

### Opacity Patterns
```dart
// For subtle elements
color.withOpacity(0.08)  // Very light (backgrounds)
color.withOpacity(0.15)  // Light (borders, dividers)
color.withOpacity(0.25)  // Medium (shadows, overlays)
color.withOpacity(0.6)   // Dark (secondary text)
```

---

## 3. Spacing System

8pt grid-based spacing for consistency:

```dart
4px  (xs) - Small gaps, icon spacing
8px  (sm) - Padding inside components
16px (md) - Standard padding, spacing between elements
24px (lg) - Large spacing between sections
32px (xl) - Extra large spacing between major sections
```

### Examples
- Card padding: `AppSpacing.md` (16px)
- Icon size: 24px with `AppSpacing.sm` margins
- Section separation: `AppSpacing.lg` (24px)

---

## 4. Typography

### Font Weights & Sizes
```
Heading 1  → 24px, Weight 800 (Bold)
Heading 2  → 18px, Weight 800 (Bold)
Heading 3  → 16px, Weight 700 (SemiBold)
Body       → 14px, Weight 500 (Medium)
Caption    → 12px, Weight 400 (Regular)
```

### Text Colors
- **Primary Text**: `#111827` (dark gray)
- **Secondary Text**: `#6B7280` (medium gray)
- **Accent Text**: `#7C3AED` (violet for important info)
- **Positive Text**: `#16A34A` (green for success)
- **Negative Text**: `#DC2626` (red for errors/pending)

### Line Height
- Standard: 1.4x font size
- Headings: 1.2x font size
- Body text: 1.6x font size

---

## 5. Components

### Cards
**Purpose**: Content containers with visual separation

**Pattern**:
```dart
Container(
  margin: EdgeInsets.only(bottom: 16px),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.white, Colors.white.withOpacity(0.95)]
    ),
    borderRadius: BorderRadius.circular(16px),
    boxShadow: [/* dual layer shadow */],
  ),
  child: Padding(
    padding: EdgeInsets.all(16px),
    child: content,
  ),
)
```

**Shadow Depth**:
- Layer 1: 12px blur, 2px offset (main shadow)
- Layer 2: 24px blur, 8px offset (ambient shadow)

### Buttons
**Primary** (filled):
- Background: `#7C3AED` (violet)
- Text: White
- Padding: 12px vertical, 24px horizontal
- Border radius: 8px

**Secondary** (outline):
- Border: 1px `#7C3AED`
- Text: `#7C3AED`
- Background: Transparent
- Padding: 12px vertical, 24px horizontal

**Disabled**:
- Opacity: 0.5
- Cursor: Not allowed

### Input Fields
**Focus State**:
- Border color: `#7C3AED` (2px)
- Background: White
- Shadow: Optional light violet shadow

**Error State**:
- Border color: `#DC2626` (red)
- Error text: Red, 12px, below field

**Filled State**:
- Background: White
- Border: 1px light violet (`#7C3AED` with 0.2 opacity)

### Status Chip
```dart
StatusChip.fromString(status)
// Renders: Paid (green), Partial (orange), Pending (red)
// Padding: 8px horizontal, 4px vertical
// Font size: 12px, weight 600
```

---

## 6. Animations & Transitions

### Duration Scale
```dart
Fast    = 200ms   (micro-interactions, tooltips)
Normal  = 300ms   (card animations, list items)
Slow    = 500ms   (page transitions, complex animations)
```

### Easing Curves
```dart
easeOutCubic  = Cubic(0.215, 0.61, 0.355, 1.0)
              → Smooth deceleration (fade/slide)

easeInOutCubic = Cubic(0.645, 0.045, 0.355, 1.0)
               → Ease in and out (complex)

easeOutExpo   = Cubic(0.19, 1.0, 0.22, 1.0)
              → Quick snap (scale, pop)
```

### Reusable Animations

**FadeSlideTransition**: Fade in + slide up
```dart
FadeSlideTransition(
  duration: AppAnimations.normal,
  child: widget,
)
```
- Opacity: 0 → 1
- Transform: Y offset 20px → 0

**ScaleInAnimation**: Fade in + scale
```dart
ScaleInAnimation(
  duration: AppAnimations.normal,
  child: widget,
)
```
- Opacity: 0 → 1
- Scale: 0.8x → 1.0x

**Staggered List**: Auto-animate list items
```dart
for (int i = 0; i < items.length; i++) {
  TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: AppAnimations.normal,
    delay: Duration(milliseconds: 100 * i),
    // ... fade + slide up
  )
}
```

### When to Animate
✅ Screen entrance → FadeSlideTransition
✅ Cards/modals → ScaleInAnimation
✅ List items → Staggered (50-100ms delay)
✅ State changes → Smooth transitions
❌ Don't animate: Static content, disabled UI

---

## 7. Charts

### BarChart (Monthly Breakdown)
- Height: 240px (including legend)
- Colors: Primary violet for bars
- Grid: Subtle horizontal lines (opacity 0.08)
- Rounded corners: 6px on bar tops
- Background bars: Faint violet (0.05 opacity)
- Shadows: Container shadow for depth

### LineChart (Trend)
- Height: 240px (including legend)
- Lines: 3px width, round caps
- Dots: 4px radius with white stroke
- Fill below: Gradient (color 0.15 → 0.01 opacity)
- Colors: Violet (due) + Green (paid)
- Legend: Inline below chart, 2-column grid

### Grid & Borders
- Grid lines: Light gray (0.08 opacity)
- Bottom border: 1px light gray (0.1 opacity)
- Left border: 1px light gray (0.1 opacity)
- Top/Right: None

---

## 8. Shadows & Elevation

### Elevation Levels
```
Level 1: Cards, sections
  - Color: violet(0.06), blur: 12px, offset: 0,2px
  - Color: violet(0.03), blur: 24px, offset: 0,8px

Level 2: Elevated cards, modals
  - Color: primary(0.08), blur: 16px, offset: 0,4px

Level 3: Floating buttons, tooltips
  - Color: primary(0.25), blur: 16px, offset: 0,4px
```

### No Shadows
- Buttons
- Text fields
- Bottom navigation
- Tabs

---

## 9. Responsive Design

### Breakpoints
- **Mobile**: < 600dp (primary target)
- **Tablet**: 600dp - 1200dp (adaptive)
- **Web**: > 1200dp (not supported)

### Touch Targets
- Minimum: 44×44pt (iOS), 48×48dp (Android)
- Buttons: 48×48dp
- Icons: 24dp (with 8dp padding = 40×40dp)
- Text input: 48dp height

---

## 10. Dark Mode (Future)

When implementing:
- Use dark gray instead of black (`#111827` → `#0F172A`)
- Adjust shadows (darker, less opacity)
- Maintain same color semantics
- Test contrast ratios

---

## 11. Accessibility

### Contrast Ratios (WCAG AA)
- Normal text: ≥ 4.5:1
- Large text (18pt+): ≥ 3:1
- UI components: ≥ 3:1

### Testing
- [WCAG Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Flutter DevTools: Accessibility Inspector
- Test on grayscale to verify

### Best Practices
- Don't rely on color alone (add icons)
- Provide alt text for images
- Use semantic widgets (Button, TextField)
- Support screen readers
- Scalable font sizes

---

## 12. Implementation Checklist

- [ ] Use `AppColors` constants (never hardcode)
- [ ] Use `AppSpacing` for padding/margins
- [ ] Use `AppRadius` for border radius
- [ ] Use `AppAnimations` for timings
- [ ] Add shadows to cards/elevated elements
- [ ] Include animations on screen entrance
- [ ] Test on iPhone 12 mini (375pt width)
- [ ] Verify touch targets ≥ 44×44pt
- [ ] Check contrast ratio ≥ 4.5:1
- [ ] Test animations at 60fps
- [ ] Use semantic color meanings

---

## 13. Example: Rent Breakdown Card

```dart
Container(
  margin: EdgeInsets.only(bottom: 16px),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.white, Colors.white.withOpacity(0.95)],
    ),
    borderRadius: BorderRadius.circular(16px),
    boxShadow: [
      BoxShadow(
        color: AppColors.violet.withOpacity(0.06),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: AppColors.violet.withOpacity(0.03),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Padding(
    padding: EdgeInsets.all(16px),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with month + status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'April 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            StatusChip.fromString('Paid'),
          ],
        ),
        SizedBox(height: 16px),
        // Line items with amounts
        _buildRow('Base Rent', 20000),
        _buildRow('Electricity', 2500),
        _buildRow('Maintenance', 1000),
        Divider(height: 24px),
        _buildRow('Total Due', 23500, bold: true),
        _buildRow('Paid', 23500, paid: true),
      ],
    ),
  ),
)
```

---

## 14. Resources

- **Colors**: `/lib/core/constants/app_tokens.dart`
- **Animations**: `/lib/core/utils/animations.dart`
- **Chart Widgets**: `/lib/widgets/ui/chart_widgets.dart`
- **Theme**: `buildAppTheme()` in `app_tokens.dart`

---

## 15. Future Enhancements

- [ ] Dark mode theme
- [ ] Custom page transitions (slide, diagonal)
- [ ] Haptic feedback on button press
- [ ] Loading skeleton animations
- [ ] Empty state illustrations
- [ ] Swipe gestures (close modals, navigate)
- [ ] Parallax scrolling
- [ ] Micro-interactions (pull-to-refresh)
