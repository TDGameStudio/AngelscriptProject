---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

# Unify class defaults with constructors

## Goal

Remove class-body `default` syntax and the separate ClassDefault execution phase so class initialization uses member initializers and constructors, while default restoration and reload migration remain host responsibilities.

## Architecture

UE keeps ownership of UClass/CDO allocation and object lifecycle; the replacement script constructor binds to the host construction path, and the ClassDefault AST statement, implicit function generation and executable identity are removed once replacement consumers migrate. Bounded host restoration from the current CDO or archetype distinguishes explicit reset from reload migration. This Change has no `design.md` yet; producing it is the outcome of task 1.1.

## Global constraints

- This creation-only record captures the accepted rationale and intended feature outcome. The required tasks artifact contains one pending planning deliverable, not a fabricated implementation-ready DAG. Structural validation does not prove product readiness or completion.
- Product tasks must be added through the matching OpenSpec lifecycle after the construction/default-state contracts and replacement host prerequisites are concrete. No source mutation or UE execution belongs to record creation.
- Read this file and `attachments/INDEX.md` first, then `proposal.md` and the indexed source evidence.
- Preserve the existing constructor/VM, delegates, diagnostics and testing-framework owners; use the selected workspace and keep the legacy runtime dormant.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Class-body `default` forms reject with the dedicated migration diagnostic; `switch` labels and default arguments remain positive controls | 1.1 |
| Base-before-derived constructor initialization with construction-context permissions for migrated constructors only | 1.1 |
| New artifacts contain no ClassDefault executable; stale/incompatible serialized kinds reject deterministically | 1.1 |
| Script default, Blueprint subclass override and instance override survive creation/load paths; components are configured after they exist | 1.1 |
| Supported reset preserves object identity and does not alias CDO-owned components; unsupported state receives an explicit contract | 1.1 |
| Changed source defaults and constructor helpers regenerate defaults with defined reload-migration and reset behavior | 1.1 |
| Existing script examples migrate without redeclaring inherited properties; ordering changes have a manual-migration path | 1.1 |

Self-review 2026-09-11: syntax migration only; coverage and symbols unchanged from the original plan. Record: `attachments/data/planning-validation.md`.

## 1. Complete construction and migration planning

## [ ] 1.1 Produce the constructor-unification design, durable scenario deltas and bounded implementation DAG

**Files**

```diff
+openspec/changes/angelscript/refactor-defaults-constructor-unification/design.md
 openspec/changes/angelscript/refactor-defaults-constructor-unification/specs/**/spec.md
 openspec/changes/angelscript/refactor-defaults-constructor-unification/tasks.md
 openspec/changes/angelscript/refactor-defaults-constructor-unification/attachments/INDEX.md
+openspec/changes/angelscript/refactor-defaults-constructor-unification/attachments/data/planning-contracts.md
```

**Verification**

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-defaults-constructor-unification', '--type', 'change', '--strict', '--json')
```

Consume the accepted proposal and current maintained source. Produce concrete contracts and independently provable product cards without changing implementation or current durable specs. The specs glob owns only deltas for this proposal's affected capabilities; it excludes unrelated capabilities. Strict validation proves structure only; completion also requires every acceptance condition below to have an executable task and a resolved owner. The task remains incomplete while those artifacts or interfaces are missing.

1. Resolve actual replacement constructor, member initialization, reflected-type identification, UE construction and reload interfaces against the current VM Change and source. Identify missing replacement host prerequisites and give them bounded ownership in the new DAG rather than activating preserved services. Specify native/script/component/template initialization order for CDO creation, ordinary creation, loading and duplication. Preserve Blueprint and instance override semantics.
2. Define removed-syntax diagnostics and the treatment of `editdefaults`/`defaults` helper permissions, immediate versus escaping callbacks, constructor-unsafe APIs, implicit/base constructors and source migration. Define a deliberate retired-kind/format-revision strategy for AST, identity and executable artifacts. The endpoint contains no ClassDefault executable or hidden replacement replay hook.
3. Define the supported reset surface and source selection, object/subobject identity handling, script-only field participation and notification adapters. Separate explicit reset from reload migration and list unsupported state categories. Define how new defaults are regenerated after constructor/member/helper changes and when conservative rebuild is required. No universal arbitrary-object reset is required.
4. Write scenario deltas and group implementation cards around language/permissions, representation compatibility, replacement UE construction, reset/reload behavior and example migration. Each group owns exact files, interfaces, concrete cases, observed feature RED/GREEN and one exact Harness proving selection. Consult the verification policy and test guide at task-authoring time. Never substitute a planned API name or dormant-host execution for a replacement integration contract.
5. Map the following independently specified outcomes into the cards, validate the complete record, and index the planning-contract evidence. Only then complete this node; preserve its permanent ID when adding dependent product nodes.

Required acceptance examples for the future cards:

- Class-body `default Value = 25;` and `default { Value = 25; }` fail with the dedicated migration diagnostic and publish no executable. A `switch` default label and a function's omitted default argument remain positive controls.
- Base field Value=10 followed by derived constructor assignment Value=25 yields 25 with a literal base-before-derived trace. A migrated constructor can perform the intended configuration access, while an ordinary unrelated method and an escaping callback do not acquire that permission.
- New artifacts contain ordinary constructors and no ClassDefault executable; stale/incompatible serialized kinds reject deterministically rather than decoding as a neighboring enum value.
- A script class default of 10, a Blueprint subclass override of 30 and an explicitly saved instance override of 50 survive the applicable creation/load paths as 10/30/50. Component configuration occurs after the corresponding component exists.
- For an explicitly supported plain-data UObject, resetting modified values to its selected template preserves its address/identity. For supported owned components, reset does not replace an instance reference with the CDO-owned component pointer. Unsupported state receives the chosen explicit contract rather than a false complete-reset result.
- Changing a source default from 10 to 20 creates a new default state of 20. Reload migration follows the specified policy for inherited defaults and explicit overrides, whereas deliberate reset discards the selected override. A changed constructor helper also invalidates defaults or selects the documented conservative rebuild.
- Existing script examples migrate without redeclaring inherited properties. Historical post-constructor defaults ordering has an explicit manual-migration path when simple movement changes behavior.
