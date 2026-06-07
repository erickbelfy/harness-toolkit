---
id: typescript-style
description: TypeScript code style and conventions for .ts/.tsx files
globs: "*.ts,*.tsx"
alwaysApply: false
priority: 50
---
- Prefer `const` over `let`; never use `var`.
- Avoid `any`; prefer `unknown` plus explicit narrowing.
- Use discriminated unions over boolean flag soup.
- Keep modules single-purpose; export the minimum surface.
- Name async functions for what they return, not that they're async.
