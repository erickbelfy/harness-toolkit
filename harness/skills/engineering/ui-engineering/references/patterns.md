# Front-end Composition Patterns

A working catalog of the patterns used to build reusable, composable components.
Examples are React + TypeScript, but the ideas port to most component models.
Pick the simplest pattern that removes the duplication — don't reach for a
reducer or polymorphism until a real second use case demands it.

## 1. Compound Components
Parent shares implicit state with children via context, so consumers compose the
parts declaratively. Use for grouped UI with one shared state (Tabs, Accordion,
Select, Menu, Disclosure).

```tsx
const TabsContext = createContext<{ active: string; setActive: (id: string) => void } | null>(null)
const useTabs = () => {
  const ctx = useContext(TabsContext)
  if (!ctx) throw new Error("Tabs.* must be used within <Tabs>")
  return ctx
}

function Tabs({ defaultId, children }: { defaultId: string; children: ReactNode }) {
  const [active, setActive] = useState(defaultId)
  return <TabsContext.Provider value={{ active, setActive }}>{children}</TabsContext.Provider>
}
Tabs.List = ({ children }: { children: ReactNode }) => <div role="tablist">{children}</div>
Tabs.Tab = ({ id, children }: { id: string; children: ReactNode }) => {
  const { active, setActive } = useTabs()
  return (
    <button role="tab" aria-selected={active === id} onClick={() => setActive(id)}>
      {children}
    </button>
  )
}
Tabs.Panel = ({ id, children }: { id: string; children: ReactNode }) => {
  const { active } = useTabs()
  return active === id ? <div role="tabpanel">{children}</div> : null
}

// Usage — flexible structure, no prop soup:
<Tabs defaultId="a">
  <Tabs.List><Tabs.Tab id="a">A</Tabs.Tab><Tabs.Tab id="b">B</Tabs.Tab></Tabs.List>
  <Tabs.Panel id="a">Panel A</Tabs.Panel>
  <Tabs.Panel id="b">Panel B</Tabs.Panel>
</Tabs>
```
Trade-offs: great ergonomics and flexibility; requires a context guard and clear
sub-component naming. Avoid for single, flat components with no shared state.

## 2. Custom Hooks (logic extraction)
Move stateful, non-visual logic into a hook so multiple components reuse it.
This is the first tool to reach for — most "patterns" below are hooks underneath.

```tsx
function useDisclosure(initial = false) {
  const [open, setOpen] = useState(initial)
  return {
    open,
    onOpen: useCallback(() => setOpen(true), []),
    onClose: useCallback(() => setOpen(false), []),
    onToggle: useCallback(() => setOpen(v => !v), []),
  }
}
```

## 3. Controlled / Uncontrolled (with sensible default)
Support both modes: controlled when a `value` prop is supplied, uncontrolled
(internal state) otherwise. Standard for inputs and any toggleable widget.

```tsx
function useControllable<T>(value: T | undefined, defaultValue: T, onChange?: (v: T) => void) {
  const [internal, setInternal] = useState(defaultValue)
  const isControlled = value !== undefined
  const current = isControlled ? value : internal
  const set = (v: T) => { if (!isControlled) setInternal(v); onChange?.(v) }
  return [current, set] as const
}
```

## 4. Headless Components
Ship behavior, state, and accessibility wiring with **no styling**; the consumer
renders the markup. Maximizes reuse across design systems (the model behind
Radix, Headless UI, React Aria). Often delivered as hooks returning prop getters.

```tsx
function useToggleButton(pressed: boolean, onChange: (v: boolean) => void) {
  return {
    getButtonProps: () => ({
      "aria-pressed": pressed,
      onClick: () => onChange(!pressed),
      type: "button" as const,
    }),
  }
}
```

## 5. Slots (children & named slots)
Compose layout by passing elements in, instead of booleans/config. Use `children`
for the main slot and named props (`header`, `footer`, `icon`) for fixed regions.

```tsx
function Card({ header, footer, children }: { header?: ReactNode; footer?: ReactNode; children: ReactNode }) {
  return (
    <section className="card">
      {header && <header>{header}</header>}
      <div className="card-body">{children}</div>
      {footer && <footer>{footer}</footer>}
    </section>
  )
}
```

## 6. Polymorphic Component (`as` prop)
One component renders as different elements/components while keeping typed props.
Use sparingly for primitives (Box, Text, Button-as-link).

```tsx
type PolymorphicProps<E extends ElementType> = { as?: E } & ComponentPropsWithoutRef<E>
function Text<E extends ElementType = "span">({ as, ...rest }: PolymorphicProps<E>) {
  const Tag = as ?? "span"
  return <Tag {...rest} />
}
// <Text as="a" href="/x">link</Text>
```

## 7. Render Props / Function-as-children
Expose internal state to the consumer's render logic. Largely superseded by hooks,
but still useful when the consumer must control rendering of variable structure.

```tsx
<Toggle>{({ on, toggle }) => <button onClick={toggle}>{on ? "On" : "Off"}</button>}</Toggle>
```

## 8. State Reducer
Let consumers intercept and override internal state transitions. Advanced; use
only when a component needs deep customization of its own behavior.

```tsx
function Toggle({ reducer = (s, a) => defaultReducer(s, a) }: { reducer?: Reducer<State, Action> }) { /* ... */ }
```

## 9. Provider Pattern
Share cross-cutting state (theme, auth, locale, toasts) via a context provider +
a typed `useX()` hook with a guard. Keep providers narrow and colocated; don't
funnel all app state through one mega-provider.

## 10. Container / Presentational (data vs view)
Separate components that fetch/derive data from components that only render props.
Keeps presentational components pure, easy to test, and reusable.

---

## Choosing a pattern
| Need | Reach for |
|------|-----------|
| Reuse non-visual logic | Custom hook |
| Grouped UI, one shared state | Compound components |
| Support `value` and uncontrolled | Controlled/uncontrolled hook |
| Reuse behavior across design systems | Headless + prop getters |
| Flexible layout regions | Slots / children |
| Same component, different element | Polymorphic `as` |
| Consumer overrides transitions | State reducer |
| Cross-cutting shared state | Provider + guarded hook |

## Anti-patterns
- Boolean prop explosion (`isPrimary`, `isLarge`, `hasIcon`, `isLoading`…) →
  prefer composition, variants, or slots.
- Premature abstraction: extract a pattern on the **second** real use, not the first.
- Context for everything: it re-renders all consumers; scope it or split it.
- Deeply nested render props ("callback pyramid") → use hooks instead.
