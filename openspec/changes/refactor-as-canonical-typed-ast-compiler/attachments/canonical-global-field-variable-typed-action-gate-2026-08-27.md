# Canonical global/field variable typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-13 — top-level/namespace globals and class/struct field declarators |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixture | one two-declarator global statement plus one private two-declarator struct field statement, followed by an incomplete method body |
| Sealed/construction-AST assertion | every authored declarator exists exactly once under the exact owner before later recovery fails; each retains canonical type, access trait and its own initializer value |
| Architecture assertion | global/class `ParseDeclaration` publishes a typed header per declarator and an explicitly named initializer adapter; generic top-level completion and `ParseClass` do not notify the whole `snDeclaration`; `WalkOne(case snDeclaration)` is local-statement-only |
| Expected RED | the current declaration replay uses `FirstChildOfType(snIdentifier)` and therefore reconstructs only the first declarator; class access traits are not explicit typed facts |
| Production edit allowed after RED | yes, limited to global/field per-declarator header/initializer ownership, access traits, exact owner/type/range and removal of global/field whole-node replay |

## Locked design

Parser continues to build `snDeclaration` for the LEGACY oracle and recovery.
For `isGlobalVar` or `isClassProp`, Canonical Sema instead receives a bounded
phase for each declarator:

1. after its identifier, a short-lived payload containing the authored name,
   already-resolved canonical type, exact identifier range and recognized
   private/protected trait mask;
2. after its optional initializer has been fully parsed, an explicitly named
   initializer adapter bound to that returned DeclId; a missing global
   initializer may project the existing non-primitive default-construction
   policy while type authority is live;
3. the next comma starts a new declaration action using the same authored
   type. Later recovery never deletes an already-valid declarator fact.

The header payload is pointer-free apart from the short-lived snapshot-local
`asCQualType` value used inside the same construction Context. Durable
identity remains the sealed declaration/type stable key. No Parser node,
Engine pointer or numeric TypeId is persisted.

## Explicit exclusions

- Local variable declaration statements, for/foreach declaration statements
  and their body ownership remain in the statement-action migration.
- General type spelling/qualifier/template parsing still enters through the
  named `ActOnQualTypeFromNode` adapter.
- Initializer expression syntax still enters through a specifically named
  expression adapter; this slice ensures exact per-declarator ownership, not
  completion of expression Sema.
- Custom named `access:` groups require a separate stable representation;
  this slice preserves recognized private/protected traits only.
- Parser-to-Builder producer association is not expanded to persist Parser
  syntax. If a bridge is required, it may bind only an already-created exact
  declaration identity and must be documented as transitional.

## Required evidence

1. test-only build and valid behavior/architecture RED before production;
2. Runtime/Editor build after the bounded repair;
3. exact multi-global/multi-field early-recovery and architecture GREEN;
4. SemaAuthority, ProductionCodeGen and Parser declarations GREEN;
5. relevant field layout/accessor/global initializer execution gates GREEN;
6. source scans, strict OpenSpec validation and parent/plugin
   `git diff --check HEAD`;
7. RED, root cause, invalid runners, repair, results and non-claims copied to
   the final issue/progress/task ledgers.

## Non-claims

- This does not complete local declarations or statement/expression Sema.
- This does not complete all property/virtual-property/access-group semantics.
- This does not prove detached CodeGen language/metadata coverage.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD and implementation record

The test-only build passed before production edits:

`Saved/Build/cta-global-field-variable-red-test-build/20260827_105912_773_f0903c02/RunMetadata.json`

The valid full SemaAuthority discovery run then produced the intended
**319 total, 317 passed, 2 failed** RED. The only failures were the two new
permanent tests:

- `ParserGlobalAndFieldDeclaratorsAreTypedIndividuallyBeforeLaterRecovery`;
- `ParserGlobalFieldVariableFamiliesUseTypedActionsWithoutWholeDeclarationReplay`.

Report:

`Saved/Tests/cta-global-field-variable-red/20260827_110132_423_71fbb6a6/Report/index.json`

The repair adds `asSVariableHeaderAction`,
`ActOnVariableHeaderAction`, and
`ActOnVariableInitializerFromNode`. `ParseDeclaration()` resolves the type
once and publishes one exact header action immediately after each authored
identifier, then binds only that declarator's optional initializer to the
returned DeclId. Private/protected traits cross the typed payload. The generic
top-level callback excludes `snDeclaration`, and the class field branch no
longer notifies its completed declaration shell. The residual
`WalkOne(case snDeclaration)` explicitly diagnoses
`global-field-variable-node-replay` under translation-unit, namespace, or
class owners and remains available only for local statement migration.

## Issues discovered during GREEN

The first focused semantic run was **0/1**, but the AST dump showed the
production representation was correct: globals had folded constants
`GlobalFirst=11` and `GlobalSecond=22`; fields had exact explicit InitPlans
`Pair::Left=31` and `Pair::Right=47`, both private. The test had incorrectly
assumed that global and field initializers both live in `Decl::inits`.
Canonical global constants are normalized into
`hasConstantValue/constantValue`, while field initializers remain explicit
InitPlan expressions. The oracle was corrected to assert those two distinct
sealed representations; no production relaxation was made.

- invalid-oracle report:
  `Saved/Tests/cta-global-field-variable-semantics-focused-green/20260827_110729_407_1bb72dfb/Report/index.json`;
- corrected-test build:
  `Saved/Build/cta-global-field-variable-test-oracle-fix-build/20260827_110842_018_08cfa2a3/RunMetadata.json`;
- final focused result, **2/2 PASS**:
  `Saved/Tests/cta-global-field-variable-focused-green/20260827_110907_732_10bc4e70/Report/index.json`.

The first complete ProductionCodeGen run was a valid product regression,
**113/114 PASS**. `CanonicalConstGlobalBinaryInitEvaluatesFortyPlusOne`
sealed `constant=41` but also exposed `default=40`. `ActOnGlobalVarInit`
correctly folded `40 + 1` and wrote normalized default text `41`; the generic
first-integer source extractor then overwrote it with the first literal
`40`. That split could make a later replay/codegen consumer reconstruct a
different value. Global/namespace initialization now leaves normalized
default ownership exclusively with `ActOnGlobalVarInit`; source integer text
is retained only for class-field InitPlan handling.

- regression report:
  `Saved/Tests/cta-global-field-variable-production-codegen-green/20260827_111033_877_9397f6b7/Report/index.json`;
- repair build:
  `Saved/Build/cta-global-field-variable-normalized-default-fix-build/20260827_111143_721_a99f9044/RunMetadata.json`;
- focused repaired case, **1/1 PASS**:
  `Saved/Tests/cta-global-field-variable-normalized-default-focused-green/20260827_111155_506_fb5f5d04/Report/index.json`.

One evidence-collection command initially used a stale guessed private-source
path and found no files. It was not a product/test RED. The scan was rerun
against the maintained fork under
`Source/AngelscriptRuntime/ThirdParty/angelscript/source/`; all counts and
architecture claims below use only that corrected path.

## Final evidence

| Gate | Result | Evidence |
|---|---:|---|
| first production build | PASS | `Saved/Build/cta-global-field-variable-first-fix-build/20260827_110658_565_57f8c2d9/RunMetadata.json` |
| exact semantic/architecture tests | **2/2 PASS** | `Saved/Tests/cta-global-field-variable-focused-green/20260827_110907_732_10bc4e70/Report/index.json` |
| final SemaAuthority | **319/319 PASS** | `Saved/Tests/cta-global-field-variable-sema-authority-final-green/20260827_111313_761_60472e08/Report/index.json` |
| final ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-global-field-variable-production-codegen-final-green/20260827_111230_543_b077f698/Report/index.json` |
| Parser declarations | **18/18 PASS** | `Saved/Tests/cta-global-field-variable-parser-declarations-green/20260827_111602_367_93bbc72a/Report/index.json` |
| strict OpenSpec validation | PASS | `openspec validate refactor-as-canonical-typed-ast-compiler --strict` |
| parent/plugin whitespace checks | PASS | separate `git diff --check HEAD`, exit 0; existing LF/CRLF notices only |

The complete ProductionCodeGen gate includes scalar/object/namespace global
initialization, mutable-global reset, generated accessor, second-field and
member-default execution coverage. The previously failing binary-constant
case was also rerun alone before the final full group.

Corrected static scans show:

- no top-level generic completion for `snDeclaration`;
- no class-field `NotifySema(node->lastChild)`;
- one typed header plus one exact initializer action per global/field
  declarator;
- global/field entry into the residual declaration walker fails closed;
- direct line-bearing `asCScriptNode` sites are declaration **96**,
  expression **42**, statement **27**, and core Sema **3**.

Executable defaults remain unchanged: `ep.canonicalCompilerPipeline` is
false unless explicitly selected, and both project/Engine Cache V2 enablement
defaults are false.

## Outcome

CTA-S-13 is closed for top-level/namespace global and class/struct field
declarator identity, access, exact initializer ownership, recovery durability,
and the covered Runtime execution paths. It advances Tasks `4.2`, `4.3`,
`4.4`, `4.5`, and `13.2` but does not close any umbrella. Local declarations,
general data-type production, property/access-group/funcdef/default/lambda
actions, and expression/statement/lifetime Parser-node adapters remain on the
critical path.
