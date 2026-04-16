# UI Components — Quick Reference

## Reusable Animations

### 1. FadeSlideTransition (Most Used)
**Use for**: Screen content, cards, sections entering view

```dart
FadeSlideTransition(
  duration: AppAnimations.normal,  // 300ms
  child: MyWidget(),
)
```
Effect: Fades in + slides up 20px

---

### 2. ScaleInAnimation (Emphasis)
**Use for**: Important cards, modals, emphasis

```dart
ScaleInAnimation(
  duration: AppAnimations.normal,
  child: MyCard(),
)
```
Effect: Fades in + scales from 0.8x to 1.0x

---

### 3. Staggered List Items (Lists)
**Use for**: Multiple cards/items entering

```dart
for (int i = 0; i < items.length; i++) {
  TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: AppAnimations.normal,
    delay: Duration(milliseconds: 100 * i),
    curve: AppAnimations.easeOutCubic,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      );
    },
    child: ItemWidget(),
  );
}
```
Effect: Each item fades + slides with 100ms delay

---

### 4. Simple Opacity Fade
**Use for**: State changes, loading completions

```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: AppAnimations.normal,
  child: MyWidget(),
)
```

---

### 5. Smooth Container Color Change
**Use for**: Status changes, highlight effects

```dart
AnimatedContainer(
  duration: AppAnimations.normal,
  decoration: BoxDecoration(
    color: status == 'paid' ? AppColors.paid : AppColors.pending,
    borderRadius: BorderRadius.circular(AppRadius.lg),
  ),
  child: content,
)
```

---

## Card Styling Template

### Basic Card with Proper Shadows
```dart
Container(
  margin: EdgeInsets.only(bottom: AppSpacing.md),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Colors.white.withOpacity(0.95)],
    ),
    borderRadius: BorderRadius.circular(AppRadius.lg),
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
    padding: EdgeInsets.all(AppSpacing.md),
    child: content,
  ),
)
```

---

## Commonly Used Patterns

### 1. Section Header with Content
```dart
FadeSlideTransition(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Section Title',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      // Content here
    ],
  ),
)
```

### 2. Metric Display Card
```dart
ScaleInAnimation(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: [/* shadows */],
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Label',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.violet,
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### 3. List of Animated Items
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.normal,
      delay: Duration(milliseconds: 50 * index),
      curve: AppAnimations.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ItemCard(item: items[index]),
    );
  },
)
```

---

## Input Field Styling

### Standard Form Field
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.violet.withOpacity(0.2),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.violet.withOpacity(0.2),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.violet,
        width: 2,
      ),
    ),
    filled: true,
    fillColor: Colors.white,
  ),
)
```

### Dropdown with Icon
```dart
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'Select Unit',
    labelStyle: TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.violet.withOpacity(0.2),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.violet, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
  ),
  icon: Icon(Icons.apartment_outlined, color: AppColors.violet.withOpacity(0.7)),
  items: /* items */,
  onChanged: /* callback */,
)
```

---

## Chart Styling Boilerplate

### Bar Chart Container
```dart
ScaleInAnimation(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: [
        BoxShadow(
          color: AppColors.violet.withOpacity(0.08),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: 240,
        child: BarChart(/* data */),
      ),
    ),
  ),
)
```

### Line Chart Container with Legend
```dart
ScaleInAnimation(
  duration: AppAnimations.slow,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: [/* shadows */],
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: LineChart(/* data */),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Due', AppColors.violet),
              SizedBox(width: AppSpacing.lg),
              _buildLegendItem('Paid', AppColors.paid),
            ],
          ),
        ],
      ),
    ),
  ),
)

Widget _buildLegendItem(String label, Color color) {
  return Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: AppSpacing.sm),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
```

---

## Animation Duration Guidance

| Scenario | Duration |
|----------|----------|
| Tooltip fade | 200ms |
| List item animation | 300ms |
| Card entrance | 300ms |
| Page transition | 500ms |
| Stagger delay | 50-100ms |

---

## Do's and Don'ts

### ✅ DO
- Use AppAnimations constants for timing
- Wrap content in FadeSlideTransition on screen entrance
- Stagger list items (50-100ms delay)
- Use ScaleInAnimation for emphasis
- Apply dual-layer shadows to cards
- Keep animation under 500ms

### ❌ DON'T
- Hardcode animation durations
- Animate static content
- Use animations > 500ms
- Skip animations on page transitions
- Animate disabled UI elements
- Mix multiple animation types in quick succession

---

## Testing Animations

1. Run on real device (not emulator)
2. Check 60fps with DevTools
3. Test on iPhone 12 mini (smallest)
4. Test on Android (performance varies)
5. Disable animations in accessibility settings (test fallback)
