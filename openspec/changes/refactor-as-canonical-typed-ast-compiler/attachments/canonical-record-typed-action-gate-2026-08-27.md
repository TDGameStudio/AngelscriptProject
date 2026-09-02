# Canonical class/interface record typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-12 — class/struct/interface header, base list and body-complete actions |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixture | two same-leaf-name bases in distinct namespaces plus a derived `struct` using an exact qualified base, followed by an incomplete method body |
| Sealed/construction-AST assertion | the derived declaration has VALUE kind/trait, records exactly the authored qualified base rather than a first-name candidate, exposes that base before body recovery fails, and has no generated lifecycle before the record body closes |
| Architecture assertion | `ParseClass()` and `ParseInterface()` use typed header/base/finish actions; neither calls `NotifySema(node)` or `ActOnParsedBaseSpecifiers`; generic completion excludes class/interface; `WalkOne` has no `case snClass:` or `case snInterface:` and the old record-node base decoder is absent |
| Expected RED | record headers and base lists still cross growing `snClass/snInterface` nodes; qualified base decoding takes the first recursive identifier and the completed declaration is replayed to synthesize lifecycle/accessors |
| Production edit allowed after RED | yes, limited to typed record header/base/finish ownership, exact qualified base resolution, PreClassData native-base completion and removal of record whole-node replay |

## Locked design

Parser continues to build `snClass`/`snInterface` only for the explicit LEGACY
oracle and syntax recovery. Canonical Sema receives three bounded phases:

1. after the authored name, a short-lived payload containing exact name/range
   and one syntax kind: class, struct or interface; Sema creates/reuses the
   declaration, owns nominal type kind/traits and returns its DeclId;
2. after the complete colon list and before entering the body, an ordered
   array of qualified base spellings and exact ranges; Sema resolves each
   spelling in the exact lexical/qualified scope, rejects ambiguity/wrong kind,
   records stable dependencies and then applies the existing PreClassData
   native-base rule only when no authored base exists;
3. after a real closing `}`, an explicit finish action synthesizes class
   lifecycle/accessors once. A forward/external `;` or recovery failure does
   not complete the record.

The typed base payload contains owned spelling/range facts only. It carries no
Parser node, AST pointer, Engine pointer, numeric TypeId or snapshot-local type
reference as durable identity.

## Transitional dependencies made explicit

- Class fields/properties, virtual properties and class-default statements
  retain their named declaration/statement adapters until their own slices.
- Interface virtual properties remain separate declaration-family work.
- Function members already use CTA-S-11 typed function actions.
- PreClassData is a build-only Runtime input to Sema; the AST retains only the
  projected stable base declaration/type identity.
- Parser-to-Builder shell identity may remain as an explicitly non-semantic
  bridge if current Runtime producer publication requires it. No record syntax
  may be decoded through that bridge.

## Required evidence

1. test-only build plus valid AST/architecture RED before production changes;
2. Runtime/Editor build after the bounded implementation;
3. focused qualified-base/early-recovery and architecture GREEN;
4. existing class/interface/struct/layout/inheritance/lifecycle regressions,
   complete SemaAuthority and ProductionCodeGen GREEN;
5. Parser declarations GREEN;
6. source scans, strict OpenSpec validation and parent/plugin
   `git diff --check`;
7. every invalid runner, product RED, root cause, repair and non-claim copied
   into the final issue/progress/task ledgers.

## Non-claims

- This does not complete general variable/property/type/lambda/expression/
  statement/lifetime action migration.
- This does not remove Parser syntax/recovery nodes from LEGACY.
- This does not prove complete detached CodeGen language coverage.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## RED and root cause

The test-only edit added two permanent SemaAuthority cases before production
code changed:

- `ParserRecordHeaderAndQualifiedBaseAreTypedBeforeBodyFails` uses
  `Wrong::Base`, `Right::Base` and an incomplete `struct Derived :
  Right::Base`. It requires the VALUE record and exact `Right::Base` edge to
  exist before body recovery fails, while generated lifecycle declarations
  must still be absent.
- `ParserRecordFamiliesUseTypedHeaderBaseAndFinishActionsWithoutReplay`
  scans the maintained source boundary and rejects record whole-node replay,
  the old base decoder and generic record completion.

The test-only Runtime/Editor build passed at
`Saved/Build/cta-record-typed-action-red-test-build/20260827_101850_939_05dd38df/RunMetadata.json`.
The valid full discovery run then produced the intended **315/317 PASS,
2 FAIL** at
`Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_101913_603_402b0d53/Report/index.json`.
There were no invalid zero-match runner attempts in this slice.

The root cause had three parts:

1. `ParseClass()` and `ParseInterface()` notified a growing record node after
   the name, then generic completion could notify the same record again.
2. `WalkOne(case snClass/snInterface)` reconstructed record kind, base edges,
   children and generated lifecycle/accessors from that syntax shell.
3. `RecordClassBases` recursively selected the first identifier child, so the
   authored qualified base `Right::Base` could be reduced to `Right` or bind
   through a wrong first-name fallback.

## Production repair

`as_sema.h` now exposes bounded record header, ordered base-specifier and
finish payloads. Parser emits the header immediately after the authored name,
binds only the already-created declaration identity to the transitional
Builder shell, publishes complete base spellings before entering the body and
publishes finish only after a real `}`. Forward `;` and recovery do not
synthesize completion.

Sema resolves qualified bases by complete stable key and lexical namespace
prefix, validates the entire ordered list before mutating the record, rejects
ambiguity/wrong-kind inputs, records stable dependencies, deduplicates exact
edges and applies `PreClassData` only when there is no authored base. Class
finish owns generated lifecycle/accessors; interface finish is an explicit
validated acted phase. `WalkOne` no longer contains `snClass` or
`snInterface`, and `ActOnParsedBaseSpecifiers`/`RecordClassBases` were removed.
The class funcdef child retains an explicit child-only adapter; fields,
defaults and general parameter/type/body actions remain separately inventoried
debt.

The first production Runtime/Editor build passed at
`Saved/Build/cta-record-typed-action-first-fix-build/20260827_103214_490_1144454a/RunMetadata.json`.
A static audit also found a stale `as_scriptengine.h` comment claiming that
CANONICAL was already the default even though
`ep.canonicalCompilerPipeline = false`; the comment was corrected to match the
transitional LEGACY default. This was documentation drift, not a behavior
change.

## Final verification

- exact qualified-base/early-recovery **1/1 PASS**:
  `Saved/Tests/cta-record-qualified-base-focused-green/20260827_103359_219_72ca3bc6/Report/index.json`;
- exact architecture **1/1 PASS**:
  `Saved/Tests/cta-record-architecture-focused-green/20260827_103433_049_9494a289/Report/index.json`;
- complete SemaAuthority **317/317 PASS**:
  `Saved/Tests/cta-record-sema-authority-green/20260827_103550_314_edb660f2/Report/index.json`;
- complete ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-record-production-codegen-green/20260827_103700_017_9e1bb3ac/Report/index.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-record-parser-declarations-green/20260827_103825_581_1cfc2df2/Report/index.json`.
- `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict`
  PASS; parent and plugin `git diff --check HEAD` both exit **0**. The diff
  checks emit existing LF/CRLF conversion notices only.

Source scans find zero `ActOnParsedBaseSpecifiers`, `RecordClassBases`,
`case snClass:` or `case snInterface:` in the Parser/Sema boundary. The
remaining direct `asCScriptNode` line inventory is declaration **94**,
expression **42**, statement **27**, and core Sema **3**; the meaningful
closure is removal of record semantic replay, not raw-token elimination.

CTA-S-12 is a verified bounded slice. It advances Tasks `4.2`, `4.3`, `4.4`
and `13.2`, but fields/properties/defaults/funcdefs, general type/parameter/
body actions, lambdas and expression/statement/lifetime replay keep those
umbrellas unchecked. Compiler default remains LEGACY and Cache V2 remains
default-disabled.
