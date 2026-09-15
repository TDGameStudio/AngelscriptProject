# Current diagnostic migration inventory — 2026-09-12

Read-only planning evidence, not completed migration or executed tests. `tasks.md` owns execution state. The historical September 5 inventory is excluded from this successor. September 12 hashes remain provenance, not a claim that current source bytes still match; apply must refresh impacted rows.

## 3.2 apply (semantic / declaration)

NativeEngine GREEN `55bdf3b6fc58473ab55df8614c0bb450` after build `47ce9354203c4043b9049c1b42775d19`. Class `DiagnosticsSemantic` owns producer proof. Unresolved-reference 4003 carries DidYouMean 6002 notes and a unique one-character SourceEdit; equal-distance Count/Court stays notes-only. Unknown-type 4004, duplicate 4005, invalid-qualifier 4007, generic-arity 4008, enum divide-by-zero 4401 and invalid-shift 4402 stay distinct. Inheritance cycle 4406 versus depth-budget 4407. Session Fail submits a group only when `asDiagnosticIdFromSemanticReason` maps the reason; hyphenated StableDiagnostics strings remain for Bodies/Declarations fixtures.

| Surface | Current hash | Proof |
|---|---|---|
| `frontend/Basic/as_diagnostic_semantic.def` | `a5eab868b5025dfcf9b5c26e394520f8effd1c4c37cdca026a67cea2add1161e` | Catalog keys 4401–4457 |
| `frontend/Basic/as_diagnostic_catalog.def` | `10fc9ba9e115b27fbdd8588d79d3196bddf3119d51d043aed2f8c4f901e37dff` | 4003–4008 and warning 4203–4205 |
| `frontend/Sema/as_sema.cpp` | `a44d77303356c17d6d1b29781f9f58cb0efb6349be468c6a12c6c8e0f3c4de06` | Mapped ReportBodyError + typo SourceEdit |
| `frontend/Compile/as_compilation_session.cpp` | `8f73e1f3f944439a31f8a6e6b994d8b71e3424dbdad90cacd6a276d9cd796678` | Mapped Fail groups + related duplicate range |
| `frontend/Compile/as_compilation_session_types.cpp` | `f3c8ef68f5a94b592a727ae2961c5edb0f9aa0f414e770bf71f10471a60febc2` | ResolveStructuredType OutReason |

Cases: `DiagnosticsSemantic.ViableTypoFix`, `DistinctSemanticCauses`, `AcceptedSemanticBoundaries` (qualifier, host TArray arity, conversion, AssessCall twice, implicit-case-fallthrough 4203).

## 3.1 apply (syntax / annotation / lex / PP)

NativeEngine GREEN `eedc121fa6b34e7c8a4bc3a11c3e9961` after build `c8d3a3acfee94c8a894d32def3cbd298`. Class `DiagnosticsSyntax` owns producer proof. Lexer 1001–1006 and preprocessor 2001–2014 keep catalog identity; parser reasons 3101–3243 plus helper-false IDs 3144–3146 map through `asDiagnosticIdFromSyntaxReason`. Invalid annotation targets use 3243; dangling/malformed annotations use 3102/3103/3121/3142. Asset/import remain 3004/3005; malformed callable remains 3006.

| Surface | Current hash | Proof |
|---|---|---|
| `frontend/Basic/as_diagnostic_syntax.def` | `15c6b4d2dfbfe9470e5b6bfb0b026252e0efc453ac56f5c009961f496b1480e8` | Catalog keys 3101–3146 / 3201–3243 |
| `frontend/Parser/as_parser.cpp` | `355876c7ace5e4ad7112bda8e5059e0cbb1ef41237719487e5bee7a2d136bfbd` | Declaration/expression reasons + helper-false Recover |
| `frontend/Parser/as_parser_statements.cpp` | `77ee968013481782cc7699d0308288762a3496b229ee2b5075ed5ffff85b0ffc` | Statement reasons + body-input catalog reports |
| `frontend/Parser/as_parser_access.cpp` | `3fb03ff531cd45e20e8fc90ecabe38429e0dca222465036a6d8682c1e1a39428` | `malformed-access-policy` 3143 |
| `frontend/Sema/as_sema.cpp` | `c1c8510432a2d45b4d1cf30f24e45fbd181a5d24c43e3239c3dd9f5f1ceda5be` | `ReportSyntax`, invalid-attribute-target 3243 |
| `frontend/Lexer/as_preprocessor.cpp` | `f3616e7226ad8b00b63e0fc4a8749d263d40495f9f475b31cd32de0a70a0cb31` | 2001–2014 including every MalformedCondition Fail |
| `frontend/Lexer/as_tokenizer.cpp` | `fd2039cf7995fe6c63c226d01dcab8cac91287cf82745da2af9adb4dcdce0a74` | 1001–1006 via tokenizer collection |

Cases: `DiagnosticsSyntax.RealDelimiterRecovery`, `SilentAnnotationAndMalformedBytes`, `AcceptedSyntaxBoundaries` (inventory parser table, PP matrix, lexer bytes, helper-false `class`/`namespace`/`int (`). Unevaluated `#if 0 && UNKNOWN` remains short-circuit without 2001.

## 2.1 catalog reservation (apply)

Reserved concrete catalog entries in `as_diagnostic_catalog.def` for Lexer 1001–1006, preprocessor 2001–2014, declaration/parser 3001–3008 (3003 remains a reserved generic), semantic/session 4001–4002 and 4101–4104, existing observation IDs 4201–4202 and 4300–4301, and builder/driver 5001–5002 plus attached note 6001. Producer migration of those IDs remains 3.1/3.2/3.4. Source causes keep catalog identity; derived Builder `5001` wrappers and flat `EmitTo` projections are observation adapters; disabled warnings are policy drops, not language failures.

## Baseline and dispositions

Parent HEAD `afeff74519a0d81e40702f140503cffe911789c6`; plugin HEAD `ad4d4830bb1b43a3439939bf4fc78aa16ae28d9d` plus existing workspace edits. Source hashes below bind the inspected bytes. No UE operation ran.

Each producing/suppressing/forwarding/false-return branch must be classified in 2.1 as source cause, derived observation, internal/environment failure, nonpoisoning API status, or demonstrably removed path. Its producer task adds catalog/status, typed payload, authentic primary/related ranges, concrete source or boundary fixture, independently expected result and exact proving case/run. The literal scan below is discovery evidence, not an exhaustive control-flow audit; missing branch evidence prevents 6.1 closure.

## Current ownership and proven gaps

| Surface | Current evidence | Owner / required proof |
|---|---|---|
| Diagnostic storage | as_diagnostics.h/cpp has flat records and rejects invalid/missing source ranges | 2.1 optional real location, complete groups, policy/failure separation and retained snapshot |
| Renderer / edits | Existing renderer is not complete group JSON/codec/atomic alternative API | 2.2 exact text/JSON; 2.3 coordinates; 2.4 atomic validation |
| Syntax / annotation | Generic recovery and body report adapters still collapse reasons | 3.1 real per-branch cause/range/fix/recovery |
| Session / Sema | Fail/StableDiagnostics and generic 4001/410x families lose structured distinctions | 3.2 typed declaration/type/body causes and viable typo corrections |
| Calls | ResolveCall/ResolveExternalCall are private mutating routines | 3.3 assessment/commit separation, candidate-local host failures, complete/incomplete parity |
| Builder | Record emits 5001; HasErrors scans displayed severity; RefreshCompileOutput copies flat records | 3.4 root identity, failure facts and lifetime-safe result export |
| Bytecode emission | Result contains status/failure metadata; Builder reduces failure to a fragment-key string | 3.4 preserve exact structured fields and genuine optional location |
| Ownership | Builder/session Dependencies are raw pointers; DefinitionSet has no retained lease API | 4.1 owned transitive input bundle, no resurrected MetadataImage/TypeInfo shared owner |
| AST | VerifyAndSeal is valid sealing, not recovery-safe tooling freeze | 4.1 worker join, safe edges, mutation rejection and strict codec/publication controls |
| Cursor | Ordinary parser and private scope data do not expose isolated cursor context | 4.4 full declaration barrier and request-local parser/sema state |
| Query / facade | Planned as_tooling_session and as_language_service APIs do not exist | 4.2/4.3 actual query results; 5.1 retained attachment and owner/feature rejection |

## Source families and literal discovery

All source paths below are relative to `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/`. Hex digests are SHA-256 of actual bytes. Hyphenated TEXT literals identify candidates for branch audit; plain booleans, enum-only failures and formatted variants still require caller tracing.

### as_builder.cpp

SHA-256 `a3eb89512110bd379de1912c0075ce5c402db56481559700f2aba23fecc187d8`.

```text
body-invalidation-finalization-failed
builder-input
builder-stage
bytecode-emit-failed
declaration-barrier-failed
declaration-dependency-finalization-failed
definition-set-dependency-must-be-immutable
descriptor-projection-failed
invalid-builder-input
invalid-semantic-input
semantic-result
stage-%u-failed
token:%u;nominal:%s;reference:%u;handle:%u;const:%u;handle-const:%u;nullable:%u
```

### as_bytecode_emitter.h

SHA-256 `8a57d91593807acb378f78177856a2869a46db6ab5e5fd1c90302c6d2dca6f78`.

Ownership/status boundary: inspect declarations and callers; no diagnostic reason literal expected.

### as_compile_output.h

SHA-256 `624abb43ff30ff340ea0d884b4f6d65f2d07a38d4612df47c28adbfb5b687e64`.

Ownership/status boundary: inspect declarations and callers; no diagnostic reason literal expected.

### as_module_definition_set.h

SHA-256 `d03fc72a49d4909b3718df0ff48b9c9a0084dd455f0007cefa895ff5feef1536`.

Ownership/status boundary: inspect declarations and callers; no diagnostic reason literal expected.

### frontend/AST/as_ast_projection.cpp

SHA-256 `915273f57eb47eb8b39cae0416eac5180b3278e65dfc891428610944bdbbacc7`.

```text
 argument-source-ordinals=[
[%d] %s source=%s:%u-%u children=%d semantic=%d cross=%d access=%s identity=%s %s
argument-source-ordinals=[%s]
callable cross-reference does not target a function
clauses=%u default=%u header=%u-%u
conversion cross-reference does not target a function
custom access cross-reference does not target an access specifier
declaration cross-reference does not target a declaration
default-argument cross-reference does not target a parameter
default-argument reference does not resolve to a parameter coordinate
explicit-fallthrough
external projection cross-reference has no durable identity
fallthrough cross-reference does not target a clause
initializers=%u condition=%u increments=%u header=%u-%u
key=%u header=%u-%u colon=%u-%u
keyword=%u-%u
loop cross-reference does not target a loop
member cross-reference does not target a declaration
member-source=%u-%u
name=%s return=%s kind=%u modifiers=%u const=%u deferred-statements=%d
name=%s type-kind=%u modifiers=%u bases=[%s]
name=%s type=%s deferred-initializer=%u
passing-modes=[%s]
projected case clause contains a non-statement child
projected class-default function is not an implicit void zero-parameter function
projected class-default statement lost its authored statement
projected declaration group contains a non-declaration child
projected default clause contains a non-statement child
projected non-class-default function carries default statements
projection cross-reference has an invalid local target
projection cross-reference identity disagrees with its local target
projection cross-reference identity is foreign or has the wrong role
projection cross-reference kind is invalid
record cross-reference does not target a record
return cross-reference does not target a function
switch parent cross-reference does not target a switch
typed-ast-v7 nodes=%d
value-init
```

### frontend/AST/as_ast_verifier.cpp

SHA-256 `29cac7bd5163b911d2cc741dafc6ae20bbea7c698517d40f5a7faa97b8309f0d`.

```text
call argument-source mapping has a gap
call argument-source mapping has the wrong size
call argument-source mapping is not a unique authored permutation
canonical type payload does not match its registry-owned identity
class-default function requires an implicit void zero-parameter signature
class-default statement range is invalid
class-default statement requires its authored keyword and statement
constructor argument-source mapping has a gap
constructor argument-source mapping has the wrong size
constructor argument-source mapping is not a unique authored permutation
custom member access does not resolve to its authored record-local policy
declaration group contains a non-declaration statement
named declaration requires a non-empty name
non-class-default function carries class-default source state
non-owning cross reference has a foreign or invalid semantic target
type alias requires an unqualified non-void primitive target
typed AST taxonomy entry has no cross-reference handling
typed AST taxonomy entry has no semantic-reference handling
```

### frontend/AST/as_decl.cpp

SHA-256 `6be4e3886476eb7ed1bfa300c0a57d7e98f82729b23b6705c1d16fe2dd7adcc7`.

```text
source-decl:%s:%s:%u:%u
```

### frontend/Basic/as_diagnostics.cpp

SHA-256 `03233c5de9fe019da20146311b75028afd9fbaae69808a472aa1429073252049`.

Ownership/status boundary: inspect declarations and callers; no diagnostic reason literal expected.

### frontend/Compile/as_binding_declaration.cpp

SHA-256 `73bb0e52d9820f6384f5d08fc155a5aa52425e54a246ce47d7a62204b7d1cc42`.

```text
binding-declaration
```

### frontend/Compile/as_compilation_session.cpp

SHA-256 `dacc51f8e018d33da816aa396f0f0b5f8cd54b08f529ecfd1619f2d057dc12aa`.

```text
:initializer-analysis-failed
:initializer-dependency-budget
:initializer-dependency-cycle
access-specifier
auto-requires-initializer:
body-analysis-failed
body-result-missing
class-default-analysis-failed
cyclic-type-alias:
enum-constant
invalid-callable-identity:
invalid-callable-parameter:%s:%d
invalid-callable-payload:
invalid-conversion-shape:
invalid-declaration-identity:
invalid-function-identity:
invalid-module-identity:
invalid-nominal-identity:
invalid-nominal-owner:
invalid-nominal-payload:
invalid-nominal-type-use:
invalid-parameter-identity:
invalid-type-alias:
return-type-conflict:
translation-unit
type-alias
type-kind:%u
unresolved-base:
unresolved-callable-return:
unresolved-return:
unresolved-type:
```

### frontend/Compile/as_compilation_session_access.cpp

SHA-256 `4d23c7472d0ecd3eb90656da2f297cdc2e01a3141d34245787314d84a94ebd5d`.

```text
duplicate-access-policy
foreign-access-policy
unknown-access-policy
unresolved-access-policy
```

### frontend/Compile/as_compilation_session_constants.cpp

SHA-256 `346d82062bb1e46b197925e4590cfbb3ac2089fde6b358df8a302e7015b144f4`.

```text
enum-constant-dependency-analysis-failed
enum-constant-dependency-cycle-or-unresolved
enum-constant-divide-by-zero
enum-constant-invalid-shift
enum-initializer-analysis-failed
enum-initializer-missing
enum-initializer-not-integral-constant
enum-value-out-of-range
```

### frontend/Compile/as_compilation_session_inference.cpp

SHA-256 `5221a11bc74e324052e704ee1c8f797d74fcbec2cbc59bc4d8470760d157670e`.

```text
:auto-initializer-analysis-failed
auto-initializer-dependency-budget
auto-initializer-dependency-cycle
```

### frontend/Compile/as_compilation_session_records.cpp

SHA-256 `0b7560f5966d4ef788fd9ef3560d9fb7eb404d488d740988c3558087ca694725`.

```text
cannot-override-final-method
cyclic-or-overdeep-inheritance
duplicate-base-type
interface-requires-interface-base
invalid-base-type
method-does-not-override
multiple-object-bases
override-return-type-mismatch
```

### frontend/Compile/as_definition_consumer.cpp

SHA-256 `cc0599492b4e475d43217961f389e1e7a0a366421de6329080e81a6c1502d167`.

```text
Cannot create an identity-authenticated definition shell.
```

### frontend/Parser/as_parser.cpp

SHA-256 `00a7e673f125caa35605e4a0cd6a1238e78b5cfac0cc7c7a935796231fd6198b`.

```text
access-policy-does-not-accept-annotations
annotation-requires-declaration
annotation-requires-parentheses
asset-syntax-removed
call-trailing-comma
cast-missing-angle-close
cast-missing-operand
cast-missing-parenthesis
cast-target-required
conditional-missing-colon
conditional-missing-false-expression
enum-constant-name-expected
enum-constant-separator-expected
enum-initializer-expression-expected
enum-underlying-type-not-supported
expression-depth-limit
import-syntax-removed
list-initializer-missing-comma
list-initializer-unclosed
local-name-required
malformed-annotation-payload
malformed-base-specifier
malformed-call-argument
malformed-callable-declaration
malformed-cast-target
malformed-class-default-statement
malformed-constant-expression
malformed-construction-arguments
malformed-direct-initializer
malformed-list-initializer
malformed-member-call
malformed-postfix-arguments
malformed-type-alias
member-name-required
missing-binary-operand
missing-local-initializer
missing-unary-operand
named-subscript-not-supported
parenthesized-expression-missing-close
qualified-name-missing-component
type-alias-missing-semicolon
unterminated-annotation
```

### frontend/Parser/as_parser_access.cpp

SHA-256 `3fb03ff531cd45e20e8fc90ecabe38429e0dca222465036a6d8682c1e1a39428`.

```text
malformed-access-policy
```

### frontend/Parser/as_parser_statements.cpp

SHA-256 `9def26073d9307ff34d64ec57f0cc2b9c53e96e42bddb4b3c0e5389c91596ec6`.

```text
body-input-invalid
body-missing-opening-brace
break-missing-semicolon
continue-missing-semicolon
default-missing-colon
do-missing-while
fallthrough-missing-semicolon
fallthrough-outside-switch
for-missing-closing-parenthesis
for-missing-condition-semicolon
for-missing-initializer-semicolon
for-missing-opening-parenthesis
for-trailing-increment-comma
foreach-invalid-key-variable
foreach-invalid-range
foreach-invalid-value-variable
foreach-missing-colon
foreach-missing-opening-parenthesis
invalid-for-increment
invalid-for-initializer
local-declaration-missing-semicolon
malformed-case-label
malformed-do-condition
malformed-if-condition
malformed-return-expression
malformed-statement
malformed-switch-selector
malformed-switch-statement
malformed-while-condition
missing-else-statement
missing-for-body
missing-foreach-body
missing-if-statement
missing-while-body
return-missing-semicolon
statement-missing-semicolon
switch-clause-declaration-requires-scope
switch-label-outside-switch
switch-missing-opening-brace
switch-statement-requires-clause
unterminated-compound
unterminated-switch
```

### frontend/Sema/as_sema.cpp

SHA-256 `b8dd007885dab1fa66de98d0c3b82f8a4a7e3fd60f4c7272ebfd1fb5a6a507ad`.

```text
assignment-requires-modifiable-lvalue
blueprint-accessor-metadata-removed
condition-requires-bool
incompatible-assignment
incompatible-conditional-branches
incompatible-declaration-initializer
increment-requires-modifiable-lvalue
invalid-attribute-target
invalid-auto-initializer
invalid-binary-operand-types
invalid-conditional-operands
invalid-numeric-literal:%s
invalid-unary-operand-type
logical-operator-requires-bool
missing-binary-operand
missing-parenthesized-expression
missing-unary-operand
unresolved-reference:%s
```

### frontend/Sema/as_sema_access.cpp

SHA-256 `a15796ce7d65b1e1044b73471c2d18127bd3c7f8905c036273873c148acc2073`.

```text
defaults-only-call-outside-defaults
inaccessible-function
unsafe-call-during-construction
```

### frontend/Sema/as_sema_conversion.cpp

SHA-256 `96b9a5e05046ac1cc8d9503470135f837c00cc0e71ce50465e5a3a3c82a5cc09`.

```text
ambiguous-user-conversion
```

### frontend/Sema/as_sema_initializer.cpp

SHA-256 `92596637e4563c2440cf4f436983d57a311ab6bd773e8d9de6896945595b59a1`.

```text
initializer-does-not-match-list-factory-pattern
```

### frontend/Sema/as_sema_postfix.cpp

SHA-256 `9ffe48eb266aa586ee39bcb782ab4cf50cdb5c2591de7b38b2e268d398fbfcc4`.

```text
deprecated-function-call
expression-requires-contextual-type
inaccessible-member
incompatible-explicit-cast
incompatible-indirect-call-argument
incompatible-primitive-construction
incomplete-string-escape
invalid-cast-target
invalid-construction-type
invalid-indirect-call-signature
invalid-primitive-construction
invalid-string-codepoint
invalid-string-escape
invalid-subscript
invalid-this-type
member-is-not-a-value
missing-construction-definition
missing-string-literal-provider
named-argument-requires-declaration
no-matching-constructor
nodiscard-call-result-unused
this-outside-instance-context
unknown-string-escape
unresolved-call:%s
unresolved-constructor
unresolved-host-identity
unresolved-host-parameter
unresolved-host-return
unresolved-host-signature
unresolved-index-operator
unresolved-member-call:%s
unresolved-member:%s
unsupported-default
unterminated-string-literal
```

### frontend/Sema/as_sema_statements.cpp

SHA-256 `87544a5a53d0127218b4ac4c596e0b50811ecebc5ad0e61a943eb024a95ede32`.

```text
break-outside-control
case-requires-integral-constant
case-type-mismatch
continue-outside-control
duplicate-case-value
duplicate-default
duplicate-local:%s
empty-switch
fallthrough-from-last-case
fallthrough-must-terminate-case
foreach-%s-%s
foreach-range-not-iterable
foreach-variable-conversion-failed
implicit-case-fallthrough
incompatible-local-initializer
incompatible-return-value
invalid-auto-initializer
invalid-local-type:%s
invalid-while-body
not-found
switch-requires-integral-or-enum
unresolved-local-type:%s
```

## Removed and relocated paths

The old `ThirdParty/angelscript/source/frontend/as_frontend_*` paths are historical. Current phases are Basic, Lexer, Parser, AST, Sema and Compile. Lambda/source-funcdef syntax remains removed; historical lambda acceptance and `as_frontend_sema_lambda.cpp` / BodyLambdaTests are not migration targets. Test lexing controls now live at `Source/AngelscriptTest/NativeEngine/Lexer/Lexer{Contracts,SpelledKinds,Recovery}Tests.cpp`; new tests stay in `NewVersion/NativeEngine/` with the public `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>` identity. Other named historical cases must be matched to current test source before they count as controls.

## Coverage closure

Keep the specific 1001–1006 Lexer and 2001–2014 preprocessor identities where semantics agree; do not reuse retired generic IDs. Audit every MalformedCondition branch, parser declaration/expression/statement recovery, silent invalid annotation, type-resolution invalid return, constant evaluator failure enum, inheritance cycle/depth distinction, access-policy branch, warning family, call rejection/default/receiver/conversion reason, definition/layout/verifier status and emission result. Removed reasons get source-absence evidence, not invented tests.

## 6.1 implementation closure

NativeEngine `a8f886db1ab04088aa3a6cf730a32b36` (1150/1150) after build `ae945a25e9fc43959484364d34b97e07`. Integration class `DiagnosticsToolingIntegration` plus the producer classes below are the per-branch oracles. Count-only totals are not used as closure.

| Family | Disposition | Independent expected payload | Proving case / run |
|---|---|---|---|
| Lexer 1001–1006 | Source diagnostic | Catalog ID and range on authentic bytes (unterminated `"` is 1005) | `DiagnosticsSyntax.AcceptedSyntaxBoundaries`; integration A.as 1005 on `06adc1ebf2b84578b2a36aa167ee97e6` |
| Preprocessor 2001–2014 | Source diagnostic | MalformedCondition 2002 on `#if defined(`; short-circuit `#if 0 && UNKNOWN` stays silent | `DiagnosticsSyntax.AcceptedSyntaxBoundaries`; integration C.as 2002 |
| Parser/annotation 3101–3243 / 3004–3006 | Source diagnostic | Reason-mapped Recover IDs, invalid annotation 3243, asset/import 3004/3005 | `DiagnosticsSyntax.RealDelimiterRecovery`, `SilentAnnotationAndMalformedBytes` |
| Semantic/declaration 4003–4008, 4401–4457, warnings 4203–4205 | Source diagnostic | Distinct IDs; unique typo 4003+6002+SourceEdit; unmapped Fail stays hyphenated only | `DiagnosticsSemantic.*` |
| Call assessment | Internal/non-mutating | Complete vs Incomplete formal maps; host candidate-local rejection | `CallAssessment.CompleteAndIncompleteMapping`; `ToolingCompletion.RealSignatureContext` |
| Builder 5001 / emission | Derived observation only when no language failure | No 5001 wrapper over Cout; ResourceLimit emission fields retained; illegal RunStage does not poison | `DiagnosticsBuilder.*` |
| CompileOutput / language service | Retained snapshot | Format/GetGroups/ApplyFix after Builder release; owner/feature rejection | `LanguageService.*`; `DiagnosticsToolingIntegration.RealCompileFixReanalysis` |
| Tooling Analyze / freeze | Partial readable, not valid-seal | Success vs Partial; FreezeForTooling ≠ IsSealed; foreign handle reject | `ToolingAnalysis.*` |
| Cursor / complete / navigate | Request-local query | Inner/Outer visibility; Item receiver across file order; hover local not function; host NoSourceTarget | `ToolingCursor.*`, `ToolingCompletion.*`, `ToolingNavigation.*` |
| Parallel Lex/PP X,K | Derived stage product | Joined token identity; A ineligible for PP; B valid; repeat Preprocessed does not grow groups | `ParallelLexPreprocess.*`; `DiagnosticsToolingIntegration.JoinedEarlyPhaseFailureAndRetainedToolingData` |
| Unmapped session Fail | Preserved internal | Hyphenated StableDiagnostics, no extra generic 4001 | `DiagnosticsSemantic` + DeclarationsLanguageForms exact counts |
| Illegal API stage | Nonpoisoning API status | Rejected request, accepted-stage facts unchanged | `DiagnosticsBuilder.NonpoisoningRejectedRequest` |
| Removed Lambda / asset-import syntax | Demonstrably removed | Named removed-feature diagnostics, no candidate completion named `function`/`lambda` | `LanguageSurface` / `ToolingCompletion` keyword filter |
| Legacy runtime / old tests | Preserved dormant | `WITH_ANGELSCRIPT_UNITTESTS==0`; no ambient Engine | Baseline `71959936e39644d5bd4662e2013f653c` |

Planning gap rows in “Current ownership and proven gaps” are closed by the producing tasks above; 6.1 does not invent remaining silent branches. Historical September 12 hashes stay provenance.

## Additional interface snapshot identities

- `as_builder.h` — SHA-256 `28808ec1c69a46abf2d48d2a338937b8354729f16a2b0d9af9e9193373bdea63`.
- `frontend/Basic/as_diagnostics.h` — SHA-256 `6e3481fbc8747a64a8cd3cb53e43f920ae30d892e7f74db792a8361561c334b9`.
- `frontend/Basic/as_source_location.h` — SHA-256 `210dc57074377384b93ca66ba6d1c63a9baabc03f3d4017cfce2a759fc26e31b`.
- `frontend/AST/as_ast_context.h` — SHA-256 `9dd29bad7b1b4b11b6005a5280e302619dedee2bf5d9810598df5ff01b67935e`.
- `frontend/Compile/as_compilation_session.h` — SHA-256 `52a46d7c9cc90eb28065dd2374b30a3a9c35a1b5cc191e05983f95c65cbd47c6`.
- `frontend/Sema/as_sema.h` — SHA-256 `35e193deb28b68e9dd6bbe4c6430c102e2bcfbb0eb0bf1bf44e6339a0b375e56`.
- `frontend/Parser/as_parser.h` — SHA-256 `f2bee5e86ced5f2e29a8abf2fc03ade3bd33e589ef372ff5a20ceb9f73c072fd`.

Provenance: carried from the same relative attachment in predecessor angelscript/feature-frontend-diagnostics-tooling, confirmed by Q10. Ownership terminology is aligned to its September 12 accepted design; original historical evidence dates remain explicit.
