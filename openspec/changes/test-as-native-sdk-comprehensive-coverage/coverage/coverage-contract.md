# Combination Coverage Contract

## Completion is row-based, not count-based

Every planned language, API, implementation, and debug behavior is represented by a stable coverage ID. The final audit derives the expected IDs from checked-in catalogs and derives implemented IDs from test annotations or declarations. Completion requires an exact reconciliation:

`Expected = ImplementedPassing + ApprovedExcluded + ApiDeferred + DisabledFuture238`

The audit fails for a missing ID, duplicate implementation, unknown ID, owner mismatch, evidence mismatch, or an exclusion without a concrete reason.

Physical source lines and `TEST_METHOD` counts are reported for scale only. They are never operands in the completion equation.

## Required record fields

Each coverage entry records:

| Field | Meaning |
| --- | --- |
| ID | Stable domain/theme/contract/case identifier, for example `LANG-FN-PARAM-I32-INOUT-MIDDLE-03` |
| Theme | One semantic owner such as Functions, Constructors, or ContextLocals |
| Element | Concrete syntax or API element under test |
| Dimensions | Named axis values that make this case distinct |
| Classification | CurrentFork, Compatible238, RejectByFork, Future238Disabled, or ApiDeferred |
| Expected result | Exact compile result, diagnostic category, execution value, state transition, callback event, metadata, or lifecycle count |
| Evidence layers | Compile, Diagnostic, Runtime, Metadata, Bytecode, Lifecycle, Debug, Cleanup, Isolation as applicable |
| Planned owner | Final `.cpp`, CQTest class, and method or tightly related batch name |
| Implementation state | Pending, Implemented, Verified, Excluded, Deferred, or Disabled |
| Rationale | Required for Excluded/Deferred/Disabled and for any reduced product |

## Semantic dimensions and equivalence classes

Dimensions are finite semantic partitions, not arbitrary sample values. A partition is separate when the compiler/runtime uses a different token, type category, ABI path, storage/lifetime path, resolution rule, control-flow edge, or diagnostic rule.

Default cross-theme type partitions are:

- signed integers: `int8`, `int16`, `int`/`int32`, `int64`;
- unsigned integers: `uint8`, `uint16`, `uint`/`uint32`, `uint64`;
- floating: current `float`, `float32`, `float64`, `double` aliases/configurations as exposed by this fork, including the double-backed ABI distinction;
- boolean;
- enum and typedef/alias where the current fork exposes them;
- script value object/struct;
- script reference/class object under the fork's automatic-reference rules;
- native registered value object and native registered reference object where needed to prove SDK embedding behavior;
- funcdef/delegate/function identity where exposed;
- `void` for returns;
- null/reference absence where legal.

Value partitions are chosen per type:

- zero/default, one/small positive, negative where legal;
- minimum, maximum, just-inside and just-outside representable boundaries;
- signed/unsigned crossing values;
- floating `+0`, `-0`, finite fraction, large/small magnitude, infinity/NaN where accepted by the relevant path;
- empty, one, many for sequences/scopes/calls;
- null, one alias, two distinct objects, base view, derived view for references;
- valid, invalid, ambiguous, inaccessible, expired, and malformed for resolution/lifetime contracts.

## Product policies

### Complete local product

All legal cells of the listed dimensions are required, plus explicitly listed illegal boundary cells. Use this policy when the axes participate in the same compiler/runtime decision. Examples:

- parameter direction × supported parameter type category;
- operator token × supported operand category × assignment/value role;
- constructor accessibility × call site;
- loop form × iteration count × control transfer;
- stack frame × debug query family;
- local variable storage/type × in-scope state × frame level.

### Complete constrained product

Generate all cells that satisfy declared constraints. Rejected cells are not silently dropped; constraint rules are part of the catalog and representative rejected cells verify each rejection rule. This is used when syntax has legal-shape rules such as default arguments trailing required arguments, `out` requiring an assignable lvalue, or access modifiers depending on call site.

### Interaction product

All cells across a smaller set of axes are required because one feature changes another's resolution, state, or lifetime. Examples include overload × conversion, constructor × member initializer × exception point, and inheritance × virtual property × const receiver.

### Proven-independent reduction

Reduction is allowed only when source evidence or a completed characterization proves that axes use the same implementation path and cannot change the outcome. The catalog must name the proof and retain boundary representatives. A bare claim that the full product is “too large” is invalid.

### Cross-theme chain

Named end-to-end scenarios cover interactions across multiple owners without forcing every unrelated cross-theme combination. Each chain records the themes, observable result, failure point, cleanup expectation, and why the combination is risk-bearing.

## Case implementation forms

### Independent scenario method

Preferred for unique grammar, invalid diagnostics, lifecycle, callback, exception, or state-transition behavior. The `TEST_METHOD` name states the subject and expected behavior.

### Tightly related case batch

Allowed for repetitive type/value products when all cases:

- belong to one semantic contract;
- have stable individual coverage IDs and assertion messages;
- use exact declarations rather than name lookup;
- continue after a non-fatal cell failure where safe so all failed IDs are reported;
- do not reduce results to one aggregate count;
- expose per-cell expected and actual values;
- are reconcilable by the static audit.

### Explicit AS fixture with multiple entry functions

Preferred over runtime string concatenation for readable valid-source products. One properly formatted `ASTEST_AS_ANSI(R"AS(...)AS")` fixture may define multiple focused functions; the C++ test executes each by exact declaration and associates it with a stable coverage ID.

### Separate invalid fixture

Compile-failure cases use one owning error per fixture whenever possible. A fixture must not contain several unrelated errors whose ordering could hide the intended diagnostic.

### Declarative generation

Mechanical generation may be introduced only if the checked-in input is readable, each generated case is independently identifiable, output obeys the inline-AS rule, generation is deterministic/offline, generated artifacts are reviewable, and build/test execution does not require an external dependency. The implementation plan must prefer explicit fixtures until repetition demonstrates that generation improves rather than obscures review.

Every generated AngelScript module SHALL print its complete source before compilation through the shared source-reporting helper. The Automation log record includes a stable product/case ID, module name, one-based AS line numbers, and explicit begin/end markers. Rebuilt or rebound variants print separately. Failure-only printing is insufficient because successful generated fixtures must remain available for review and learning after the run.

## Evidence requirements

| Behavior | Minimum evidence |
| --- | --- |
| Pure token/grammar acceptance | token/node/compile result plus exact range or metadata where observable |
| Executable syntax | successful build plus return value, mutation, dispatch marker, or state transition |
| Resolution | selected declaration/function/type identity plus runtime result where callable |
| Negative syntax/type rule | exact return code and one stable owning diagnostic category/location/text fragment |
| Object/value behavior | values plus construction/copy/assignment/destruction counts and alias independence where applicable |
| Exception | context result, text, function, section, row/column, stack, cleanup, and reuse where applicable |
| Debug API | callback sequence or exact frame/variable/function/source data plus invalid-state behavior |
| Serialization | pre-save metadata/result, post-load identity/metadata/result, and corrupt/truncated recovery |
| Optimization/bytecode | executable equivalence plus relevant opcode/control/debug marker invariants |
| Rejection by fork | enabled negative assertion; no permissive alternative outcome |
| Future 2.38 | compiled Disabled test with real desired assertions and `#as-v238-backport` tag |

## Formatting and ownership

- New files and methods state their concrete subject; generic coverage labels are not used in new names.
- All ordinary inline scripts use visually indented `ASTEST_AS_ANSI(R"AS(...)AS")`, Allman braces, and required blank lines.
- Exact-layout fixtures use `ASTEST_AS_ANSI_PRESERVE_LINES` or the approved equivalent and an adjacent explanation.
- CQTest registration and methods remain inside `#if WITH_ANGELSCRIPT_UNITTESTS`.
- Each test owns its raw engine/module/context state and releases it through RAII.
- Shared helpers remain narrow; scenario flow and expected evidence remain visible in the owning `TEST_METHOD`.

## Audit outputs

The implementation produces source-derived reports for:

- expected, implemented, excluded, deferred, Disabled, and verified coverage IDs;
- per-theme dimension values and product cardinalities;
- missing/duplicate/unknown IDs;
- evidence-layer satisfaction;
- API symbol-to-test ownership;
- current-fork and selected-2.38 classifications;
- inline-AS formatting violations and approved exact-layout exceptions;
- active/Disabled test definitions, files, and latest pass results.
