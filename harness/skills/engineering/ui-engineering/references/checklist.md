# UI Review Checklist (expanded)

## Accessibility
- Keyboard: tab order is logical; no traps; visible focus ring on every control.
- Semantics: native elements first (`button`, `a`, `label`); ARIA only to fill gaps.
- Announcements: live regions for async updates; errors associated to inputs.
- Motion: respect `prefers-reduced-motion`.

## Visual quality
- Spacing follows the scale; alignment is consistent across the view.
- Typography hierarchy is clear; line length 45–75 chars for body text.
- Color tokens carry meaning; contrast ≥ 4.5:1 for text, 3:1 for large text/icons.
- Corner radius, shadows, and borders are consistent with the system.

## States
- Loading (skeleton), empty (guidance + CTA), error (cause + recovery), success.
- Disabled and pending states for async actions; prevent double-submit.

## Responsiveness
- 320 / 768 / 1024 / 1440 px verified; no horizontal overflow.
- Touch targets ≥ 44×44 px; hover-only affordances have non-hover equivalents.

## Performance
- No layout shift on load (reserve space for media).
- Images sized/lazy-loaded; fonts use `font-display: swap`.
- Memoize expensive renders; avoid re-render storms from context.
