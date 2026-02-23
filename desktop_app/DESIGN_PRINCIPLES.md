# Vibe Deck Design Principles

This document defines the design system for Vibe Deck applications. Use these principles when designing or modifying any Vibe Deck interface (desktop host, client apps, web interface, etc.).

## Table of Contents

- [Brand Colors](#brand-colors)
- [Color Palette](#color-palette)
- [Typography Scale](#typography-scale)
- [Spacing System](#spacing-system)
- [Border Radius](#border-radius)
- [Shadows](#shadows)
- [Component Guidelines](#component-guidelines)
- [Dark Mode](#dark-mode)

---

## Brand Colors

### Primary Accent: Electric Blue
- **Hex:** `#3B82F6`
- **RGB:** `rgb(59, 130, 246)`
- **HSL:** `hsl(217, 91%, 60%)`

**Why Electric Blue?**
- Conveys trust, reliability, and technical competence
- Excellent contrast in both light and dark modes
- Modern developer tool aesthetics
- Universally recognizable as a "technical/action" color

### Semantic Colors

| Purpose | Color | Hex | Usage |
|---------|-------|-----|-------|
| Success | Green | `#10B981` | Positive states, running status |
| Warning | Orange | `#F59E0B` | Warnings, shell mode indicators |
| Danger | Red | `#EF4444` | Errors, dangerous actions, stopped status |
| Info | Blue | `#3B82F6` | Informational messages |

---

## Color Palette

### Light Mode

| Category | Token | Hex | Usage |
|----------|-------|-----|-------|
| Background | `background` | `#FAFAFA` | Scaffold background |
| Surface | `surface` | `#FFFFFF` | Cards, dialogs |
| Surface Variant | `surfaceVariant` | `#F5F5F5` | Card headers, inputs |
| Border | `border` | `#E5E7EB` | Dividers, borders |
| Primary | `primary` | `#3B82F6` | Actions, links, accents |
| Primary Hover | `primaryHover` | `#2563EB` | Hover states |
| Primary Container | `primaryContainer` | `#DBEAFE` | Accent backgrounds |
| Text Primary | `textPrimary` | `#111827` | Headings, primary text |
| Text Secondary | `textSecondary` | `#6B7280` | Secondary text |
| Text Tertiary | `textTertiary` | `#9CA3AF` | Captions, metadata |

### Dark Mode

| Category | Token | Hex | Usage |
|----------|-------|-----|-------|
| Background | `backgroundDark` | `#0F0F0F` | Scaffold background |
| Surface | `surfaceDark` | `#1A1A1A` | Cards, dialogs |
| Surface Variant | `surfaceVariantDark` | `#242424` | Card headers, inputs |
| Border | `borderDark` | `#2A2A2A` | Dividers, borders |
| Primary | `primary` | `#3B82F6` | Actions, links, accents |
| Primary Hover | `primaryHoverDark` | `#60A5FA` | Hover states |
| Primary Container | `primaryContainerDark` | `#1E3A8A` | Accent backgrounds |
| Text Primary | `textPrimaryDark` | `#F9FAFB` | Headings, primary text |
| Text Secondary | `textSecondaryDark` | `#9CA3AF` | Secondary text |
| Text Tertiary | `textTertiaryDark` | `#6B7280` | Captions, metadata |

### Glassmorphism Overlay (Dark Mode)
- **Hex:** `#0AFFFFFF` (6% white with alpha)
- **Usage:** Elevated headers, floating elements in dark mode

---

## Typography Scale

### Font Sizes

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `fontSize3Xl` | 32px | Bold | Hero text |
| `fontSize2Xl` | 24px | Bold/Semibold | Large headers |
| `fontSizeXl` | 20px | Semibold | Page headers |
| `fontSizeLg` | 16px | Semibold | Card titles |
| `fontSizeMd` | 14px | Regular | Body text, labels |
| `fontSizeSm` | 12px | Regular | Secondary text |
| `fontSizeXs` | 11px | Medium | Labels, metadata |

### Font Weights

| Token | Value | Usage |
|-------|-------|-------|
| `weightRegular` | 400 | Body text |
| `weightMedium` | 500 | Emphasized text, buttons |
| `weightSemibold` | 600 | Headings, card titles |
| `weightBold` | 700 | Hero text |

### Letter Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `letterSpacingTight` | -0.5 | Large headings |
| `letterSpacingNormal` | 0 | Default |
| `letterSpacingWide` | 0.5 | Labels, buttons |

### Line Heights

| Token | Value | Usage |
|-------|-------|-------|
| `lineHeightTight` | 1.2 | Hero text, large headings |
| `lineHeightNormal` | 1.5 | Headings, labels |
| `lineHeightRelaxed` | 1.75 | Body text |

### Font Families

- **Primary:** System default (San Francisco on macOS, Segoe UI on Windows, Roboto on Android)
- **Monospace:** Monaco, Menlo, Consolas (for code, logs)

---

## Spacing System

All spacing follows an **8px grid system**. Use these values consistently.

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXs` | 4px | Tight gaps, icon spacing |
| `spacingSm` | 8px | Default element gap |
| `spacingMd` | 16px | Card padding, sections |
| `spacingLg` | 24px | Screen padding, large gaps |
| `spacingXl` | 32px | Major section spacing |
| `spacingXxl` | 48px | Hero sections |

### Spacing Rules

1. **Card padding:** Always use `spacingMd` (16px)
2. **Gap between related elements:** Use `spacingSm` (8px)
3. **Gap between sections:** Use `spacingMd` (16px)
4. **Screen margins:** Use `spacingLg` (24px)

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSm` | 8px | Small elements, buttons |
| `radiusMd` | 12px | Cards (default) |
| `radiusLg` | 16px | Large cards, dialogs |
| `radiusXl` | 24px | Hero cards, modals |
| `radiusFull` | 999px | Circular elements (badges, avatars) |

### Border Radius Rules

1. **Default card radius:** Use `radiusMd` (12px)
2. **Dialog radius:** Use `radiusLg` (16px)
3. **Button radius:** Use `radiusSm` (8px)
4. **Status badges:** Use `radiusFull` (circular or pill-shaped)

---

## Shadows

### Light Mode

| Token | CSS | Usage |
|-------|-----|-------|
| `shadowCard` | `rgba(0,0,0,0.05) 0px 2px 8px` | Cards |
| `shadowElevated` | `rgba(0,0,0,0.08) 0px 4px 12px` | Floating elements |

### Dark Mode

| Token | CSS | Usage |
|-------|-----|-------|
| `shadowCardDark` | `rgba(0,0,0,0.10) 0px 2px 8px` | Cards |
| `shadowElevatedDark` | `rgba(0,0,0,0.20) 0px 4px 12px` | Floating elements |

### Shadow Rules

1. **Use shadows sparingly** - rely more on color contrast
2. **Dark mode shadows are darker** - needed for visibility on dark backgrounds
3. **No elevation on AppBar** - use color difference instead

---

## Component Guidelines

### Cards

- **Padding:** 16px (`spacingMd`)
- **Border radius:** 12px (`radiusMd`)
- **Background:** `surface` (light) or `surfaceDark` (dark)
- **Shadow:** `shadowCard` or `shadowCardDark`
- **Header (optional):** Slightly different background with icon + title

### Status Badges

```
┌─────────────────────┐
│ 🟢 Running          │  ← Success color, pill-shaped
└─────────────────────┘

┌─────────────────────┐
│ ⚠️ SHELL MODE       │  ← Warning color, pill-shaped
└─────────────────────┘
```

- **Padding:** 4px horizontal, 4px vertical
- **Border radius:** `radiusFull` (pill-shaped)
- **Font size:** `fontSizeXs` (11px)
- **Font weight:** `weightMedium` (500)

### Buttons

- **Primary:** Filled button with Electric Blue background
- **Secondary:** Outlined button with border
- **Tertiary:** Text button (no background, no border)
- **Danger:** Red background for dangerous actions
- **Padding:** 12px horizontal (`spacingMd`), 8px vertical (`spacingSm`)
- **Border radius:** 8px (`radiusSm`)

### Inputs

- **Background:** `surfaceVariant` (light) or `surfaceVariantDark` (dark)
- **Border:** 1px solid, subtle color
- **Border radius:** 8px (`radiusSm`)
- **Padding:** 12px horizontal, 8px vertical
- **Focus state:** 2px border with primary color

### Switches/Toggles

- **Active color:** Electric Blue
- **Track:** Primary container color when active
- **Thumb:** White or surface color

### Icons

- **Default size:** 24px
- **Small size:** 16px (for inline icons)
- **Color:** Match text color (secondary or primary)

---

## Dark Mode

### Principles

1. **True dark background:** Use `#0F0F0F` (not pure black) for the scaffold
2. **Surface cards:** Use `#1A1A1A` for cards to create subtle separation
3. **Higher contrast needed:** Shadows are darker in dark mode
4. **Glassmorphism:** Add subtle white overlay (6% opacity) for elevated elements

### Dark Mode Conversion

| Light Mode | Dark Mode |
|------------|-----------|
| `#FAFAFA` (background) | `#0F0F0F` (backgroundDark) |
| `#FFFFFF` (surface) | `#1A1A1A` (surfaceDark) |
| `#F5F5F5` (surfaceVariant) | `#242424` (surfaceVariantDark) |
| `#E5E7EB` (border) | `#2A2A2A` (borderDark) |
| `#111827` (textPrimary) | `#F9FAFB` (textPrimaryDark) |
| `#6B7280` (textSecondary) | `#9CA3AF` (textSecondaryDark) |
| `#9CA3AF` (textTertiary) | `#6B7280` (textTertiaryDark) |

### Dark Mode Special Effects

**Glassmorphism Header (Dark Mode Only):**
```
background: surfaceDark + glassOverlayDark (6% white)
backdrop-filter: blur(10px) (platform-specific)
border-bottom: 1px solid borderDark
```

---

## Reusable Patterns

### Card with Header

```
┌─────────────────────────────────────┐
│ [Icon] Title              [Badge]   │ ← Header (surfaceVariant)
├─────────────────────────────────────┤
│                                       │
│  Content area                        │ ← Body (surface)
│                                       │
└─────────────────────────────────────┘
```

### Copy Button Row

```
┌─────────────────────────────────────┐
│ Label: Value      [Copy Icon]       │
└─────────────────────────────────────┘
```

- Label: Secondary text color
- Value: Primary text color, monospace if technical
- Button: Icon-only or icon + text, outlined style

### Danger Zone Section

```
┌─────────────────────────────────────┐
│ ⚠️ Danger Zone                      │ ← Warning-colored border (top: 2px)
├─────────────────────────────────────┤
│  Warning message...                 │
│  [Enable Dangerous Feature]         │ ← Danger button
└─────────────────────────────────────┘
```

- Top border: 2px solid warning color
- Background: Warning container color (subtle)
- Button: Red/danger color

---

## Implementation

### Flutter

The design system is implemented in `lib/src/design/`:
- `design_tokens.dart` - All constants and helper methods
- `app_theme.dart` - Complete ThemeData for light and dark modes

Usage:
```dart
import '../design/design_tokens.dart';
import '../design/app_theme.dart';

// Use tokens directly
Container(
  padding: const EdgeInsets.all(AppTokens.spacingMd),
  decoration: BoxDecoration(
    color: AppTokens.getSurface(brightness),
    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    boxShadow: AppTokens.getCardShadow(brightness),
  ),
)

// Or use theme
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

### Web/React

```css
/* CSS Variables */
:root {
  --color-background: #FAFAFA;
  --color-surface: #FFFFFF;
  --color-primary: #3B82F6;
  --color-text-primary: #111827;
  --spacing-md: 16px;
  --radius-md: 12px;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #0F0F0F;
    --color-surface: #1A1A1A;
    --color-text-primary: #F9FAFB;
  }
}
```

---

## Accessibility

### Contrast Ratios

All color combinations meet **WCAG AA** standards:
- Normal text: 4.5:1 minimum
- Large text (18px+): 3:1 minimum
- UI components: 3:1 minimum

### Focus States

All interactive elements must have visible focus states:
- Buttons: 2px border with primary color
- Inputs: 2px border with primary color
- Cards: Subtle outline or elevation change

### Touch Targets

- Minimum size: 44x44px (mobile)
- Recommended: 48x48px (mobile)

---

## Resources

- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Color Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

*Last updated: 2025*
*Version: 1.0.0*
