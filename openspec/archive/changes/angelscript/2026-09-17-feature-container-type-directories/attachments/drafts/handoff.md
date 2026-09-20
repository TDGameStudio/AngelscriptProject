# Handoff: container type directories and lengthened observations

Source draft: `openspec/drafts/angelscript/container-fixture-coverage/designs/container-pocket-rewrite/handoff.md` (Chinese original; approval R6).

## OpenSpec Handoff

- Scope: container-pocket-rewrite
- Target Change: angelscript/feature-container-type-directories

## Problem

Host-api flattened nine containers into `Containers/<Type>.as`. The filename names only the type. A `@begin` often disagrees with its body (`array` tests empty construction). Three TMap dumps risk C4883. Coverage is thin, but quality comes first, then each bind surface thickens on its own tree.

## Success

- One directory per type; lengthened Pascal observation leaves; one `@begin` per file.
- Polarity directories are only `CompileFail/` and `RuntimeFail/`.
- Corpus uses prefix `Containers/<Type>/` and can `Get(Containers/TArray/AddAndOrder, AddAndOrder)`.
- Hand-written moves and rewrites. No conversion scripts. Admission does not compile or execute AngelScript.

## Evidence

- [quality-debt.md](findings/quality-debt.md)
- [extended-names.md](findings/extended-names.md)
- [target-layout.md](findings/target-layout.md)
- [per-type-trees.md](findings/per-type-trees.md)
- [authoring-standard.md](findings/authoring-standard.md)
- [fail-siblings.md](findings/fail-siblings.md)
- [coverage-wave.md](findings/coverage-wave.md)

## Scope

Do: quality rewrite and bind-surface thickening for `TArray` `TMap` `TSet` `TOptional` `TSoftObjectPtr` `TWeakObjectPtr` `TSubclassOf` `TObjectPtr` `SoftObjectPath`; project them; publish prefix FileTags on host-api-fixtures; update the corpus.

Do not: Language / Unreal first-batch / a new `Math/` root; dump Pending; Bindings axis files; conversion scripts; reopen the parser.

## Constraints

- Author `.as` in English; Change records in English.
- One Change. Nine type tasks have no `depends_on` edges. Shared spec/corpus may sit on a join node.
- Fail follows Bind Throw only. `TSoftObjectPtr/RuntimeFail/` and SoftObjectPath Fail exist only with evidence.
- Trees follow each bind surface. Do not copy TArray leaves.

## Approach

Delete the flat pockets. Hand-write `Containers/<Type>/<Observation>.as`. Quality splits giant versions, renames, and repairs SYNTAX. Coverage adds the named begins on each type list.

## Alternatives and flip

- Keep flat FileTags: rejected at R4. If a single file hits C4883 again, stop and discuss; do not flatten.
- `TArrayAddAndOrder` prefix: rejected at R5. The directory already names the type.
- Two Changes: rejected at R4. Flip if parallel edits cannot share spec/cpp through a join.

## Failure

- Short leaves `add.as` or a flat `TArray.as` return.
- Last/Insert copied onto TMap/TSet.
- Scripts generate authors from Pending.
- Admission treated as AngelScript compile/execute.

## Verification

Per-type author parse tests go RED then GREEN. `codegen.py generate` / `check`. Corpus prefix and named `Get`.

## Exploration Carryover

Exported from the approved draft handoff. Required copies live beside this file.
