# Handoff: reconstruct Language syntax by coverage

## OpenSpec Handoff

- Scope: syntax-coverage
- Target Change: angelscript/feature-language-syntax-coverage

## Problem

Admitted Language has two shapes and thin positives. 35 of 53 positive files have ≤5 `@begin` cases. The six second-wave themes hold 87 positives in six flat files. `Arithmetic` packs every operator into one case. `FunctionReturn` has two `return 42` cases. Directory versus file follows each live syntax's coverage. Cases thicken. Later subagents hand-write from lists. Do not script-merge Pending. This is a corpus reconstruction, not a move.

## Success

Scale: [real-scale.md](findings/real-scale.md). Hundreds of new or rewritten `@begin` cases. One Change. The Task DAG splits by chapter (a dozen-plus author nodes) plus projection and records. Chapters run in parallel: [parallel-dag.md](findings/parallel-dag.md).

- Retire the six flat second-wave FileTags and thicken each live-syntax chapter. Auto covers declaration sites, inference sources, qualifiers, and Fail — not only the current 11 cases. `Language/Auto` must not remain the representative Get.
- Thicken all 35 thin first-wave positives. Split mashup claims. Thicker pockets only gain real gaps.
- Write `Language/Interface/` as a chapter. Add `Syntax/FunctionModifiers` for `local` and `access` when needed.
- Every task lists every `@begin`. Fail follows the slice. No privileged `root`.
- Spec, Skill, corpus, second-wave author tests, Migration, and Generated all adopt the new identities.
- Run `codegen.py generate/check` only after authors exist. Admission is not compile or execute.

## Evidence

- [current-layout.md](findings/current-layout.md)
- [coverage-gaps.md](findings/coverage-gaps.md)
- [per-syntax-grain.md](findings/per-syntax-grain.md)
- [real-scale.md](findings/real-scale.md)
- [directory-options.md](findings/directory-options.md)
- [parallel-dag.md](findings/parallel-dag.md)

## Scope

Do: one Change `angelscript/feature-language-syntax-coverage`. Rewrite the six second-wave chapters. Thicken the 35 thin first-wave positives. Write the Interface chapter. Update every flat-identity consumer. Project after hand-writing.

Do not: positives or Fail for removed syntax (import, asset, funcdef, template, coroutine, shared/external, `property` decorator); Pending Properties / FString / EdgeCases / UClass; Python-generated authors; reopen `feature-language-second-wave-fixtures`; treat admission as execution.

## Constraints

- Author `.as` in English. Change records in English.
- FileTag is the path without `.as`. Choose a directory or a single file from coverage.
- Pocket format matches `Language/ControlFlow/If.as`. Pending is reading material only.
- Do not pad a type matrix. One claim, one complete body.
- `codegen.py` is not an author generator.

## Approach

```
1.x  Auto chapter
2.x  Class chapter
3.x  Inheritance chapter
4.x  Typedef chapter
5.x  Mixin chapter
6.x  Destructors chapter
7.x  Interface chapter + FunctionModifiers
8.x  Operators thin files
9.x  ControlFlow thin files
10.x Syntax thin files
11.x Namespace / Casting / Preprocessor thin files
12.  one generate/check + spec/Skill/corpus join
```

Ensure plan writes every chapter's `@begin` list first. Author chapters do not depend on each other. Subagents may take them in parallel. Density lives in the Change attachments, not in finishing Auto first.

`codegen.py generate`, spec, Skill, and corpus edit only after every author chapter finishes. Parallel tasks must not touch those shared files. Cross-chapter moves have one owner (see [parallel-dag.md](findings/parallel-dag.md)). A task titled "thicken Arithmetic" with no case table is invalid.

## Alternatives and flip

- Keep flat pockets: rejected at Q1. Flip: thickening still leaves one claim.
- Merge a directory into one FileTag: not chosen. Flip: discovery contract must change.
- Fail pockets for removed syntax: Q3 corrected to skip. Flip: a later Change may own removed syntax.
- Several Changes: Q7 then withdrawn at Q8. Long one Change with parallel chapters is accepted. Flip: shared files collide under parallel edits, or the DAG cannot be planned.

## Failure

- Script-merging Pending recreates mashups.
- Admitting Pending Properties as positives (decorator removed).
- Corpus still asserts exact `Language/Auto`.
- Tasks that omit the `@begin` list (subagents will under-write).
- `for (auto x : xs)` written only on Foreach.

## Verification

Author tests cover new FileTags with no privileged `root`. `codegen.py check` is synchronized. Corpus finds chapter representatives (`Language/Auto/…` and `Language/Interface/…`) and does not find the six retired flat names. Does not prove compile or run.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| glossary.md | attachments/drafts/glossary.md | Settled Change ID |
| ../../findings/current-layout.md | attachments/drafts/findings/current-layout.md | Two layout contracts |
| ../../findings/coverage-gaps.md | attachments/drafts/findings/coverage-gaps.md | Thin pockets and dirty Pending |
| ../../findings/per-syntax-grain.md | attachments/drafts/findings/per-syntax-grain.md | Per-syntax directory rule |
| ../../findings/real-scale.md | attachments/drafts/findings/real-scale.md | Honest corpus size |
| ../../findings/directory-options.md | attachments/drafts/findings/directory-options.md | Why not merge-dir FileTag |
| ../../log.md#r8 | attachments/talks/talk-20260917-172000-syntax-coverage-one-change.md | Full scale, one Change |
| ../../findings/per-syntax-grain.md | attachments/knowledges/per-syntax-directory-grain.md | Directory vs file depends on coverage |
| ../../findings/real-scale.md | attachments/knowledges/language-corpus-is-thin.md | Two-thirds of positives have ≤5 cases |
| ../../findings/parallel-dag.md | attachments/drafts/findings/parallel-dag.md | One Change; chapter tasks parallel; join on generate |
