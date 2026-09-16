---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": []
    "1.3": []
    "1.4": []
    "1.5": []
    "1.6": []
    "1.7": []
    "1.8": []
    "1.9": []
    "1.10": []
    "2.1": []
    "2.2": []
    "2.3": []
    "2.4": []
    "2.5": []
    "2.6": []
    "2.7": []
    "2.8": []
    "2.9": []
    "3.1": []
    "3.2": []
    "3.3": []
    "3.4": []
    "4.1": []
    "4.2": []
    "4.3": []
    "4.4": []
    "4.5": []
    "5.1": []
    "5.2": []
    "5.3": []
    "5.4": []
    "5.5": []
    "5.6": []
    "5.7": []
    "5.8": []
    "5.9": []
    "5.10": []
    "5.11": []
    "5.12": []
    "5.13": []
    "5.14": []
    "5.15": []
    "5.16": []
    "5.17": []
    "6.1": []
    "6.2": []
    "7.1": ["5.8"]
    "7.2": ["5.8"]
    "7.3": ["1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "1.10", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3.1", "3.2", "3.3", "3.4", "4.1", "4.2", "4.3", "4.4", "4.5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "5.10", "5.11", "5.12", "5.13", "5.14", "5.15", "5.16", "5.17", "6.1", "6.2", "7.1", "7.2"]
---

# Hand-authored Language fixture migration

## Goal

Deliver the complete accepted 47-container corpus and its queryable projections while retiring production Counter safely.

## Architecture

Author complete .as containers in the parent; explicitly project them to plugin C++; reuse the central catalog. See [design.md](design.md) and the [inventory](attachments/drafts/findings/container-inventory.md).

## Global constraints

- Legacy source is read-only evidence; no UClass/FString observer migration, import graphs or AS Builder/VM execution.
- Every file task is source-material migration, not a new C++ unit test. Its exact read-only command uses the same shared verifier; compatible files may share a documented batch. The only new corpus Automation method is the aggregate dump in task 7.3.
- Run commands from workspace root. For UE commands import Harness once and set $context = New-HarnessContext; build the current editor with ue.build before execution when C++ projections/tests changed.
- Explicit codegen generate is required after author edits; inspect its exact changes, preserve unrelated work, then run each named read-only proof. Shared per-theme migration records serialize writers within that theme.
- Keep version IDs stable; every retained scenario is traceable and every exclusion has a reason.
- Execution conventions: [.agents/skills/harness/references/execution-conventions.md](../../../../.agents/skills/harness/references/execution-conventions.md).

## Requirement coverage

| Requirement | Tasks |
|---|---|
| All 47 tags, source metadata and exact projections | 1.1 through 6.2 (inventory maps exact IDs); 7.3 |
| Complete positive/negative versions and provenance | All container tasks; 7.3 |
| Real StructFields adoption and production Counter retirement | 5.8; 7.1 |
| Accurate authoring guidance and lexical/host boundaries | All relevant containers; 7.2 |

Self-review 2026-09-15: all 47 tags have one owning task, additional integration/docs/acceptance work is bounded, and symbols/proofs are inspected. Record: attachments/data/planning-validation.md.

## [x] 1.1 Migrate Operators/Arithmetic as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Arithmetic/Function/ArithmeticOperators.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Arithmetic` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Arithmetic.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Arithmetic.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Arithmetic
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Arithmetic` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Arithmetic: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.2 Migrate Operators/Assignment as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Assignment/Function/AssignmentOperators.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Assignment` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Assignment.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Assignment.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Assignment
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Assignment` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Assignment: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.3 Migrate Operators/DefiniteAssignment as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Assignment/Function/BranchDefiniteAssignment.as`; `TestSource-old/Language/Operators/Assignment/Function/PartialDefiniteAssignment.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/DefiniteAssignment` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/DefiniteAssignment.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/DefiniteAssignment.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/DefiniteAssignment
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/DefiniteAssignment` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/DefiniteAssignment: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.4 Migrate Operators/Bitwise as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Bitwise/Function/BitwiseOperators.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Bitwise` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Bitwise.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Bitwise.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Bitwise
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Bitwise` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Bitwise: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.5 Migrate Operators/Comparison as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Comparison/Function/ComparisonOperators.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Comparison` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Comparison.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Comparison.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Comparison
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Comparison` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Comparison: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.6 Migrate Operators/Logical as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Logical/Function/LogicalOperators.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Logical` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Logical.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Logical.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Logical
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Logical` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Logical: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.7 Migrate Operators/Ternary as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Ternary/Function/TernaryOperators.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Ternary` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Ternary.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Ternary.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Ternary
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Ternary` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Ternary: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.8 Migrate Operators/Precedence as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Advance/ExpressionPrecedenceChains.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Precedence` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Precedence.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Precedence.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Precedence
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Precedence` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Precedence: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.9 Migrate Operators/ExpressionEdges as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Arithmetic/Function/ExpressionEdgeCases.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/ExpressionEdges` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/ExpressionEdges.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/ExpressionEdges.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/ExpressionEdges
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/ExpressionEdges` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/ExpressionEdges: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 1.10 Migrate Operators/Overload as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Operators/Overload/Function/FValCmpOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecAddAssignOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecAddOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecEqualsOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecMulOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecNegOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecSubOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecUsageOverload.as`; `TestSource-old/Language/Operators/Overload/Function/ScoreOperatorSuite.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Operators/Overload` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Operators/Overload.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Operators/Overload.generated.cpp
+AngelscriptTestCode/Language/Migration/Operators.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Overload
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Operators/Overload` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Operators/Overload: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Operators.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.1 Migrate ControlFlow/If as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/IfBasic.as`; `TestSource-old/Language/ControlFlow/Function/IfConditions.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/If` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/If.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/If.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/If
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/If` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/If: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.2 Migrate ControlFlow/IfElse as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/IfElseForms.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/IfElse` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/IfElse.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/IfElse.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/IfElse
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/IfElse` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/IfElse: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.3 Migrate ControlFlow/IfNested as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/IfNested.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/IfNested` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/IfNested.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/IfNested.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/IfNested
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/IfNested` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/IfNested: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.4 Migrate ControlFlow/While as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/DoWhileLoop.as`; `TestSource-old/Language/ControlFlow/Function/WhileLoop.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/While` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/While.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/While.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/While
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/While` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/While: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.5 Migrate ControlFlow/DoWhile as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/DoWhileLoop.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/DoWhile` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/DoWhile.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/DoWhile.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/DoWhile
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/DoWhile` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/DoWhile: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.6 Migrate ControlFlow/Switch as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/SwitchBasic.as`; `TestSource-old/Language/ControlFlow/Function/SwitchBreak.as`; `TestSource-old/Language/ControlFlow/Function/SwitchEnum.as`; `TestSource-old/Language/ControlFlow/Function/SwitchIntegerTypes.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/Switch` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/Switch.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/Switch.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/Switch
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/Switch` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/Switch: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.7 Migrate ControlFlow/LoopJump as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/BreakInLoop.as`; `TestSource-old/Language/ControlFlow/Function/ContinueInLoop.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/LoopJump` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/LoopJump.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/LoopJump.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/LoopJump
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/LoopJump` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/LoopJump: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.8 Migrate ControlFlow/Return as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/FMatrixReturnApi.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnBoolValues.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnControlFlow.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnFloatValues.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnIntegerWidths.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnQuatValues.as`; `TestSource-old/Language/ControlFlow/Function/GeometricStructParametersAndReturns.as`; `TestSource-old/Language/ControlFlow/Function/MultipleReturns.as`; `TestSource-old/Language/ControlFlow/Function/ReturnEarly.as`; `TestSource-old/Language/ControlFlow/Function/ReturnExpression.as`; `TestSource-old/Language/ControlFlow/Function/ReturnFloatAsInt.as`; `TestSource-old/Language/ControlFlow/Function/ReturnInt.as`; `TestSource-old/Language/ControlFlow/Function/ReturnVoid.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/Return` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/Return.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/Return.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/Return
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/Return` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/Return: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 2.9 Migrate ControlFlow/Foreach as complete source material

Rewrite the accepted concern from `TestSource-old/Language/ControlFlow/Function/ForeachBreakContinue.as`; `TestSource-old/Language/ControlFlow/Function/ForeachContainerMutation.as`; `TestSource-old/Language/ControlFlow/Function/ForeachValueReference.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/ControlFlow/Foreach` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. Replace host collection dependencies with the script protocol source shape; do not rewrite foreach into ordinary for merely to avoid its protocol.

**Files**

```diff
+AngelscriptTestCode/Language/ControlFlow/Foreach.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ControlFlow/Foreach.generated.cpp
+AngelscriptTestCode/Language/Migration/ControlFlow.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/Foreach
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/ControlFlow/Foreach` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/ControlFlow/Foreach: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/ControlFlow.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 3.1 Migrate Casting/NumericImplicit as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Casting/Function/ImplicitBoolToInt.as`; `TestSource-old/Language/Casting/Function/ImplicitDerivedToBase.as`; `TestSource-old/Language/Casting/Function/ImplicitFloatToInt.as`; `TestSource-old/Language/Casting/Function/ImplicitFloatToUint8.as`; `TestSource-old/Language/Casting/Function/ImplicitInt64ToInt.as`; `TestSource-old/Language/Casting/Function/ImplicitIntToFloat.as`; `TestSource-old/Language/Casting/Function/ImplicitIntToInt64.as`; `TestSource-old/Language/Casting/Function/ImplicitLiteralToFloat.as`; `TestSource-old/Language/Casting/Function/ImplicitUint8ToInt.as`; `TestSource-old/Language/Casting/Function/NumericEnumAndStringConversions.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Casting/NumericImplicit` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Casting/NumericImplicit.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Casting/NumericImplicit.generated.cpp
+AngelscriptTestCode/Language/Migration/Casting.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/NumericImplicit
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/NumericImplicit` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Casting/NumericImplicit: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Casting.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 3.2 Migrate Casting/NumericExplicit as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Casting/Function/ExplicitFloatToInt.as`; `TestSource-old/Language/Casting/Function/ExplicitIntToFloat.as`; `TestSource-old/Language/Casting/Function/ExplicitIntToUint8.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Casting/NumericExplicit` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Casting/NumericExplicit.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Casting/NumericExplicit.generated.cpp
+AngelscriptTestCode/Language/Migration/Casting.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/NumericExplicit
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/NumericExplicit` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Casting/NumericExplicit: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Casting.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 3.3 Migrate Casting/Nullptr as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Casting/Function/CastNullptrIsNull.as`; `TestSource-old/Language/Casting/Function/NullptrComparison.as`; `TestSource-old/Language/Casting/Function/NullptrHandleAssignment.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Casting/Nullptr` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Casting/Nullptr.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Casting/Nullptr.generated.cpp
+AngelscriptTestCode/Language/Migration/Casting.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/Nullptr
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/Nullptr` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Casting/Nullptr: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Casting.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 3.4 Migrate Casting/ClassCast as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Casting/Function/CastDowncast.as`; `TestSource-old/Language/Casting/Function/CastRoundTripWithNullCheck.as`; `TestSource-old/Language/Casting/Function/CastToParentClass.as`; `TestSource-old/Language/Casting/Function/ImplicitDerivedToBase.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Casting/ClassCast` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Casting/ClassCast.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Casting/ClassCast.generated.cpp
+AngelscriptTestCode/Language/Migration/Casting.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/ClassCast
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Casting/ClassCast` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Casting/ClassCast: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Casting.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 4.1 Migrate Namespace/QualifiedName as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Namespace/Function/NamespaceQualifiedCall.as`; `TestSource-old/Language/Namespace/Function/NamespaceQualifiedName.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Namespace/QualifiedName` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Namespace/QualifiedName.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Namespace/QualifiedName.generated.cpp
+AngelscriptTestCode/Language/Migration/Namespace.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/QualifiedName
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/QualifiedName` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Namespace/QualifiedName: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Namespace.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 4.2 Migrate Namespace/Nested as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Namespace/Function/NamespaceNestedAccess.as`; `TestSource-old/Language/Namespace/Function/NamespaceNestedScope.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Namespace/Nested` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Namespace/Nested.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Namespace/Nested.generated.cpp
+AngelscriptTestCode/Language/Migration/Namespace.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/Nested
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/Nested` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Namespace/Nested: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Namespace.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 4.3 Migrate Namespace/GlobalVersusScoped as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Namespace/Function/NamespaceGlobalVersusScoped.as`; `TestSource-old/Language/Namespace/Function/NamespaceScopedGlobal.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Namespace/GlobalVersusScoped` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Namespace/GlobalVersusScoped.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Namespace/GlobalVersusScoped.generated.cpp
+AngelscriptTestCode/Language/Migration/Namespace.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/GlobalVersusScoped
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/GlobalVersusScoped` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Namespace/GlobalVersusScoped: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Namespace.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 4.4 Migrate Namespace/Shadowing as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Namespace/Function/NamespaceScopeShadowing.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Namespace/Shadowing` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Namespace/Shadowing.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Namespace/Shadowing.generated.cpp
+AngelscriptTestCode/Language/Migration/Namespace.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/Shadowing
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/Shadowing` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Namespace/Shadowing: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Namespace.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 4.5 Migrate Namespace/Enum as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Namespace/Function/NamespaceWithEnum.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Namespace/Enum` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Namespace/Enum.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Namespace/Enum.generated.cpp
+AngelscriptTestCode/Language/Migration/Namespace.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/Enum
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Namespace/Enum` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Namespace/Enum: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Namespace.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.1 Migrate Syntax/Comments as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/Comments/Function/BlockCommentBeforeFunction.as`; `TestSource-old/Language/Syntax/Comments/Function/BlockCommentWithSeparateMarkers.as`; `TestSource-old/Language/Syntax/Comments/Function/CommentBeforeFunction.as`; `TestSource-old/Language/Syntax/Comments/Function/DocumentationComment.as`; `TestSource-old/Language/Syntax/Comments/Function/InlineCommentInsideFunction.as`; `TestSource-old/Language/Syntax/Comments/Function/MultiLineBlockComment.as`; `TestSource-old/Language/Syntax/Comments/Function/SingleLineComment.as`; `TestSource-old/Language/Syntax/Comments/Function/TrailingBlockCommentImportConsumer.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Comments` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Comments.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Comments.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Comments
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Comments` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Comments: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.2 Migrate Syntax/EmptyFunction as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/EmptyFunctionBodyCompiles.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/EmptyVoidFunction.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/EmptyFunction` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/EmptyFunction.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/EmptyFunction.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/EmptyFunction
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/EmptyFunction` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/EmptyFunction: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.3 Migrate Syntax/FunctionReturn as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/IntReturnFunction.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/FunctionReturn` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/FunctionReturn.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/FunctionReturn.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/FunctionReturn
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/FunctionReturn` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/FunctionReturn: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.4 Migrate Syntax/DefaultParameters as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/BoolDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/DefaultParameterFunction.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionDefaultParameterEdges.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyDefaultParameters.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/DefaultParameters` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/DefaultParameters.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/DefaultParameters.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/DefaultParameters
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/DefaultParameters` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/DefaultParameters: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.5 Migrate Syntax/Overload as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/BoolIntOverloadResolution.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatDoubleOverloadResolution.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionOverloadArityAndNumericResolution.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntWidthOverloadResolution.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/VoidOverloadSet.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Overload` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Overload.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Overload.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Overload
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Overload` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Overload: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.6 Migrate Syntax/NamedArguments as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/NamedArgumentsMixedPartialOrder.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/NamedArguments` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/NamedArguments.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/NamedArguments.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/NamedArguments
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/NamedArguments` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/NamedArguments: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.7 Migrate Syntax/Parameters as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/BoolDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/BoolInOutParameter.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/BoolOutParameter.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/BoolReferenceInParameter.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/BoolValueParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/DefaultParameterFunction.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatInOutParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatOutParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatReferenceInParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FloatValueParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatInOutParameter.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatOutParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatReferenceInParameter.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatValueParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionDefaultParameterEdges.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionParametersMultipleOut.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyDefaultParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyInOutParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyOutParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyReferenceInParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyValueParameters.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/ParameterlessMappingGettersDispatchWithNativeParity.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/ReferenceWriteParameter.as`; `TestSource-old/Language/Syntax/Reference/Function/FunctionReferenceParameterCombinations.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Parameters` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Parameters.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Parameters.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Parameters
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Parameters` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Parameters: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.8 Migrate Syntax/StructFields as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/BasicScriptStruct.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/StructMemberDefaults.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/StructFields` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. Provide exactly the root/add-field/invalid-duplicate-field integration shapes and annotation names fixed in design.md; preserve that byte contract for task 7.1.

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/StructFields.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/StructFields.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructFields
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructFields` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/StructFields: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.9 Migrate Syntax/StructConstructors as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstructors.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/StructConstructors` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/StructConstructors.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/StructConstructors.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructConstructors
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructConstructors` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/StructConstructors: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.10 Migrate Syntax/StructConst as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstMethod.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstReaderMethod.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstructors.as`; `TestSource-old/Language/Syntax/Keywords/Function/ConstMethodOnStruct.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/StructConst` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/StructConst.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/StructConst.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructConst
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructConst` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/StructConst: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.11 Migrate Syntax/Enum as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/BasicEnumValues.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/EmptyEnumDeclaration.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/EnumAvailability.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/EnumExplicitValues.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/EnumLocalUsage.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/UEnumReflection.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/UEnumWithoutPrefixNaming.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Enum` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Enum.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Enum.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Enum
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Enum` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Enum: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.12 Migrate Syntax/ForClauses as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/ForBasicShapes.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/ForCommaClauses.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/ForOmittedClauses.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/ForPositiveSyntaxForms.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/ForClauses` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/ForClauses.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/ForClauses.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/ForClauses
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/ForClauses` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/ForClauses: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.13 Migrate Syntax/ForNested as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/ForNestedLoops.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/ForNested` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/ForNested.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/ForNested.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/ForNested
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/ForNested` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/ForNested: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.14 Migrate Syntax/Variables as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/Variable/Function/PrimitiveAndReferenceLocals.as`; `TestSource-old/Language/Syntax/Variable/Function/ScopeVariables.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Variables` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Variables.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Variables.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Variables
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Variables` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Variables: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.15 Migrate Syntax/Const as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/ConsoleCommandStringConstructionCompileBoundary.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstMethod.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstReaderMethod.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstructors.as`; `TestSource-old/Language/Syntax/Keywords/Function/ConstMethodOnStruct.as`; `TestSource-old/Language/Syntax/Reference/Function/ConstValuesMethodsAndReferences.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Const` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Const.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Const.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Const
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Const` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Const: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.16 Migrate Syntax/References as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/ReferenceWriteParameter.as`; `TestSource-old/Language/Syntax/Reference/Function/FunctionReferenceParameterCombinations.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/References` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/References.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/References.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/References
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/References` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/References: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 5.17 Migrate Syntax/Blocks as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Syntax/EdgeCases/Function/DeeplyNestedBlocks.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/DeeplyParenthesizedAddition.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/LongChainedAddition.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/MultipleStatementsInOneFunction.as`; `TestSource-old/Language/Syntax/EdgeCases/Function/ShortCircuitSkipsRightHandSide.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Syntax/Blocks` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Syntax/Blocks.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/Blocks.generated.cpp
+AngelscriptTestCode/Language/Migration/Syntax.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Blocks
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/Blocks` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Syntax/Blocks: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Syntax.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 6.1 Migrate Preprocessor/IfElifElse as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Preprocessor/Function/EditorConfigurationFlagBranch.as`; `TestSource-old/Language/Preprocessor/Function/IfElifElseEndifBranches.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Preprocessor/IfElifElse` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. 

**Files**

```diff
+AngelscriptTestCode/Language/Preprocessor/IfElifElse.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Preprocessor/IfElifElse.generated.cpp
+AngelscriptTestCode/Language/Migration/Preprocessor.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Preprocessor/IfElifElse
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Preprocessor/IfElifElse` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Preprocessor/IfElifElse: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Preprocessor.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 6.2 Migrate Preprocessor/DirectiveInString as complete source material

Rewrite the accepted concern from `TestSource-old/Language/Preprocessor/Function/StringLiteralDoesNotTriggerDirectiveLexer.as`. Read the [inventory](attachments/drafts/findings/container-inventory.md) and current design boundaries; inspect related negative sources in the owning theme.

**Outcome**

`Language/Preprocessor/DirectiveInString` exists with a parentless root, complete source bodies, valid v1 metadata and a matching structured projection. Retain each relevant positive/negative scenario using the stable version naming policy, remove observation wrappers, and record retained/merged/adapted/excluded provenance. Use the explicit SourceOnly lexical boundary; remove FString observer APIs without claiming executable string support.

**Files**

```diff
+AngelscriptTestCode/Language/Preprocessor/DirectiveInString.as
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Preprocessor/DirectiveInString.generated.cpp
+AngelscriptTestCode/Language/Migration/Preprocessor.md
```

The theme record is shared with other tasks in this theme; create once, then append owned dispositions without overwriting other entries. Its Markdown is not a public FileTag or a generated source.

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Preprocessor/DirectiveInString
```

This read-only check must find the exact source, parse its complete version tree and compare its exact current structured C++ projection. Independently inspect that retained source statements match the named concern; no language execution is claimed.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Preprocessor/DirectiveInString` after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. Result: `Language/Preprocessor/DirectiveInString: complete container and exact structured projection passed`. Disposition recorded in `AngelscriptTestCode/Language/Migration/Preprocessor.md`. Omitted UE Automation and AS compile/execute: source-material admission only.

## [x] 7.1 Replace the production Counter integration fixture

After task 5.8, adopt the real StructFields container in global database tests and retire only the production Counter source/projection.

**Outcome**

GeneratedSources and Adoption tests query StructFields; parser-tool Counter tests retain their own annotated fixture; production Counter is absent. Retain source-byte, annotation-offset, origin-map, metadata and structured-registration checks.

**Interfaces**

Consumes the inspected Framework/Catalog/AngelscriptTestCode.h:23-34 API and StructFields from task 5.8; produces no new runtime API. Existing test identities remain GeneratedSources and Adoption. Adapt existing methods and assertions only; the Cases below describe retained coverage, not requests to add new test methods.

```cpp
static FAngelscriptTestCode& GetInstance();
FAngelscriptTestSourceResult Get(FStringView FileTag, FStringView VersionTag) const;
// New inputs: Language/Syntax/StructFields, root, add-field, invalid-duplicate-field.
```

**Cases**

1. **Real fixture and independent child** — new RED
   Get StructFields/root and add-field around repeated child reads; compare complete source to independently authored literals for X=0, Y=0.0f and added Z=1. Parent remains root. Root/child metadata share the file truth and retain distinct node summaries/topics.
2. **Annotation proof survives replacement** — new RED
   Assert initial-value at root's 0, before-add at the child Z declaration and delta spanning its 1. Compute literal expected clean/authored byte offsets from the designed fixture independently; do not retain Counter offsets or derive the oracle from the queried source itself.
3. **Private parser fixture survives public removal** — existing control
   Preserve the current annotated production Counter bytes in CodeGenTool/tests/fixtures/parser/Language/Counter.as before deletion. Redirect both filesystem reads in test_source_parser.py to it. Existing parser annotation/topology cases still pass with the original logical Language/Counter test identity.
4. **Public Counter absent, generated activation unchanged** — new RED
   Get Language/Counter/root fails, while StructFields succeeds and registration errors remain empty. Inspect StructFields.generated.cpp for structured format=v2 registration and absence of runtime SourceParser activation. JIT/secondary provider center identity checks remain in Adoption.

**Files**

```diff
-AngelscriptTestCode/Language/Counter.as
-Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Counter.generated.cpp
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/GeneratedSourcesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/AdoptionTests.cpp
 AngelscriptTestCode/CodeGenTool/tests/test_source_parser.py
+AngelscriptTestCode/CodeGenTool/tests/fixtures/parser/Language/Counter.as
```

**Verification**

```powershell
python -m unittest discover -s AngelscriptTestCode/CodeGenTool/tests -p test_source_parser.py
if ($LASTEXITCODE -ne 0) { throw 'Parser fixture regression failed' }
$generated = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.GeneratedSources'; Fast = $true; TimeoutMs = 600000 }
if ($generated.exitCode -ne 0) { throw 'GeneratedSources failed' }
$adoption = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Adoption'; Fast = $true; TimeoutMs = 600000 }
if ($adoption.exitCode -ne 0) { throw 'Adoption failed' }
```

Require all exact tests to execute and pass with a current editor binary; then record codegen synchronization. Do not rename synthetic Counter inputs in unrelated isolated tests.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. `python -m unittest discover -s AngelscriptTestCode/CodeGenTool/tests -p test_source_parser.py` OK (6 tests). After `ue.build` run `a5b3a34ce39743568b0146fcf758ea03` Succeeded, `ue.test` GeneratedSources run `f48e31d5d7a94433bbd18e23dd9141e9` Succeeded: GeneratedFixture, GeneratedChildRemainsDirectlyAddressable, RegistrationAndCaseMetadataHaveOneTruth, GeneratedActivationHasNoParserDependency all Success. Adoption run `5a206cd9a3864a66a963f2c493b22b4f` Succeeded: TwoModulesOneCenter, VersionReads, ReplacementOnly all Success. Production Counter source/projection removed; parser fixture preserved at `CodeGenTool/tests/fixtures/parser/Language/Counter.as`. `codegen.py check` synchronized. Naming assumed: colliding UBT leaves `Enum.generated.cpp` and `Overload.generated.cpp` are uniquified to `Language_<Theme>_<Name>.generated.cpp` while FileTags stay `Language/Syntax/Enum`, `Language/Namespace/Enum`, `Language/Syntax/Overload`, and `Language/Operators/Overload`. Omitted Quick/Performance/Integration/full suite: existing GeneratedSources and Adoption prefixes are the specified proof.

## [x] 7.2 Update authoring guidance to real fixtures and structured projection

Replace production Counter examples with the exact StructFields contract and correct stale projection-layer descriptions.

**Outcome**

Skill examples resolve to real author paths, describe complete positive/negative versions, and accurately state that current Python parsing emits structured C++ Builder registration rather than runtime source-parser activation. No workflow or parser implementation changes.

**Files**

```diff
 .agents/skills/angelscript-test/SKILL.md
 .agents/skills/angelscript-test/references/test-code-database.md
```

**Verification**

```powershell
python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructFields
if ($LASTEXITCODE -ne 0) { throw 'Documented fixture is not synchronized' }
$guide = Get-Content .agents/skills/angelscript-test/references/test-code-database.md -Raw
if ($guide.Contains('Language/Counter') -or $guide.Contains('Python does not interpret metadata')) { throw 'Stale production example or projection contract' }
```

Inspect every shown query/topic/version against the admitted fixture and the current API. Keep general parser-fixture concepts distinct from production examples.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructFields` passed versions=3. Guide check: test-code-database.md contains neither Language/Counter nor "Python does not interpret metadata". Examples now use Language/Syntax/StructFields root/add-field/invalid-duplicate-field and describe structured format=v2 Builder registration. SKILL.md points at that production fixture. Omitted UE run: documentation-only proving command.

## [x] 7.3 Dump and compare the complete hand-authored catalog

Implement the aggregate round-trip contract in design.md and the indexed round-trip talk. Add one C++ dump method and one automated comparison operation for the whole corpus.

**Outcome**

The complete compiled Language catalog is dumped into one Actual.as. Independent Python parsing of the migrated author sources produces Expected.as. All 47 FileTags and every declared version match by identity, current metadata/typed annotations and exact clean-source bytes; Comparison.json records the concrete run and differences. Production Counter is absent. Source migration disposition records cover the legacy census. No new per-container C++ tests or manually duplicated full-library expected literals are introduced.

**Interfaces**

Consumes existing FAngelscriptTestCode GetInstance/FindFiles/FindCases/GetRegistrationErrors and source GetBytes, existing Python discovery/container_parser APIs, and Harness ue.build/ue.test. Produces one CQTest class LanguageFixtureCorpus with one method DumpsAllAuthoredSources, plus two local verification tools. No public database dump API or generator dependency is added.

```cpp
// TestDir: Angelscript.UnitTest.Framework
// Class: LanguageFixtureCorpus
// TEST_METHOD(DumpsAllAuthoredSources)
// Enumerate the actual catalog and write its exact source bytes only.
```

**Cases**

1. **Complete round-trip** — new RED
   One dump method includes every Language file and version, without filtering negatives or SourceOnly. The driver compares independent authored clean-source expectations with actual database bytes and requires the exact 47-file inventory and complete version set. Use byte-length framing with JSON-escaped metadata headers, ordinal ordering and the run-local three-artifact output contract in design.md. Reuse current parser tag/escape/normalization rules; author v1 and carrier format=v2 are distinct.
2. **Corruption and omission are rejected** — new RED
   Exercise the comparison helper on temporary copies with one version omitted, one unexpected identity, one modified byte, a changed topic/parent or annotation offset, and a missing dump. Each must fail and identify the relevant mismatch. Restore copies and prove the original corpus passes using the same aggregate command. Do not add separate C++ fixture tests for these controls.
3. **Current compiled registration is observed** — new RED
   Registration/query errors, a nonexecuted test, stale artifacts and source changes during the captured run fail. Actual.as is written from GetSource().GetBytes() in the current compiled database, never reread author files. The missing production Counter is visible in the compared identity set. Existing task 7.1 retains annotation and provider-identity regression checks.
4. **Migration source census is closed** — source evidence
   Record retained/merged/adapted/excluded disposition for every inspected legacy source and destination identities for retained material. This document check stays in closure evidence; it is not an additional Automation method.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/LanguageFixtureCorpusTests.cpp
+AngelscriptTestCode/CodeGenTool/verify_language_roundtrip.ps1
+AngelscriptTestCode/CodeGenTool/language_roundtrip.py
+AngelscriptTestCode/Language/Migration/README.md
 AngelscriptTestCode/Language/Migration/Operators.md
 AngelscriptTestCode/Language/Migration/ControlFlow.md
 AngelscriptTestCode/Language/Migration/Casting.md
 AngelscriptTestCode/Language/Migration/Namespace.md
 AngelscriptTestCode/Language/Migration/Syntax.md
 AngelscriptTestCode/Language/Migration/Preprocessor.md
```

**Verification**

```powershell
& ./AngelscriptTestCode/CodeGenTool/verify_language_roundtrip.ps1 -Context $context
```

This planned driver runs in the current PowerShell process, uses the existing Harness for the current build and the exact Angelscript.UnitTest.Framework.LanguageFixtureCorpus.DumpsAllAuthoredSources selector, then requires a successful independent byte comparison. Capture source fingerprints before the run and validate them afterwards. It must throw on failed/pending operations, missing exact executed-case evidence or comparison failure. Expected.as, Actual.as and Comparison.json belong to HandwrittenCorpus beside that exact run's Unreal.log. Preserve artifacts on failure. The driver and Python helper are implementation deliverables of this task and do not exist at replan time.

Document the bounded negative controls and the source census check in Evidence. No additional per-file C++ unit tests or AS compilation/execution tests are required for this migration.

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Proving command `& ./AngelscriptTestCode/CodeGenTool/verify_language_roundtrip.ps1 -Context $context` succeeded. Self-test rejected omitted version, unexpected identity, flipped byte, changed topic, and missing dump, then accepted the identical baseline. `ue.test` run `27d3dbbef4c5497b988834caa1b4da59` executed `Angelscript.UnitTest.Framework.LanguageFixtureCorpus.DumpsAllAuthoredSources` state Success. HandwrittenCorpus beside that run's Unreal.log: Expected.as, Actual.as, Comparison.json; comparison `passed=true` files=47 versions=116 missing=[] extra=[] `has_production_counter=false`; expected and actual SHA-256 both `ed975e5a691aa581adf53613029463011a5f5198db26fdd7cff39f4330dae0cb`. Source snapshot unchanged across the run. Census of all 624 `TestSource-old/Language` files is in `AngelscriptTestCode/Language/Migration/README.md`. Omitted Quick/Performance/Integration/AS compile/execute: dump and byte comparison only.
