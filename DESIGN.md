---
name: Pantaura
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#41474e'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#71787f'
  outline-variant: '#c1c7d0'
  surface-tint: '#24638f'
  primary: '#00476e'
  on-primary: '#ffffff'
  primary-container: '#1f5f8b'
  on-primary-container: '#add7ff'
  inverse-primary: '#94ccfe'
  secondary: '#00677c'
  on-secondary: '#ffffff'
  secondary-container: '#7fe2ff'
  on-secondary-container: '#006478'
  tertiary: '#2c4175'
  on-tertiary: '#ffffff'
  tertiary-container: '#44598e'
  on-tertiary-container: '#c3d2ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cde5ff'
  primary-fixed-dim: '#94ccfe'
  on-primary-fixed: '#001d31'
  on-primary-fixed-variant: '#004b74'
  secondary-fixed: '#b1ecff'
  secondary-fixed-dim: '#70d4f1'
  on-secondary-fixed: '#001f27'
  on-secondary-fixed-variant: '#004e5e'
  tertiary-fixed: '#dae2ff'
  tertiary-fixed-dim: '#b1c5ff'
  on-tertiary-fixed: '#001947'
  on-tertiary-fixed-variant: '#304579'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
  surface-canvas: '#F8FAFC'
  surface-card: '#FFFFFF'
  surface-tint-ice: '#D2ECF9'
  border-subtle: '#E2E8F0'
  text-primary: '#1E293B'
  text-header: '#253B6E'
  status-unverified: '#D97706'
  status-unverified-bg: '#FEF3C7'
  status-verified: '#DC2626'
  status-verified-bg: '#FEE2E2'
  status-resolution: '#1891AC'
  status-resolution-bg: '#D2ECF9'
  status-resolved: '#16A34A'
  status-resolved-bg: '#DCFCE7'
  status-rejected: '#64748B'
  status-rejected-bg: '#F1F5F9'
typography:
  display-hero:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1rem
  margin-lg: 1.5rem
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style

The design system establishes a high-contrast, calm, and reassuring digital environment built for high-stress civic and emergency situations. Its design language blends **Modern Corporate Utility** with **Elder-Friendly Ergonomics**, emphasizing instant legibility, unambiguous touch targets, and authoritative visual calmness under adverse physical conditions (e.g., outdoor direct sunlight, trembling hands, slow network connectivity).

### Brand Personality & Core Values
- **Authoritative & Trustworthy:** Anchored by deep maritime blues, projecting systemic stability, rapid coordination, and institutional accountability.
- **Calm & Non-Alarmist:** Avoids chaotic layouts or gratuitous warning textures; uses controlled, semantic color tokens to inform rather than panic.
- **Radically Accessible:** Strict adherence to WCAG AAA contrast ratios (minimum 7:1 for normal text), expansive touch targets (minimum 48px to 56px), and legible typography scaling designed for elderly citizens, rescue volunteers, and stressed reporting users.
- **Functional & Direct:** Clean vector icon-text pairings, status chips with explicit iconography, and clear hierarchy that replaces decorative illustrations with actionable data points.

### Aesthetic Execution
The interface relies on clear visual boundaries, subtle border outlines, and soft oceanic surface tints (`#D2ECF9`) over pure `#FFFFFF` cards, floating above an anti-glare canvas (`#F8FAFC`). Flat planes, controlled elevation shadows tinted with deep navy, and distinct semantic state indicators guide citizens swiftly through disaster submission and resolution workflows.

## Colors

The color palette centers on a disciplined nautical and teal structure paired with high-visibility semantic status tiers. Because this application operates during emergency and field scenarios, contrast is paramount: all text pairings must achieve WCAG AAA compliance against their designated surface containers.

### Role Allocations
- **Primary Brand (`#1F5F8B`):** Dedicated to core interactive drivers, active navigation states, primary buttons, confirmed map pins, and focused input outlines.
- **Secondary Accent (`#1891AC`):** Applied to the central emergency reporting Floating Action Button (FAB), active highlights, secondary badges, and progress indicators.
- **Tertiary Dark (`#253B6E`):** Used for solid headers, top AppBars, high-priority modals, primary action triggers on light containers, and deep textual hierarchy.
- **Neutral Surface & Stroke (`#64748B`, `#E2E8F0`, `#F8FAFC`):** Soft, low-fatigue slate grays provide crisp boundaries and secondary descriptions without competing with active alerts.
- **Surface Tint Ice Blue (`#D2ECF9`):** Provides soft, reassuring container backdrops for emergency banners, active filter chips, and selected category cards.

### Incident Lifecycle Status Tokens
Status colors must never rely solely on hue; always pair them with their corresponding status icon and contrasting background tint:
- **Unverified (`#D97706` / `#FEF3C7`):** Amber tone indicating incoming citizen reports pending verification.
- **Verified (`#DC2626` / `#FEE2E2`):** Vivid crimson signaling active, confirmed emergency situations requiring caution.
- **Resolution Submitted (`#1891AC` / `#D2ECF9`):** Bright teal indicating field evidence has been lodged and recovery verification is underway.
- **Resolved (`#16A34A` / `#DCFCE7`):** Clear emerald confirming safe, normalized municipal conditions.
- **Rejected (`#64748B` / `#F1F5F9`):** Muted slate used strictly in private history views for invalid reports.

## Typography

The type system pairs **Plus Jakarta Sans** for prominent headers with **Inter** for UI, data feeds, forms, and general readability. 

### Typographic Hierarchy & Readability Rules
- **Legibility in Motion:** `Plus Jakarta Sans` provides open apertures and distinctive shapes that remain legible on jostling mobile devices. Headlines are styled in Bold or SemiBold (`700`/`600`) to create clear section landmarks.
- **Functional Body Text:** `Inter` handles all dense informational strings, form labels, and timestamps. Body text defaults to minimum `14px` (`body-md`), scaling up to `16px` (`body-lg`) for elderly-friendly form instructions.
- **Button & Label Enunciation:** Button labels and interactive chips require medium-to-semibold weights (`label-md` and `label-lg`) with slight positive letter spacing (`0.02em` / `0.5px`) to preserve clarity in low-contrast outdoor environments.
- **Strict Size Floor:** Never render interactive labels or status badges below `12px`.

## Layout & Spacing

The layout model is built on an accessible, thumb-friendly single-column mobile rhythm using an 8-point baseline grid (with 4-point micro increments).

### Grid & Form Factors
- **Mobile Handheld (320px – 480px):** Single-column layout with fixed horizontal screen padding (`margin: 1rem` / 16dp). Card content gutters default to `1rem` (16dp), reducing to `0.75rem` (12dp) for dense two-column incident feeds.
- **Large Handheld & Small Tablet (481px – 768px):** Screen margin expands to `margin-lg: 1.5rem` (24dp), capping form containers at a maximum readable width of 600px centered in the viewport.
- **Vertical Spacing Rhythm:** Component separation maintains a consistent vertical gap of `space-md` (16dp). Dense metadata within cards uses `space-xs` (8dp) to `space-sm` (12dp).
- **Safe Tap Bounds:** Interactive elements (buttons, inputs, category selectors, map markers) enforce an absolute minimum touch boundary of 48px × 48px, with 56px height standard for primary CTA buttons.

## Elevation & Depth

Visual hierarchy uses physical card separation combined with soft, navy-tinted ambient shadows. Avoid high-contrast harsh dropshadows or glossy 3D skeumorphism; depth must feel structural, orderly, and calm.

### Elevation Architecture
- **Level 0 (Flat Canvas):** The base background canvas `#F8FAFC`. All primary content rests on top of this tone.
- **Level 1 (Card & Content Blocks):** Pure white surfaces (`#FFFFFF`) framed by a subtle 1px border (`#E2E8F0`). Flat on the surface or lifted with a faint ambient shadow:
  - *Box Shadow:* `0px 2px 4px rgba(37, 59, 110, 0.04)`.
- **Level 2 (Floating Controls & Navigation):** AppBars, Incident Preview Sheets, Filter Chips, and Bottom Navigation Bars:
  - *Box Shadow:* `0px 4px 12px rgba(37, 59, 110, 0.08)`.
- **Level 3 (Emergency Actions & Overlays):** Central Reporting FAB, Map Location Finders, and Dialog Modals:
  - *Box Shadow:* `0px 8px 24px rgba(37, 59, 110, 0.16)`.
- **Level 4 (Sticky Full-Width CTAs):** Bottom sheet buttons pinned above the safe area utilize a top-cast border blur:
  - *Box Shadow:* `0px -4px 16px rgba(37, 59, 110, 0.06)`.

## Shapes

The design system incorporates a balanced, friendly geometric radius (`roundedness: 2`) that conveys contemporary approachability while retaining professional structure.

### Geometric Application
- **Base Elements (Buttons, Inputs, Selectors):** Standard radius of `12dp` (`0.75rem`), providing clear touch affordance without turning into stark rectangles.
- **Cards, Panels & Containers:** Form modules, incident list cards, and media preview panels use `16dp` (`1rem`) corner radius.
- **Bottom Sheets & Modal Surfaces:** Sheet overlays feature rounded top corners of `24dp` (`1.5rem`) with squared bottom corners to anchor firmly to the viewport base.
- **Badges, Chips & Meta Indicators:** Compact informative pills use `8dp` (`0.5rem`) to maintain compact density.
- **Floating Action Button (FAB):** Completely circular (`pill-shaped` / 50% radius) surrounded by an ergonomic soft buffer ring.

## Components

### 1. Primary & Secondary Buttons
- **Primary Action (CTA):** Height `56px` (Elder-friendly tap target). Background `#1F5F8B`, text `#FFFFFF`, border-radius `12px`, typography `label-lg`. Pressed state transitions to `#253B6E`.
- **Emergency Accent (FAB):** Diameter `64px`, background `#1891AC`, white icon (`28px`), encased in a subtle `4px` ring of `#D2ECF9` with Level 3 elevation shadow.
- **Secondary Outlined:** Height `56px`, border `2px solid #1F5F8B`, background transparent, text `#1F5F8B`, border-radius `12px`.
- **Sticky Bottom Action:** Full-width container anchored to screen bottom with `16px` padding and safe-area insets.

### 2. Status Chips & Badges
- **Structure:** Always combine an icon (14px) with uppercase or title-case text (12px, semibold).
- **Variants:**
  - *Unverified:* Background `#FEF3C7`, text `#D97706`, icon `clock` or `hourglass`.
  - *Verified:* Background `#FEE2E2`, text `#DC2626`, icon `shield-alert`.
  - *Resolution Submitted:* Background `#D2ECF9`, text `#1891AC`, icon `refresh-cw`.
  - *Resolved:* Background `#DCFCE7`, text `#16A34A`, icon `check-circle`.
- **Dimensions:** Minimum height `28px`, horizontal padding `10px`, radius `8px`.

### 3. Disaster Category Selector (Grid 2x2)
- Large touch cards (minimum `100px` height) configured in a two-column grid.
- **Default State:** Background `#FFFFFF`, border `1.5px solid #E2E8F0`, icon (32px) `#253B6E`, title `#1E293B` (16px, bold).
- **Selected State:** Background `#D2ECF9`, border `2.5px solid #1F5F8B`, icon `#1F5F8B`, title `#253B6E`. Checkmark badge anchored top-right.

### 4. Input Fields & Text Areas
- **Height & Padding:** Text inputs minimum `54px` height; multi-line text areas minimum `120px` height. Internal horizontal padding `16px`.
- **States:**
  - *Default:* Border `1.5px solid #E2E8F0`, background `#FFFFFF`, text `#1E293B`, placeholder `#64748B`.
  - *Active / Focus:* Border `2px solid #1F5F8B`, background `#FFFFFF`.
  - *Error:* Border `2px solid #DC2626`, inline error message below field in `#DC2626` (13px, medium) paired with an alert icon.
- **Labeling:** Permanent top label in `#253B6E` (`label-md`), never floating inside to avoid confusion.

### 5. Media Upload Buttons
- Dual side-by-side cards with `2px dashed #1F5F8B` border, background `#D2ECF9` at 40% opacity, min-height `72px`.
- Prominent icon (camera / gallery) paired with label text centered vertically.

### 6. Incident Cards & Feeds
- Surface `#FFFFFF`, border `1px solid #E2E8F0`, corner radius `16px`, padding `16px`.
- Layout: Top-row category & status badges, headline (16px bold), location line with map pin, timestamp, and incident aggregation badge (e.g., *"3 Laporan Tergabung"* on `#D2ECF9` pill).

### 7. Interactive Map Markers
- Teardrop shape pin with centered disaster icon.
- Marker color mirrors the status palette (Red for `verified`, Amber for `unverified`, Green for `resolved`).
- Pin includes a top-right counter badge for multiple grouped reports.