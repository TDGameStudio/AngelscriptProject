# One long Change, chapters in parallel

The user: a long Change is fine; subagents may run in parallel.

Ensure plan writes every chapter's `@begin` list first. After that, author chapters have no authoring dependency.

```
Ensure plan writes every chapter claim list
  │
  ├──────────────┬──────────────┬──────────────┬──────────────┐
  ▼              ▼              ▼              ▼              ▼
Auto           Class       Inheritance   Mixin/Dtor     Interface
  │              │              │              │              │
  ├──────────────┼──────────────┤              │              │
  ▼              ▼              ▼              ▼              ▼
Operators     ControlFlow     Syntax      Namespace      Casting/PP
  │              │              │              │              │
  └──────────────┴──────────────┴──────────────┴──────────────┘
                                │
                                ▼
                    one generate/check
                                │
                                ▼
                    spec / Skill / corpus join
```

## Why parallel is safe

Each chapter writes only its own tree: `Language/Auto/**`, `Language/Class/**`, `Language/Operators/**`.

Cross-chapter cases have one owner:

| Case | Owner |
|---|---|
| `invalid-auto-without-initializer` | Auto (moved off VariablesCompileFail) |
| `for (auto x : xs)` / foreach auto variable | Auto; ControlFlow/Foreach does not write it |
| ordinary `get_Value()` | Class methods |
| string literals split from Variables | Syntax chapter |

## Not parallel

- `codegen.py generate` writes Generated globally. Run once after every author chapter.
- `language-fixtures` spec, Skill, `LanguageFixtureCorpusTests.cpp`, Migration: join task only.
- Per-chapter parse tests may be local. Aggregate corpus assertions belong to the join.

## Task cards

Parallelism is many cards with few edges, not one vague "thicken Operators" card given to three agents. Every card still names every `@begin`.
