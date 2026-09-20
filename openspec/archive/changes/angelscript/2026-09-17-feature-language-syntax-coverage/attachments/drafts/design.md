# Live Language syntax coverage

Source: draft `angelscript/language-syntax-coverage` design `syntax-coverage`. Approval: R8 (full scale, one Change). Translated from Chinese.

## Problem

Admitted Language has two shapes. First-wave themes already live as directories (`Language/ControlFlow/If.as`). Second-wave themes were flattened to `Language/<Theme>.as`. `Auto.as` has 11 cases, all local literals or constructors. Variables, FunctionReturn, and Arithmetic are equally thin. The user wants directory-versus-file decided per live syntax from its coverage, and wants cases thickened. Later subagents hand-write from task lists. Do not script-merge Pending.

## Settled

- Q1: no single FileTag rule. Judge from how many independent claims remain after thickening.
- Q2: split the six flat themes and expand from a live-keyword checklist.
- Cases must thicken, not only move.
- Q3 corrected: removed syntax is out of this Change (positives and Fail).
- Q4 / Q8: one Change. Q7 split is withdrawn.
- Q5: `angelscript/feature-language-syntax-coverage`.
- Q6: write the handoff first; creation waited for an explicit ask.
- Long Change is acceptable. Chapter author tasks run in parallel.

## Judgment

```
live syntax
├─ still one family after thickening  →  one file (may stay under Syntax/Operators/ControlFlow)
└─ several claims / would mashup      →  Language/<Theme>/<Slice>.as
   └─ Fail = same-slice CompileFail, not one theme-wide Fail pocket
```

FileTag equals the path without `.as`. Flat `Language/Auto` retires. Corpus queries use the prefix `Language/Auto/`.

## This Change

This is a Language author-corpus reconstruction, not a folder move. See [real-scale.md](findings/real-scale.md).

1. Rewrite the six second-wave themes as full chapters (position / source / qualifier / Fail). Auto is a whole checklist, not four token files. Class, Inheritance, Typedef, Mixin, and Destructors use the same density.
2. Thicken every first-wave positive with ≤5 `@begin` cases (35 files). Split mashup claims such as `arithmetic`. Thicker pockets (Parameters, Return, Comments, Switch) only gain real gaps.
3. Add live gaps: `Language/Interface/` as a chapter; `Language/Syntax/FunctionModifiers` for `local` and `access` when needed.
4. Move misfiled cases (for example `invalid-auto-without-initializer`).
5. Retire flat FileTags in the spec, Skill, corpus, `test_second_wave_authors`, Migration, and Generated units.
6. Every task lists every `@begin`. Run `codegen.py generate/check` only after authors exist.

Ensure plan writes a dozen-plus author nodes that may run in parallel, then one generate join and one spec/corpus join. Do not collapse this into five empty tasks.

## Out of scope

- Positives or Fail for import, asset, funcdef, template, coroutine, shared/external, or the `property` decorator.
- Pending Properties, Literals/FString, Syntax/EdgeCases, UClass.
- Python scans that assemble `@begin` from Pending or Bindings.
- Reopening the `feature-language-second-wave-fixtures` design.
- Treating admission as compile or execute.

## Authoring for subagents

- One theme or first-wave slice per task. List FileTags and every `@begin` claim.
- Match `Language/ControlFlow/If.as`: `@version v1`, `@summary`, `@begin`, optional `@function`, no privileged `root`.
- Pending is reading material only. Rewrite it. Do not copy `@version root`.
- Do not pad a type matrix. One claim, one complete body.

## Auto chapter

Claim tree: [real-scale.md](findings/real-scale.md). Tasks list every `@begin` for position, source, qualifier, and Fail. The other five second-wave themes use the same density.

## Verification

- Authors parse with parentless `@begin` and no privileged `root`.
- `codegen.py check` matches hand-written authors.
- Corpus finds `Language/Auto/InferFromLiteral` and does not treat flat `Language/Auto` as the representative pocket.
- No removed-syntax assertions.
