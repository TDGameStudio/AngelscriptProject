# Coverage gaps (core syntax)

Compared with admitted pockets, leftover `Pending/Language/`, and keywords in `as_tokendef.h`. Admission is not compile or execute.

## Thin admitted pockets

Having a pocket is not coverage.

| Pocket | Positive `@begin` | Fail | Missing |
|---|---:|---:|---|
| `Language/Auto` | 11 | 6 | only bool/float/int/constructor locals. No auto in for/foreach, `auto&`, call inference, string/enum, `const auto`, multi-decl, fields |
| `Language/Syntax/Variables` | 4 | 10 | three cases are string literals. No globals, multi-declarators, width integers as a declaration theme |
| `Language/Syntax/FunctionReturn` | 2 | 4 | two `return 42` twins |
| `Language/Operators/Arithmetic` | 2 | 17 | one mashup `arithmetic` case; positives far thinner than Fail |
| `Language/Syntax/EmptyFunction` | 3 | 2 | narrow declaration surface |

`invalid-auto-without-initializer` lives on `Language/Syntax/VariablesCompileFail`, not Auto.

`Language/ControlFlow/Foreach` uses `for (int Value : Values)`, not `auto`.

## Live keywords with no theme pocket

Tokens still live in `as_tokendef.h` and the parser, with no admitted theme coverage:

- `interface`
- `access` / `local`
- contextual: `this` / `super` / `override` / `final` appear inside Class/Inheritance, not as their own directories

`funcdef` is commented out. Do not treat it as a gap.

Integer widths (`int8` / `uint16` / `float64`) appear only as passengers on parameters and returns.

## Pending leftovers that must not be absorbed wholesale

`Pending/Language/` has about 558 `.as` files.

| Folder | Files | Read as |
|---|---:|---|
| Auto / Class / Inheritance / Destructors / Typedef / Mixin | already adapted into flat pockets | not missing |
| Properties | 8 | host-free accessors, but the `property` decorator is removed |
| Const | 6 | mostly overlaps `Language/Syntax/Const` |
| Syntax/Function | 8 | arity / type / nested function / keyword names |
| Syntax/Keywords | 10 | half UClass/Blueprint |
| Syntax/Variable | 9 | Rejects already in VariablesCompileFail; one UClass file |
| Syntax/EdgeCases | 180 | not syntax (CVars, FBox, compile events) |
| Literals/FString | 69 | host API; keep out of Language |
| ControlFlow/Reject | 36 | likely already in first-wave CompileFail; compare by hand |

Coverage authority is the live keyword list plus thin admitted pockets. Pending one-concern host-free files are reading material only.

## Out of this Change

Removed syntax (import, asset, funcdef, template, coroutine, shared/external, `property` decorator): no positives and no Fail. Pending Properties, FString, EdgeCases, and UClass stay Pending.
