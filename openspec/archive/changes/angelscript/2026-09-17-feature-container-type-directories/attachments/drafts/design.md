# Accepted: container type directories and observation leaves

Status: designed (R6). Source draft: `openspec/drafts/angelscript/container-fixture-coverage/designs/container-pocket-rewrite/design.md` (Chinese original; approval R6).

Names: [glossary.md](glossary.md). Evidence: [quality-debt.md](findings/quality-debt.md), [extended-names.md](findings/extended-names.md), [target-layout.md](findings/target-layout.md), [per-type-trees.md](findings/per-type-trees.md).

## Problem

Host-api flattened nine container types into `Containers/<Type>.as`. The FileTag names only the type. Many `@begin` tags do not match the body (`array` asserts empty construction). TMap dumps risk C4883. Coverage is thin on a type-axis, but quality must come first.

## Accepted direction

- R1: quality rewrite, then thicken. Nine types in one wave. Hand-write `.as`. No conversion scripts.
- R2: split giant versions; keep existing in/out/type observations. Do not dump Pending. TMap missing-key `[]` always throws.
- R4: one directory per type. One Change. Nine type tasks with no inter-type edges.
- R5: lengthened Pascal observation leaves, no repeated type prefix (`AddAndOrder.as`).
- R6: the other eight types thicken too, but each tree follows that type's bind surface.

## Destination

```
AngelscriptTestCode/Containers/<Type>/<Observation>.as
AngelscriptTestCode/Containers/<Type>/CompileFail/<Observation>.as
AngelscriptTestCode/Containers/<Type>/RuntimeFail/<Observation>.as
```

FileTag is the path without `.as`. One parentless `@begin` per file; the tag equals the Pascal stem. Polarity directories are only `CompileFail/` and `RuntimeFail/`.

Corpus queries use prefixes such as `Containers/TArray/`. Exact `Containers/TArray` retires.

TArray tree: [target-layout.md](findings/target-layout.md). Other types: [per-type-trees.md](findings/per-type-trees.md). Author rules: [authoring-standard.md](findings/authoring-standard.md).

## Still open in implementation

`TSoftObjectPtr/RuntimeFail/` and SoftObjectPath Fail directories exist only when Bind Throw/Validate evidence exists.

## Out of scope

Language, Unreal first-batch, a new `Math/` root, Pending dumps, Bindings axis files, conversion scripts, parser reopen, AngelScript compile or execute claims.

## Call chain (author intent)

```
hand-write Containers/<Type>/<Observation>.as
  -> parse_source_file
  -> codegen.py generate
     -> TestCode/Generated/Containers/<Type>/<Observation>.generated.cpp
        -> Get(Containers/TArray/AddAndOrder, AddAndOrder)
```
