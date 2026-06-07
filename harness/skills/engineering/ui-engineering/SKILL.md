---
name: ui-engineering
description: Build production-quality user interfaces. Use when creating or modifying components, layouts, state, or any user-facing interface, or when output must look and feel hand-crafted rather than AI-generated. Covers component architecture, state, design-system adherence, accessibility, responsiveness, and performance.
license: MIT
metadata:
  discipline: frontend
  reference: addyosmani/agent-skills/frontend-ui-engineering
---
# UI Engineering

Build interfaces that are accessible, performant, and visually polished — not
"AI-default" looking. Optimize for clarity, consistency, and real user states.

## When to use
- Building new components or pages.
- Modifying user-facing interfaces, layouts, or interactions.
- Fixing visual / UX issues or responsiveness.
- Any time the result must look production-quality.

## Core principles

### Component architecture
- Colocate related files (component, styles, tests, hooks, types).
- Favor composition over configuration; keep components focused (< ~200 lines).
- Separate data fetching from presentation.

### Composition patterns
Compose reusable components with established patterns rather than boolean-prop
explosion. Most-used: **compound components** (grouped UI sharing one state, e.g.
Tabs/Accordion), **custom hooks** (reuse non-visual logic), **controlled/
uncontrolled** inputs, **headless components + prop getters** (behavior without
styling), **slots/children**, **polymorphic `as`**, and the **provider pattern**.
Reach for the simplest one that removes real duplication; abstract on the second
use, not the first. Full catalog with code: `references/patterns.md`.

### State management
- Escalate only as needed: local → lifted → context → URL → server cache → global.
- Avoid prop drilling beyond ~3 levels; reach for context or composition first.
- Keep server state in a cache layer; don't mirror it into global stores.

### Design-system adherence
- Eliminate AI tells: default purple palettes, gradient overload, uniform corner
  rounding, generic hero layouts, arbitrary pixel values.
- Use the spacing scale and semantic color tokens; never hard-code one-off values.
- Respect typographic hierarchy (display/h1–h3/body/small) and sufficient contrast.

### Accessibility (target WCAG 2.1 AA)
- Every interactive element is keyboard reachable and operable.
- Label controls (visible label or ARIA); manage focus in dynamic content.
- Never signal state by color alone; provide text/icon affordances.
- Design meaningful empty, loading, and error states.

### Responsive design
- Mobile-first; verify at 320 / 768 / 1024 / 1440 px.
- Prefer fluid layouts and container queries over fixed breakpoints where possible.

### Performance & perceived speed
- Skeletons over spinners; optimistic updates for mutations.
- Code-split routes and heavy components; lazy-load below the fold.
- Watch bundle size and avoid unnecessary re-renders.

## Red flags
- Components over ~200 lines or with inline/arbitrary styles.
- Missing loading / error / empty states.
- No keyboard-navigation or screen-reader pass.
- Color-only state indication; insufficient contrast.

## Verification checklist
- [ ] No console errors or warnings.
- [ ] Fully keyboard accessible; logical focus order.
- [ ] Screen-reader labels present and sensible.
- [ ] Responsive at all four reference widths.
- [ ] Loading, empty, and error states implemented.
- [ ] Design-system tokens used (no arbitrary values).

## Reference files
- `references/patterns.md` — front-end composition patterns (compound components,
  hooks, headless, controlled/uncontrolled, slots, polymorphic, provider, …).
- `references/checklist.md` — expanded accessibility/visual/state review checklist.
