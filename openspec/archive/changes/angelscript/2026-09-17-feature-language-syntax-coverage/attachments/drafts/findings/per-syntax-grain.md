# Per-syntax grain: file versus directory, and how to thicken

Not one FileTag rule. Count independent claims after thickening.

## Rule

```
live syntax
├─ one family after thickening  →  single file (may stay under Syntax/)
└─ several claims / mashup      →  Language/<Theme>/<Slice>.as
   └─ Fail = same-slice CompileFail
```

Removed syntax is out of this Change (Q3 corrected).

FileTag still equals the path. Corpus queries use prefixes such as `Language/Auto/`.

## Six flat second-wave pockets

| Syntax | Now | Claims after thickening | Layout |
|---|---|---|---|
| Auto | 11 positives, all local literal/ctor | literal, call, loop, qualifier | `Language/Auto/` |
| Class | 22 positives in 547 lines | ctor, fields, methods, access, this | `Language/Class/` |
| Inheritance | 17 positives | override / super / final / multi-level | `Language/Inheritance/` |
| Typedef | 20 positives mixed by use | alias / field / handle / return / chain | `Language/Typedef/` |
| Mixin | 6 positives, all function mixins | receiver / default / call forms, still one family | `Language/Mixin/FunctionMixin.as` (small directory) |
| Destructors | 11 positives mixed | class / struct / base-derived | `Language/Destructors/` (two or three slices) |

## First wave: thicken in place

| Pocket | Positive now | Thicken |
|---|---:|---|
| `Syntax/Variables` | 4 (3 strings) | globals, multi-decl, width integers; strings may split to `Syntax/StringLiterals` |
| `Syntax/FunctionReturn` | 2 | more return shapes, void, value/ref |
| `Syntax/EmptyFunction` | 3 | declaration and empty-body edges |
| `Syntax/Parameters` | 21 | hand-write host-free Pending Function rejects; no script merge |
| `Operators/Arithmetic` | 2 / Fail 17 | one claim per operator; do not grow the Fail matrix |
| `ControlFlow/Foreach` | 5 | do not take Auto iterator cases |

Move `invalid-auto-without-initializer` onto the matching Auto Fail slice.

## Live additions versus removed syntax

| Form | Layout |
|---|---|
| `interface` | new `Language/Interface/` (declare / implement / handle + Fail) |
| `local` | `Language/Syntax/FunctionModifiers.as` |
| `access` | FunctionModifiers or Class access, split if it mashups |
| ordinary `get_Value()` | Class methods; never `Object.Value =` as a positive |

Do not write import / asset / funcdef / template / coroutine / shared / external / `property` decorator.

## Auto chapter density (hand-written)

See [real-scale.md](real-scale.md) for the claim tree. Ensure plan lists every `@begin`. Do not treat four files as done.
