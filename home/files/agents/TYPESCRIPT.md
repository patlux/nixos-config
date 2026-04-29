# TypeScript Rules

- Never use `any`
- Avoid `as ...` casts; use type guards, narrowing, unions, or constrained generics
- Never use double assertions like `as unknown as T`
- `as const` is allowed for literal inference
- Use `unknown` for uncertain input, then narrow before use
- Never prefix function calls with `void`
