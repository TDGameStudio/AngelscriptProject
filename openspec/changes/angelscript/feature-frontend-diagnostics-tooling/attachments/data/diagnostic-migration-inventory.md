# Current Diagnostic Migration Inventory

## Status and purpose

This attachment records read-only source inspection on 2026-09-05 for planning `angelscript/feature-frontend-diagnostics-tooling`. It is an inventory of current behavior and required migration work, not evidence that any diagnostic has been migrated or that any product test has passed. No UE run was performed for this inventory.

`tasks.md` owns execution state. The task references below only map ownership; this attachment has no independent completion checkboxes.

All paths are repository-relative. For compactness:

- **F/** means `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/`.
- **S/** means `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`.
- **T/** means `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/`.

Line numbers describe the inspected snapshot and are navigation hints, not permanent identifiers. Existing test owners are relevant places to extend or preserve behavior; naming them does not assert complete diagnostic coverage.

## Disposition policy and task ownership

Task 1.1 establishes the catalog and expands this family inventory into a producer-branch coverage matrix. Every current branch that produces, suppresses, aggregates, or silently loses an error must receive one of the following explicit dispositions:

1. **Source diagnostic:** migrate to a specific stable catalog entry with typed arguments, accurate ranges, relevant notes, and a concrete source fixture.
2. **Derived observation:** preserve the stage/analysis failure fact while linking or forwarding the original diagnostic; do not emit a duplicate generic source error.
3. **Internal or environment diagnostic:** preserve exact invariant/status information and report it through an appropriate structured boundary. A source location is optional and must be genuine.
4. **Public API status:** retain a non-poisoning invalid-request/status result when the contract does not define a source-language error. For example, an out-of-order Builder stage request must not invent a syntax error or poison the current stage.
5. **Unreachable or obsolete producer:** record source evidence and remove only through the owning implementation task; absence must be demonstrated, not inferred from lack of tests.

The expanded matrix must record producer branch, selected disposition, catalog entry or preserved status, required semantic payload, source/related ranges, concrete test owner/case, and proving evidence. A source scan alone is not behavioral acceptance. Renaming every generic ID without examining the underlying branches does not close coverage.

| Task | Inventory responsibility |
|---|---|
| 1.1 | Catalog, grouping/severity policy, complete branch matrix, and status-versus-diagnostic classification. |
| 1.2 | Text/JSON fidelity, safe edit sets, source-less rendering, source revision and position conversion. |
| 2.1 | Lexer, preprocessor, Parser, and annotation/declaration collection producer migration. |
| 2.2 | Sema, session, type resolution, Builder aggregation, and side-effect-free script/host candidate assessment. |
| 3.1 | Owning analysis results, partial-result barriers, cursor parsing, and query cancellation/status boundaries. |
| 3.2 | Completion and signature help consuming shared candidate reasons without formal AST or diagnostic mutation. |
| 3.3 | Hover/definition consuming authentic semantic bindings and locations without invented host source. |
| 4.1 | Integrated behavior, branch-matrix closure, source/fix round trips through the language service, and justified adjacent regressions. |
| 5.1 | In-process SDK facade: attach compilation diagnostics, Clang-style format, structured note/fix query and in-memory apply. |

## Current ID surfaces

| Producer | Current ID | Current shape | Primary task |
|---|---|---|---|
| Tokenizer | 1001-1006 | Specific enum, source range. | 2.1 |
| Preprocessor | 2001-2014 | Specific enum, source range, optional text argument. | 2.1 |
| Declaration recovery through `ActOnRecovery` | 3001 | Many reasons collapsed into one ID. | 2.1 |
| Attribute target validation | 3002 | `invalid-attribute-target` text. | 2.1 |
| Builder semantic assembly wrapper | 3003 | Stage error or serialized diagnostic text. | 2.2 |
| Removed syntax/callable/annotation Parser enums | 3004-3007 | A few specific declaration categories. | 2.1 |
| `ReportBodyError` | 4001 | Most expression/body reasons as preformatted text, including Parser body recovery. | 2.1, 2.2 |
| `ReportBodyWarning` | 4002 | All current body warning families share one ID. | 2.2 |
| Enum constants | 4101 | Many reasons share one ID. | 2.2 |
| Auto inference | 4102 | Cycle/budget reasons; other failures remain text-only. | 2.2 |
| Inheritance/override | 4103 | Many reasons share one ID. | 2.2 |
| Access policies | 4104 | Many reasons share one ID. | 2.2 |
| Builder stage failure | 5001 | Serialized errors or generic stage string. | 2.2 |
| Main declaration resolution | None | `StableDiagnostics` strings, without a structured source record. | 2.2 |

## Lexer

Source: **F/as_frontend_tokenizer.cpp**, enum in **F/as_tokenizer.h:16**.

Exact enum entries:

```text
InvalidUtf8 = 1001
UnicodeIdentifierDisallowed = 1002
EmbeddedNul = 1003
UnexpectedCharacter = 1004
UnterminatedString = 1005
UnterminatedBlockComment = 1006
```

Emission sites include approximately lines 188, 241, 350, 364-380, and the helper at 445. Numeric-token classification is separate from numeric-value validity; Sema diagnoses invalid numeric literal values later.

Existing owner: **T/LexerTests.cpp**. Relevant cases include `UnicodePolicyIsFrozenPerTokenizer`, `MalformedBytesAlwaysAdvanceAndDiagnoseOnce`, `UnterminatedBlockCommentConsumesToEnd`, and numeric-token-boundary tests.

Task 2.1 must preserve bounded forward progress and exact byte ranges while expanding diagnostic payloads. Shared lexical and semantic literal errors must not become duplicate reports for one root cause.

## Preprocessor

Source: **F/as_preprocessor.cpp**, enum in **F/as_preprocessor.h:21**.

Exact enum entries, sequentially 2001-2014:

```text
UnknownFlag
MalformedCondition
UnexpectedElif
UnexpectedElse
UnexpectedEndif
ElifAfterElse
DuplicateElse
MissingEndif
UnsupportedDirective
InvalidRestrictionOperation
InvalidRestrictionPolicy
MissingRestrictionPattern
ExtraRestrictionArgument
UnsupportedInclude
```

`MalformedCondition` currently covers missing expressions or operands, invalid flag tokens, malformed `defined` forms, unmatched parentheses, trailing operands, and arguments on directives that accept none. Task 2.1 must audit those branches separately; one test asserting ID 2002 is insufficient.

The input guard near line 468 rejects an unready SourceManager, empty token input, or unavailable diagnostics. Classify this as API/input failure; do not invent an authored directive location.

Existing owners:

- **T/Preprocessor/AngelscriptPreprocessorConditionTests.cpp**
- **T/Preprocessor/AngelscriptNativePreprocessorPolicyTests.cpp**
- **T/Preprocessor/AngelscriptNativePreprocessorDirectiveRoutingTests.cpp**
- **T/Preprocessor/AngelscriptNativePreprocessingRecordTests.cpp**
- **T/Preprocessor/AngelscriptNativeDirectiveTreeTests.cpp**

## Parser and declaration collection

### Declaration and annotation reasons

Source: **F/as_frontend_parser.cpp**.

Exact current reason strings:

```text
annotation-requires-parentheses
unterminated-annotation
malformed-annotation-payload
annotation-requires-declaration
access-policy-does-not-accept-annotations
malformed-class-default-statement
malformed-type-alias
type-alias-missing-semicolon
malformed-callable-declaration
malformed declaration
enum-underlying-type-not-supported
malformed-base-specifier
enum-constant-name-expected
enum-initializer-expression-expected
enum-constant-separator-expected
malformed-constant-expression
local-name-required
missing-local-initializer
malformed-direct-initializer
virtual-property-syntax-removed
property-decorator-removed
asset-syntax-removed
import-syntax-removed
```

`malformed declaration` currently contains a space. Helpers returning `false` often collapse missing type/name/delimiter conditions into that broad caller recovery. Task 2.1 must classify those helper branches, not simply give the wrapper a new ID.

Specific enums in **F/as_parser.h:9**:

```text
RemovedAsset = 3004
RemovedImport = 3005
InvalidCallable = 3006
InvalidAnnotation = 3007
```

Removed syntax stays rejected. Improving its diagnostic does not restore that syntax.

**F/as_frontend_parser_access.cpp:10** additionally produces `malformed-access-policy`.

### Expression recovery reasons

Source: **F/as_frontend_parser.cpp**.

```text
expression-depth-limit
conditional-missing-colon
conditional-missing-false-expression
missing-binary-operand
missing-unary-operand
member-name-required
malformed-member-call
malformed-postfix-arguments
named-subscript-not-supported
call-trailing-comma
lambda-parameters-required
lambda-parameters-unclosed
lambda-parameter-name-required
malformed-lambda-parameter
lambda-body-required
lambda-body-unclosed
malformed-list-initializer
list-initializer-missing-comma
list-initializer-unclosed
cast-target-required
malformed-cast-target
cast-missing-angle-close
cast-missing-operand
cast-missing-parenthesis
parenthesized-expression-missing-close
malformed-construction-arguments
qualified-name-missing-component
malformed-call-argument
```

### Statement recovery and body input

Source: **F/as_frontend_parser_statements.cpp**.

Current body-fragment-only status reasons:

```text
body-input-invalid
body-missing-opening-brace
```

Current recovery reasons:

```text
unterminated-compound
for-missing-opening-parenthesis
invalid-for-initializer
for-missing-initializer-semicolon
for-missing-condition-semicolon
invalid-for-increment
for-trailing-increment-comma
for-missing-closing-parenthesis
missing-for-body
malformed-switch-selector
switch-missing-opening-brace
malformed-case-label
default-missing-colon
switch-statement-requires-clause
fallthrough-missing-semicolon
malformed-switch-statement
switch-clause-declaration-requires-scope
unterminated-switch
foreach-missing-opening-parenthesis
foreach-invalid-value-variable
foreach-invalid-key-variable
foreach-missing-colon
foreach-invalid-range
missing-foreach-body
malformed-if-condition
missing-else-statement
missing-if-statement
malformed-while-condition
missing-while-body
do-missing-while
malformed-do-condition
break-missing-semicolon
continue-missing-semicolon
malformed-return-expression
return-missing-semicolon
switch-label-outside-switch
fallthrough-outside-switch
local-declaration-missing-semicolon
malformed-statement
statement-missing-semicolon
```

`RecoverBody` funnels through Sema `ActOnRecoveryStatement`, so these currently become generic ID 4001, not declaration ID 3001.

### Attribute collection without an emitted diagnostic

**F/as_frontend_sema.cpp:31-58** emits ID 3002 and `invalid-attribute-target`, including a UCLASS/USTRUCT/UENUM annotation on the wrong record kind.

However, `ActOnVariable` near lines 113-121 marks invalid function-parameter attributes and the declaration fragment as erroneous without emitting a corresponding diagnostic. This silent branch is mandatory Task 2.1 coverage.

Relevant existing owners:

- **T/Declarations/DeclarationLanguageTests.cpp**
- **T/Declarations/DeclarationSemanticTests.cpp**
- **T/Declarations/DeclarationAccessTests.cpp**
- **T/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp**
- **T/Bodies/BodyLanguageFormsTests.cpp**
- **T/Bodies/BodyControlFlowTests.cpp**

## Main declaration/type resolution and session orchestration

### Text-only declaration resolution

In **F/as_compilation_session.cpp** near line 240, local `Fail` marks the declaration invalid, sets `bHasErrors`, and appends text to `StableDiagnostics`. It does not produce a structured diagnostic record.

Current reasons and parameter shapes:

```text
invalid-module-identity:<module>
duplicate:<name>:<original-source-key>:<duplicate-source-key>
recovery:<source-key>:<begin>:<end>
invalid-nominal-owner:<name>
invalid-nominal-identity:<name>
invalid-nominal-type-use:<name>
invalid-nominal-payload:<name>
cyclic-type-alias:<name>
invalid-type-alias:<name>
invalid-declaration-identity:<name>
unresolved-base:<qualified-declaration>:<base-name>
unresolved-return:<qualified-name>
unresolved-callable-return:<qualified-name>
invalid-callable-parameter:<qualified-name>:<ordinal>
invalid-callable-identity:<qualified-name>
invalid-callable-payload:<qualified-name>
invalid-conversion-shape:<qualified-name>
return-type-conflict:<qualified-name>
invalid-function-identity:<qualified-name>
invalid-parameter-identity:<qualified-name>
auto-requires-initializer:<qualified-name>
unresolved-type:<qualified-name>:<type-spelling>
```

Some reasons represent user language errors; others indicate failed identity or invariant operations. Task 2.2 must preserve that distinction rather than classifying all of them as syntax/type errors.

Additional session/body orchestration strings:

```text
initializer-analysis-failed
initializer-dependency-cycle
initializer-dependency-budget
class-default-analysis-failed
body-analysis-failed
body-result-missing
```

The `*-analysis-failed`, `recovery`, and missing-result observations often derive from another error. Retain failure state without automatically creating another independent source error.

### Enum constants

Source: **F/as_compilation_session_constants.cpp**, current generic ID 4101.

```text
enum-initializer-analysis-failed
enum-constant-dependency-analysis-failed
enum-value-out-of-range
enum-initializer-missing
enum-constant-divide-by-zero
enum-constant-invalid-shift
enum-initializer-not-integral-constant
enum-constant-dependency-cycle-or-unresolved
```

Underlying **F/as_constant_evaluator.h** already provides `NotConstant`, `UnresolvedReference`, `InvalidType`, `Overflow`, `DivideByZero`, `InvalidShift`, and `BudgetExceeded`, with `FailureNode`. Preserve these distinctions and use the real failing expression location where available. Do not report every constant error against the whole enum declaration, or continue conflating a dependency cycle with an unresolved name.

### Auto inference

Source: **F/as_compilation_session_inference.cpp**.

```text
auto-initializer-dependency-cycle
auto-initializer-dependency-budget
auto-initializer-analysis-failed
```

The first two use generic ID 4102. The analysis-failed branch near line 51 only appends stable text.

### Inheritance and overrides

Source: **F/as_compilation_session_records.cpp**, generic ID 4103.

```text
cyclic-or-overdeep-inheritance
invalid-base-type
duplicate-base-type
multiple-object-bases
interface-requires-interface-base
override-return-type-mismatch
cannot-override-final-method
method-does-not-override
```

An inheritance cycle and an exhausted depth budget need distinct explanations. Duplicate base and override diagnostics should retain the relevant prior/base declarations as notes.

### Access policies

Source: **F/as_compilation_session_access.cpp**, generic ID 4104.

```text
duplicate-access-policy
foreign-access-policy
unknown-access-policy
unresolved-access-policy
```

### Structured type resolution with discarded reasons

**F/as_compilation_session_types.cpp**, `ResolveStructuredType`, currently returns an invalid type for these separate conditions:

- Recursion depth above 64 or invalid type syntax.
- Type name not found.
- Invalid generic argument, including a `void` argument.
- Generic application to a non-nominal template.
- Generic arity mismatch or missing required generic arguments.
- Failed identity authentication or interning.
- Invalid array-dimension range.
- Missing or mismatched configured array template.
- Primitive handle or qualified `void`.
- Invalid qualifier construction.

Callers collapse these into `unresolved-type`, `invalid-local-type`, or another broad failure. Task 2.2 must expose structured resolution reasons from the real type resolver, without creating an independent language/type-rule implementation.

**F/as_compilation_session_lists.cpp** and external-definition admission in **F/as_compilation_session_types.cpp** also contain semantic lookup/status returns. Include all remaining invalid/false-return branches in the audit; classify them as contextual semantic rejection or internal/API status based on their caller, rather than manufacturing an error on every unsuccessful lookup.

Relevant existing owners:

- **T/Declarations/DeclarationSemanticTests.cpp**
- **T/Declarations/DeclarationAccessTests.cpp**
- **T/Builder/BuilderStageTests.cpp**
- **T/Builder/ConstantEvaluationTests.cpp**
- **T/Builder/FrozenHostSemanticTests.cpp**
- **T/Definitions/GenericDefinitionTests.cpp**
- **T/Identity/AngelscriptTypeContextIdentityTests.cpp**

## Sema expression and body reasons

Unless marked as a warning or fragment status, these currently funnel through generic error ID 4001 with preformatted text.

### Core Sema

Source: **F/as_frontend_sema.cpp**.

```text
invalid-auto-initializer
incompatible-declaration-initializer
unresolved-reference:<name>
invalid-numeric-literal:<spelling>
missing-parenthesized-expression
missing-unary-operand
invalid-unary-operand-type
increment-requires-modifiable-lvalue
missing-binary-operand
assignment-requires-modifiable-lvalue
incompatible-assignment
logical-operator-requires-bool
invalid-binary-operand-types
condition-requires-bool
invalid-conditional-operands
incompatible-conditional-branches
```

### Statements and control flow

Source: **F/as_frontend_sema_statements.cpp**.

```text
incompatible-return-value
invalid-auto-initializer
invalid-local-type:<type>
unresolved-local-type:<type>
incompatible-local-initializer
duplicate-local:<name>
invalid-while-body
switch-requires-integral-or-enum
case-type-mismatch
case-requires-integral-constant
duplicate-case-value
duplicate-default
fallthrough-must-terminate-case
fallthrough-from-last-case
implicit-case-fallthrough
empty-switch
foreach-<begin|end|next|value|key>-<ambiguous|not-found>
foreach-range-not-iterable
foreach-variable-conversion-failed
break-outside-control
continue-outside-control
```

`invalid-while-body` is a body-fragment status. `implicit-case-fallthrough` is warning ID 4002. The foreach notation denotes the actual formatted variants for each named protocol function and ambiguity/not-found outcome; every supported variant belongs in the branch matrix.

### Postfix, calls, construction, and literals

Source: **F/as_frontend_sema_postfix.cpp**.

```text
this-outside-instance-context
invalid-this-type
unresolved-member:<name>
inaccessible-member
member-is-not-a-value
deprecated-function-call
unsupported-default
unresolved-host-return
unresolved-host-identity
unresolved-host-signature
unresolved-host-parameter
unresolved-call:<name>
unresolved-member-call:<name>
invalid-immediately-invoked-lambda
invalid-indirect-call-signature
named-argument-requires-declaration
incompatible-indirect-call-argument
invalid-subscript
unresolved-index-operator
invalid-cast-target
incompatible-explicit-cast
invalid-construction-type
invalid-primitive-construction
incompatible-primitive-construction
missing-construction-definition
unresolved-constructor
no-matching-constructor
expression-requires-contextual-type
nodiscard-call-result-unused
unterminated-string-literal
incomplete-string-escape
invalid-string-escape
invalid-string-codepoint
unknown-string-escape
missing-string-literal-provider
```

`deprecated-function-call` and `nodiscard-call-result-unused` are warning ID 4002. Other entries are errors.

### Access/call context

Source: **F/as_frontend_sema_access.cpp**.

```text
inaccessible-function
defaults-only-call-outside-defaults
unsafe-call-during-construction
```

### Lambdas

Source: **F/as_frontend_sema_lambda.cpp**.

```text
lambda-requires-explicit-function-origin
lambda-source-origin-unavailable
duplicate-lambda-parameter
lambda-return-needs-concrete-type
invalid-lambda-body
inconsistent-lambda-return-types
capturing-lambda-cannot-escape
```

### Conversion and list initialization

- **F/as_frontend_sema_conversion.cpp**: `ambiguous-user-conversion`.
- **F/as_frontend_sema_initializer.cpp**: `initializer-does-not-match-list-factory-pattern`.

Relevant existing owners:

- **T/Bodies/BodySemanticTests.cpp**
- **T/Bodies/BodyCallContextTests.cpp**
- **T/Bodies/BodyAccessTests.cpp**
- **T/Bodies/BodyControlFlowTests.cpp**
- **T/Bodies/BodyLanguageFormsTests.cpp**
- **T/Bodies/BodyConversionTests.cpp**
- **T/Bodies/BodyLambdaTests.cpp**
- **T/Builder/FrozenHostSemanticTests.cpp**
- **T/Definitions/ListInitializerDefinitionTests.cpp**

## Candidate rejection details currently lost

**F/as_frontend_sema_postfix.cpp:132**, `ResolveCall`, silently discards candidates for:

- Wrong declaration kind, invalid declaration, or absent resolved signature.
- Too many arguments.
- Unknown named argument, positional argument after a named argument, or duplicate assignment to one formal.
- Missing argument expression or omitted required formal; invalid default.
- Lambda contextual type, arity, or explicit parameter mismatch.
- Missing list-initialization contract.
- Null passed to a non-handle or `out`/`inout` formal.
- Invalid actual type.
- Ambiguous or unavailable user conversion.
- Handle/value mismatch.
- `out`/`inout` argument that is not a modifiable lvalue or has the wrong type.
- Const handle passed to a mutable handle formal.
- Incompatible non-numeric type.
- Equally ranked ambiguous overloads.

After selection it checks access/defaults/construction context and commits AST conversions/default-argument expressions. The outer call site usually reduces failure to `unresolved-call` or `unresolved-member-call`, losing candidates and rejected-argument reasons.

`ResolveExternalCall` similarly loses host metadata authentication, arity, named-argument, conversion, and ambiguity distinctions. It also emits `unsupported-default` while inspecting one candidate and immediately aborts search.

Task 2.2 must separate candidate assessment from committing AST modifications and reporting ordinary compilation diagnostics for both script and host callables. Task 3.2 then consumes the shared structured reasons in incomplete-call mode, without treating not-yet-authored later arguments as complete-call arity failures. Querying the existing mutating resolver directly is not an acceptable implementation.

## Builder, definition, and verifier boundaries

### Stage aggregation

Source: **S/as_builder_frontend.cpp**, `Record` near line 125.

Every failed stage currently creates diagnostic ID 5001, borrows `Inputs[0].RawTokens[0].Range` when available, and puts the entire error text in one argument.

Known error sources:

```text
invalid-builder-input
stage-%u-failed
serialized declaration diagnostics
serialized body diagnostics
AST verifier/projection error text
concatenated definition-consumer diagnostic messages
```

`DefinitionsBuilt` discards each existing `asSDefinitionDiagnostic.Range` while concatenating `Message`. Layout/freeze retain `MetadataStatus`, but the fallback diagnostic text remains `stage-%u-failed`.

Out-of-order `RunStage` and backward/invalid `RunThrough` return `false` without consuming or poisoning the current stage. Preserve that deliberate API behavior; invalid API sequencing is not automatically an AS source error.

### Semantic assembly wrapper

Source: **S/as_builder_frontend.cpp**, assembly reporting near line 340, ID 3003.

```text
invalid-semantic-input
declaration-barrier-failed
serialized declaration diagnostics
descriptor-projection-failed
declaration-dependency-finalization-failed
body-invalidation-finalization-failed
```

The wrapper constructs its record with an unset/default primary range.

### Source-less emission can disappear

**F/as_diagnostics.cpp:117** rejects a diagnostic whose primary range is not valid in the bound snapshot. Therefore:

- `invalid-builder-input` can be dropped because it is emitted before input token ranges exist.
- The default-range semantic assembly diagnostics can be dropped.
- Sema calls passing `{}` for a missing expression/condition can fail diagnostic emission.

Tasks 1.1, 1.2, and 2.2 must support explicitly source-less diagnostics and preserve rejection/status information where appropriate. Borrowing the first token of another file is not a valid fix.

### Definition and metadata statuses

**F/as_definition_consumer.h**, `asEDefinitionConsumerStatus` failure categories:

```text
InvalidPhase
InvalidAST
InvalidIdentity
UnsupportedDefinition
InvalidType
InvalidDefinition
InvalidDependency
```

**S/as_metadata_image.h**, `asEMetadataResult` failure categories:

```text
InvalidArgument
InvalidState
ForeignOwner
DuplicateIdentity
DuplicateName
UnfrozenDependency
IncompleteDefinition
InvalidLayout
RecursiveValueType
InvalidSignature
```

Preserve these exact internal/API statuses and forward meaningful structured boundary detail. Do not transform every metadata mutation/status API into a frontend language-diagnostic producer. Engine registration itself is not expanded by this Change.

### AST verification and projection

**F/as_ast_verifier.h**, `asEASTVerificationStatus` failure categories:

```text
NullRoot
ForeignNode
InvalidSourceRange
MissingRequiredChild
DuplicateOwningEdge
OwningCycle
RecoveryReachable
InvalidCrossReference
MissingSemanticReference
InvalidSemanticReference
InvalidDeclarationContext
InvalidAttributeTarget
InvalidPayload
UnhandledKind
```

The verifier returns status, descriptive text, and `LocalNodeID`. **F/as_ast_projection.cpp** has further precise ownership, identity-authentication, cross-reference, and semantic-payload failure strings. Builder currently reduces these outcomes to text.

Task 2.2 must inventory the verifier/projection boundary by exact status/category, retain detailed invariant text and authentic offending-node information where available, and avoid fake syntax errors. Task 3.1 must not make an error-tolerant query result pass the successful-compilation verifier by weakening its checks.

Relevant existing owners:

- **T/Builder/BuilderStageTests.cpp**
- **T/Definitions/DefinitionConsumerTests.cpp**
- **T/Definitions/MetadataImageTests.cpp**
- **T/AST/AngelscriptNativeASTTraversalTests.cpp**
- **T/AST/AngelscriptNativeASTControlFlowTests.cpp**
- **T/AST/AngelscriptNativeASTCodecTests.cpp**

Important existing Builder scenarios include `IllegalOrderDoesNotConsumeOrPoisonTheCurrentStage`, `InvalidOptionsRejectBeforeLexing`, `ForeignDiagnosticSnapshotRejectsTheBuilderInput`, `RecoveryStopsDefinitionPublicationAndKeepsFailureObservation`, `DirectSessionRecoveryCannotPublishAfterDeclarationFailure`, and `LayoutFailureRetainsExactReasonAndDoesNotFreezeTheDraft`.

## Cross-cutting current losses and acceptance obligations

- Related ranges and Fix-Its exist structurally, but the inspected source producers do not populate them. **T/SourceDiagnosticsTests.cpp** currently exercises manually constructed records; those tests do not establish real producer coverage.
- No explicit primary/note relationship exists. Independent global record sorting cannot preserve a diagnostic group as one unit.
- `SerializeStable` is an abbreviated text projection rather than a lossless structured interchange format.
- Root errors can be followed by duplicate `recovery`, `*-analysis-failed`, and Builder wrapper reports.
- Ambiguous lookup, incompatible candidates, invalid types, and invalid host metadata can all surface as unresolved names/calls.
- Constant dependency cycles, unresolved references, budgets, and inheritance depth/cycles lose distinctions at aggregation boundaries.
- Type mismatch messages commonly contain reason tags rather than semantic expected/actual types and declaration context.
- The inspected current warning families are `deprecated-function-call`, `nodiscard-call-result-unused`, and `implicit-case-fallthrough`; warning-policy tests must exercise real producers, not only synthetic records.
- Some source-less errors disappear and some definition errors lose an already available source range.

Tasks 1.2 and 3.1 must prove result ownership after caller-owned Builder/input/host handles are released, invalid snapshot/range rejection, and accurate UTF-8/UTF-16 boundary conversion. Tasks 3.2 and 3.3 must prove that queries reuse actual semantic bindings without mutating normal compilation state or fabricating host source locations.

Task 4.1 closes coverage only when every currently supported producer branch has a concrete disposition and behavioral evidence. Re-scan the owning sources at implementation time because this planning snapshot is not permission to omit subsequently discovered branches. Preserve unrelated work and use evidence-gated Replan if newly discovered behavior invalidates an accepted requirement or architectural boundary.
