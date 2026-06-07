---
name: software-architecture
description: Design stable system structure, boundaries, and interfaces. Use when shaping a new system or feature, defining module/service boundaries, choosing between approaches, designing APIs or data contracts, or recording an architectural decision. Emphasizes evolvability, clear contracts, and documented trade-offs.
license: MIT
metadata:
  discipline: architecture
  reference: addyosmani/agent-skills/api-and-interface-design,documentation-and-adrs
---
# Software Architecture

Design for change. Good architecture maximizes the number of decisions that can
be deferred or reversed cheaply, and makes the costly ones explicit and recorded.

## When to use
- Starting a new system, service, or significant feature.
- Defining boundaries between modules, services, or front/back end.
- Designing public APIs, data models, or contracts between components.
- Choosing among competing approaches with real trade-offs.
- Recording a decision others will need to understand later (write an ADR).

## Core principles

### Boundaries & coupling
- Draw boundaries around things that change together; keep what changes for
  different reasons in different modules (single responsibility at the seam).
- Depend on interfaces/contracts, not concrete implementations.
- Push policy (business rules) to the center; keep IO/frameworks at the edges.
- Prefer low coupling and high cohesion; minimize the surface each module exposes.

### Interface & contract design
- **Contract first**: define the interface before implementing it.
- **Hyrum's Law**: every observable behavior will be depended on — design and
  document the contract deliberately, and plan deprecation paths.
- Prefer addition over modification; extend with optional fields rather than
  breaking existing consumers. Aim for one supported version where feasible.
- Validate untrusted input at boundaries; trust internal calls.
- Consistent error semantics and naming across the whole surface.

### Data & state
- Make the source of truth explicit; avoid duplicating mutable state.
- Model invariants in the type system / schema where possible.
- Design for idempotency and retries in anything networked.

### Evolvability & risk
- Favor reversible decisions; spike to retire the riskiest unknown first.
- Choose boring, proven technology unless a requirement truly demands otherwise.
- Identify the few one-way-door decisions and give them extra scrutiny.

## Decision records (ADRs)
Record significant decisions as short ADRs: context, the decision, alternatives
considered, and consequences. One file per decision, immutable once accepted
(supersede rather than edit). Template: `references/adr-template.md`.

## Red flags
- Boundaries drawn around technical layers instead of behaviors.
- Bidirectional or cyclic dependencies between modules.
- Breaking changes shipped as silent modifications.
- "Temporary" coupling to a framework leaking into core logic.
- Big-bang rewrites instead of incremental, reversible steps.

## Verification checklist
- [ ] Boundaries map to reasons-to-change, not layers.
- [ ] Dependencies point inward (toward policy), no cycles.
- [ ] Public contracts are explicit, validated, and versioned/extensible.
- [ ] Error semantics and naming are consistent.
- [ ] Risky/one-way decisions identified and recorded as ADRs.
- [ ] The design can be delivered incrementally.
