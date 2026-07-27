# Plan Review

## Review result

The plan is ready for implementation after user approval. It is intentionally much stricter than `refactor-as-native-sdk-regression-suite`: completion is tied to stable semantic IDs, complete local products, evidence layers, predecessor reconciliation, direct API ownership, formatting checks, and verified reports rather than directories, broad method names, or counts.

No test implementation, build, or automation execution is part of this planning pass.

## Requirement trace

| User requirement | Recorded response |
| --- | --- |
| Create a new OpenSpec | New change `test-as-native-sdk-comprehensive-coverage`; predecessor remains historical. |
| Coverage was far too shallow | `background.md` proves 25/222 exact predecessor scenarios present and 197 missing. |
| Language needs comprehensive coverage | Fourteen dedicated catalogs enumerate syntax elements, dimensions, products, boundaries, evidence, and owners. |
| Elements should receive Cartesian-product coverage | `coverage/coverage-contract.md` requires complete local/constrained products and source-backed reasons for every reduction. |
| Function parameter lists need all directions/combinations | `coverage/functions.md`, specs, and tasks cover type × direction, position × direction, arity × target, defaults × omission, returns × paths, overload dimensions, argument sources, recursion, indirect calls, ABI, lifecycle, and failures. |
| Constructors/properties/other language subjects need equal depth | Separate catalogs and task groups cover properties, constructors, destructors, inheritance, references, expressions, operators, conversions, control flow, foreach, exceptions, variables, and declarations. |
| Refer to previous UE AS Coverage work | `references/ue-as-coverage-lessons.md` records the reviewed OpenSpec/source practices and explicitly adapts them to raw SDK boundaries. |
| Do not rely on generic file/topic naming | New artifacts/files/classes/tasks use concrete semantic subjects; the rejected generic English term does not occur in this change. |
| Native AS debug was missing | `coverage/native-debug.md`, a dedicated capability spec, impact owners, and Runtime tasks cover all public/fork callback/frame/local/receiver/nested/function-metadata families. |
| Inline AS layout violates UnitTest style | Baseline findings, formatting classification, a static audit, ordinary migration, preserve-lines exceptions, and post-migration verification are required. |
| Use CQTest and AS conventions | Specs/tasks require gates, `TEST_CLASS_WITH_FLAGS`, scenario `TEST_METHOD`s, matcher assertions, raw ownership, exact lookup, `ASTEST_AS_ANSI`, Allman braces, and spacing. |
| Test core only, not add-ons | Proposal/spec/design/audit exclude every SDK add-on and UE wrapper/debug integration; minimal local native fixtures are allowed. |
| Current fork first, selective 2.38 later | Enabled singular current behavior, enabled rejections, compiled Disabled/tagged future tests, and API-deferred absent symbols are distinct. |
| Physical source scale | No line-count goal remains. Generated sources are retained only where they preserve readable, independently verifiable semantic cases; completion remains semantic and source-verifiable. |
| Minimize compile frequency | Tasks 1–18 forbid planned per-file builds/tests; task 19 is the first integration build after all planned code/static reconciliation. |
| Cover all impacts/tasks | `impact-map.md` covers source groups, runtime access, helpers, parent docs/config, static artifacts, build/runtime, dirty files, dual-repo commits; `tasks.md` contains 243 tracked tasks. |

## Coverage-design review

### Language themes

All fourteen predecessor themes have dedicated design owners:

1. declarations;
2. functions and parameter lists;
3. variables and scope;
4. stored/virtual/indexed properties;
5. constructors and initialization;
6. destructors and exit lifetime;
7. inheritance and dispatch;
8. automatic references/aliasing/null;
9. expressions and evaluation;
10. operators;
11. conversions and casts;
12. conditionals/loops/switch/jumps;
13. `foreach` protocol;
14. exceptions/propagation/recovery.

Each includes positive, boundary, invalid, lifecycle/state, interaction, cleanup, current-fork, and future/deferred classification where applicable. Cross-theme chains prevent isolated theme completion from hiding constructor/property/inheritance, overload/conversion/reference, exception/debug, optimization/debug, module/metadata, or GC/teardown defects.

### Non-language domains

The plan does not focus so narrowly on language syntax that the predecessor's other missing rows remain open. Separate tasks cover:

- complete token/parser/node/source behavior;
- engine profiles/properties/lifecycle/memory/atomic/threading;
- builder/compiler/instruction/bytecode/optimization behavior;
- runtime invocation/state/object/GC;
- module lifecycle/sections/lookups/imports/persistence/corruption;
- type metadata/config groups/globals/enums/aliases/funcdefs/traits;
- embedding registration/calling conventions/generic/object/interface/JIT/string/thread/user-data;
- current-fork and selected-2.38 conformance.

### Native debug

The design explicitly includes:

- exception, instruction, line, loop-detection, and stack-pop callbacks;
- install/replace/clear/reuse behavior;
- instruction phase/opcode/user data;
- frame count/function/blueprint frame/line/column/section;
- local count/name/declaration/type/address/scope/value;
- shadowed and caller-frame variables;
- `this` type/pointer across global/base/derived/virtual frames;
- nested state counts, outer restoration, inner errors, invalid pops;
- concrete stack frame pointer/size safety;
- function locals/declarations/next executable lines/bytecode;
- valid, invalid, optimized, rebuilt, saved/loaded, and cleanup states.

UE DebugServer/DAP is correctly excluded rather than counted as native evidence.

## Lessons applied from the prior Coverage suite

The plan retains:

- type-specific and role-specific owners;
- all primitive-width and parameter-direction expansion;
- scenario-level rows;
- runtime assertion over compile-only claims when behavior is executable;
- explicit unsupported/rejection boundaries;
- interaction permutations and copy/lifecycle independence;
- source reconciliation and false-gap correction.

It improves:

- stable per-cell IDs instead of relying on broad aggregate methods;
- complete local products with explicit reduction proof;
- smaller semantic test implementation locations instead of one enormous translation unit;
- raw-SDK rather than UE observation points;
- current inline-AS formatting;
- direct debug coverage;
- independent expected/source/report reconciliation.

## Execution-risk review

- The plan may generate very large source and long automation runs, but it has decomposition, prefix, per-cell ID, timeout, unity-build, and failure-batching controls.
- Hazardous debug/internal-state cases are isolated and cannot be placed in broad batches.
- Diagnostic tests use stable categories/location/fragments rather than brittle full-message snapshots.
- Exact-layout tests are protected from accidental dedent changes.
- Existing dirty work is explicitly preserved; source additions prefer new owners and overlapping dirty runtime/config files require coordination.
- No source generator is assumed. It requires a separate evidence-based decision after explicit products expose real repetition.

## Remaining implementation-time decisions

These are bounded characterization questions, not missing planning scope:

- exact current classification for tokenizer/parser forms whose older records conflict with vendored tokens;
- stable versus characterization-only callback event counts under optimization;
- whether explicit deterministic source generation improves reviewability for repetitive primitive products;
- which predecessor scenarios were invalid requirements rather than merely unimplemented.

Tasks 1.3, 1.8, 1.12, 1.13, and the debug inventory resolve these before affected tests are represented as complete.

## Final planning gate

The change may move to implementation only if the implementer agrees that:

- no theme closes from counts;
- no local product cell is silently omitted;
- no current test is deleted before reconciliation;
- no enabled test accepts contradictory current/future outcomes;
- no add-on or UE debugger integration is used to satisfy raw coverage;
- no planned build occurs before sections 1–18 are code-complete and statically reconciled, except one explicitly justified structural blocker build;
- final verification includes source IDs and report evidence, not just green method totals.

## Implementation review checkpoint (2026-07-24)

The first implementation batches now have evidence-backed closure for
NativeDebug/Runtime.Debug, ControlFlow, Declarations, Destructors, and the
Constructor Failure teardown order. The latest full SDK report is
**478/535 PASS, 57 FAIL, 0 not-run, 0 in-process**, with normal shutdown and no
crash. This is a progress checkpoint rather than a final approval: the 57
remaining owners are still active and are not reclassified merely because the
runner exported a report.

The review specifically confirms that the Destructors batch did not trade depth
for green counts. It retains member-count, base/derived, reference, partial
construction, exception, global, parameter, transfer, metadata, and cleanup
axes; every generated source is printed; and current-fork restrictions are
asserted with diagnostics and fresh-module cleanup. Three runtime defects were
repaired in the compiler/interpreter, while Abort/Suspend, mutable globals,
value-parameter normalization, and missing automatic special members remain
explicit enabled characterization products. The Constructor Failure owner now
shares the verified reverse teardown sequence.

The remaining review work is theme-by-theme diagnosis of Exceptions,
Expressions, Foreach, Functions, Inheritance, Interactions, Operators,
Properties, References, and Variables, followed by the full static audits and
the native/full suite. No final completion or commit should be claimed until
those owners have focused evidence and the aggregate result is rerun.

## Latest code-quality review — 2026-07-24

The focused depth batch was re-reviewed against `Documents/UnitTest/UnitTest.md`
after the first implementation failures. The review found and corrected one
real lifecycle-policy oracle defect: the raw harness enables
`asEP_DISALLOW_VALUE_ASSIGN_FOR_REF_TYPE`, so the restricted
`AssignScriptObject` result must be `asNOT_SUPPORTED`; the positive path is
tested only while the property is temporarily disabled and is restored by RAII.
The other intermediate red reports were either a fixture expectation/length
mistake, unsafe fork probing, a declaration-normalization mismatch, or an
over-specific bytecode-shape assertion. They are retained in the verification
chronology and issues ledger.

The final review checks are green: all focused classes have explicit unit-test
gates, class-level raw engine hooks, CQTest matcher assertions, generated source
printing, Allman source formatting, per-method cleanup, and no raw SDK boundary
violations. The test-owned source contains no forbidden generic coverage label.
The full OpenSpec catalog currently reports 130 products and 40,254 expanded
cases, but broad theme closure is not implied: 180 checklist items remain open,
including parser/node/source coordinates, the remaining Engine/Compiler axes,
GC and raw-debug query families, Module/TypeSystem/Embedding closure, and
predecessor mappings. The eight new checked task rows are focused slices and a
quality checkpoint only.

The fresh full-prefix verification after this review is now **550/550 PASS**
(`Saved/Tests/as-native-sdk-full-after-depth-batch/20260724_235848_500_f1ec0f2c/Report/index.json`),
with zero failures/not-run/in-process and normal shutdown. This proves the
current scheduled owners are stable; it does not reduce the 180 open broad
checklist tasks or turn focused slices into complete theme closure.

## Latest code-quality and progress review — 2026-07-25

The Frontend parser-depth follow-up and the lifecycle refactor were reviewed
again against `Documents/UnitTest/UnitTest.md`. The recent Parser and ScriptNode
owners now use class-owned `FNativeTestEngine` lifetime hooks, explicit
`BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL` cleanup, CQTest matcher assertions,
per-method module cleanup, readable Allman-formatted generated AngelScript, and
the required source begin/content/end log records. The parser CRLF fixture was
also rewritten to keep line-ending semantics without an ordinary escaped-line
concatenation. A static search found no method-local bare-engine lifecycle calls
in `AngelScriptSDK/Frontend`.

The focused evidence is **4/4** for the new parser-depth owner,
**18/18** for the shared-engine declaration owner, and **138/138** for the
complete Frontend prefix. The first aggregate rerun exposed one existing
References identity assertion under a different owner ordering; its isolated
owner rerun passed **1/1**, and the required aggregate rerun completed **554**
scheduled owners with **553 passed, one warning, zero failed, zero not-run, and
zero in-process**, normal shutdown, and exit code `0`. The warning is owned by
the existing `NativeDebug.CallbackLifecycle` state-path test; it is not a
failure or crash and remains visible in the report.

The final static review is clean: **134 products**, **40,273 expected IDs**,
**40,206 current-fork IDs**, and **65 selected-2.38 Disabled IDs**; source
reconciliation reports **133 implemented**, **1 Disabled implemented**, and
**0 incomplete**; raw SDK boundary violations are **0**; API inventory is
**370 rows / 299 observed / 0 missing direct Debug calls**; inline-AS formatting
is **213 conforming / 0 violations**; strict OpenSpec validation passes. These
are source/catalog and scheduled-owner results, not a claim that every planned
language requirement is complete.

The task file currently contains **347 checklist rows: 167 checked and 180
unchecked**. The remaining 180 are broad depth and closure work rather than
180 currently failing owners. They include the remaining Frontend taxonomy and
predecessor mappings, Engine and Compiler axes, declaration/property
reclassification, StaticJIT constructor/reference parity, operators and
conversions, control flow, Runtime object/GC/raw-debug queries, Module,
TypeSystem, Embedding, Conformance, cross-theme chains, final source-style
migration, and the domain/native/full-suite closure and commit review. The
focused slices completed so far must not be counted as closure of those broader
requirements.
## Latest Conversions/Engine follow-up review — 2026-07-25

The numeric conversion and boundary owners were checked again against
`Documents/UnitTest/UnitTest.md`. Their raw engine is class-owned with explicit
`BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL` hooks, and the generated source/count
assertions remain in the scenario methods. One compile warning/error surfaced while
introducing the shared member (`C4458`, helper parameter `Engine` shadowing the
member); it was fixed by renaming the parameter to `NativeEngine` and was recorded
as a test-structure issue rather than hidden.

The Engine message callback follow-up now has two focused owners with direct raw SDK
calls, CQTest matcher assertions, per-method callback isolation, complete source
printing, and no UE/add-on integration. The coherent build passed; Conversions passed
17/17 and Engine passed 21/21 with zero failed/not-run/in-process entries. Static
catalog validation reports 136 products and 40,329 unique expected IDs. These are
focused evidence only: **180 broad checklist items remain unchecked**, so neither
domain is being declared complete from these passes.

The follow-up static sweep is also clean: source reconciliation reports **136
products, 135 implemented, one Disabled implemented, and zero incomplete**; the
boundary audit reports **0 violations**; API-use inventory is **370 rows / 300
observed / 0 missing direct Debug calls**; inline-AS formatting remains **213
conforming / 0 violations**; strict OpenSpec validation passes. The task file now
has **348 rows: 168 checked and 180 unchecked**. The unchecked count is the
remaining planned work, not a count of currently failing automation owners.
## Runtime Debug lifecycle follow-up review — 2026-07-25

The Runtime.Debug owners were reviewed against `Documents/UnitTest/UnitTest.md`
after the lifecycle repair. All six classes now own their raw SDK engine at class
scope and use `BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL`; direct Debug API calls,
CQTest matcher assertions, module/context RAII, and generated source logging remain
in the scenario methods. The concentrated build passed and the Runtime.Debug
prefix is **5/5** with no warnings or failures. This removes a concrete test-quality
defect, but it does not turn the broader Runtime Debug task group into a completed
theme; the remaining query and save/load products still require their own evidence.

After this repair the task file contains **349 rows: 169 checked and 180
unchecked**. Catalog/source/boundary/API/format counts remain unchanged from the
Conversions/Engine sweep because this batch changes ownership structure rather than
adding a product: **136 products**, **40,329 expected IDs**, **135 implemented + 1
Disabled implemented**, **0 incomplete**, **0 boundary violations**, **370 API rows / 300
observed / 0 missing direct Debug calls**, and **213 conforming inline-AS sources**.
The affected Runtime domain was rerun after the focused Debug check and completed
**32/32** owners with no failures, missing runs, or in-process entries. This is a
domain regression checkpoint only; the full SDK prefix still needs to be rerun after
the current batch and the remaining broad tasks remain open.

## ControlFlow loop-depth review — 2026-07-25

The LoopDepth owner was reviewed against `Documents/UnitTest/UnitTest.md`. It is
gated by `WITH_ANGELSCRIPT_UNITTESTS`, uses one class-owned raw SDK engine with
`BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL`, resets the engine before each generated
cell, uses CQTest matcher assertions, prints every generated source, and performs
exact declaration lookup plus explicit module cleanup. The generated AngelScript
uses Allman braces and readable one-statement-per-line builders. It stays within
the native SDK boundary: no UE object wrappers, bindings, add-ons, or
`FAngelscriptEngine` integration are involved.

The depth is substantive rather than a single smoke case: loop kind, count, and
transfer are all independently enumerated, yielding 48 stable IDs. Body,
condition, and increment counters make `break`, `continue`, `return`, zero entry,
and terminal-condition behavior observable. The first focused run found a real
oracle mistake for `do_while` + `break`; the expected post-body condition count
was corrected and the same generated cell was rerun. The owner now passes 1/1,
and the ControlFlow prefix was rerun as a domain checkpoint before the lifecycle
repair was recorded below.

The catalog is now **137 products / 40,377 expected IDs** (**40,310
current-fork**, **65 selected-2.38 Disabled**). The task file contains **352
rows: 172 checked and 180 unchecked** after this focused slice and lifecycle
repair. These counts are
planning and evidence counts, not a claim that the remaining ControlFlow or
Language themes are complete.

The post-LoopDepth static sweep is clean: catalog validation reports 137 products,
40,377 expected IDs, 40,310 current-fork IDs, 65 selected-2.38 Disabled IDs, and
40,377 unique IDs; source reconciliation reports 136 implemented products, one
Disabled implementation, and zero incomplete products; the native SDK boundary
audit reports zero violations; API-use inventory reports 370 rows / 300 observed /
zero missing direct Debug calls; inline-AS formatting reports 213 conforming raw
sources / zero violations; and `openspec validate ... --strict --json` passes.

The follow-up ControlFlow lifecycle review also covers the three pre-existing
owners, not only the new LoopDepth source. Conditions, StatementTransfers, and
Switch now have class-owned engines and explicit lifecycle hooks; a scoped search
finds no method-local `CreateBareSdkEngine`, `ASTEST_CREATE_ENGINE_NATIVE`, or
`ON_SCOPE_EXIT` engine destruction in the ControlFlow directory. The one coherent
build and the complete ControlFlow regression both pass 5/5. This is a quality
repair and regression checkpoint, while the remaining semantic ControlFlow work
is still open.

The `for`-clause addition was reviewed for depth and safety: all three clause
presence axes are independent, count bounds include zero/one/many, the initializer
and helper calls provide direct event observability, and omitted-condition cells
cannot hang because the generated source includes an explicit break. Every source
is printed, exact `Entry()` and bytecode checks are retained, and module absence is
asserted after each cell. The focused owner is 1/1 and the complete ControlFlow
prefix is 6/6. The catalog is now **138 products / 40,401 expected IDs** (**40,334
current-fork**, **65 selected-2.38 Disabled**); the task file contains **353 rows:
173 checked and 180 unchecked**. This remains a focused slice, not broad
ControlFlow completion.

After registering the `for`-clause product, the final static sweep remains clean:
138 products / 40,401 unique expected IDs, 137 implemented plus one Disabled
implementation, zero incomplete products, zero native-boundary violations, 370
API inventory rows with zero missing direct Debug calls, 213 conforming inline-AS
sources, and strict OpenSpec validation passing.

The authoritative full SDK rerun after this batch is also clean: the current
scheduled set is **557/557 PASS**, with zero failed/not-run/in-process/warning
entries, normal shutdown, `GIsCriticalError=0`, and exit code `0`. The two new
ControlFlow owners account for the increase over the earlier 554-owner checkpoint;
the result is recorded at
`Saved/Tests/as-native-sdk-full-after-controlflow-for-clauses-depth/20260725_013116_480_761aa9c3/Report/index.json`
as a fresh aggregate report. The task file now contains
**354 rows: 174 checked and 180 unchecked**. The unchecked rows are remaining
planned semantic depth, not current automation failures.

The nested-target slice now adds another independent ControlFlow product: 3
nesting shapes × 3 transfer forms × 2 target levels = 18 generated IDs. The
owner's C++ trace oracle was reviewed against the emitted AngelScript for inner
and outer `break`, `continue`, and `return`; the transfer statements remain in
the actual generated loop bodies. Focused execution is 1/1 and the complete
ControlFlow prefix is 7/7. The catalog is now **139 products / 40,419 expected
IDs** (**40,352 current-fork**, **65 selected-2.38 Disabled**), and the task file
contains **355 rows: 175 checked and 180 unchecked**. The remaining open items
include transfer-time destructor order, invalid jump placement, and bytecode
target correlation; they are not being inferred from this focused owner.

The nested-target batch is now followed by a fresh full SDK run: **558/558 PASS**,
zero failed/not-run/in-process entries, normal shutdown, `GIsCriticalError=0`, and
no crash marker. The catalog is **139 products / 40,419 expected IDs** (**40,352
current-fork**, **65 selected-2.38 Disabled**); source reconciliation remains
138 implemented + 1 Disabled with zero incomplete. The task file contains **356
rows: 176 checked and 180 unchecked**. The open count is the remaining semantic
plan, not a count of failing scheduled tests.

The Exceptions owners were then reviewed for class-level raw SDK lifecycle and
the complete SDK prefix was rerun. The two existing owners now share explicit
`BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL` hooks while keeping their native bridges,
debug callbacks, generated-source logging, context recovery, and module cleanup.
The fresh aggregate report is
`Saved/Tests/as-native-sdk-full-after-exceptions-lifecycle-depth/20260725_015116_557_b9bdd278/Report/index.json`
with **558/558 PASS**, no failed/not-run/in-process/warning entries, normal
shutdown, and no crash marker. This is a test-structure and regression-quality
checkpoint only; the open task count is now **357 rows: 177 checked and 180
unchecked**, and the unchecked rows still represent planned semantic depth rather
than current automation failures.

The Foreach owners were then reviewed under the same lifecycle rule. The 640
iteration combinations and 250 protocol combinations remain unchanged and still
print their generated AngelScript before each build. Both owners now use explicit
class-level engine hooks; the Foreach prefix is **2/2 PASS**, and the fresh full
SDK report `Saved/Tests/as-native-sdk-full-after-foreach-lifecycle-depth/20260725_015750_029_f12ef02d/Report/index.json`
is **558/558 PASS** with no warning, failure, missing, in-process, or crash entry.
The current planning count is **360 rows: 180 checked and 180 unchecked**. The
remaining 180 rows are still planned semantic depth, including Foreach transfer,
lifetime, structural mutation, and complete `opFor*` failure combinations; they
are not current automation failures.

The ControlFlow transfer-validity slice adds a genuine current-fork semantic
owner rather than only a lifecycle repair. Four owning placements × two transfer
kinds produce eight generated sources: ordinary function and branch reject both
transfers, switch accepts only `break`, and loop executes both with distinct
target results. The focused owner and complete ControlFlow prefix pass 1/1 and
8/8; generated rejection sources are printed with their diagnostics. The fresh
full SDK report is **559/559 PASS** with no failed/not-run/in-process/warning or
crash entry. A source-format review then corrected the generated transfer
statement indentation and removed whitespace-only assembly lines; the focused
owner remained **1/1 PASS**, and a fresh full rerun again records **559/559 PASS**
with normal shutdown and `GIsCriticalError=0`. The current planning count is
**364 rows: 184 checked and 180 unchecked**; the remaining rows still represent
planned semantic depth and not current automation failures.

The switch-placement slice then adds sixteen current-fork diagnostic products:
four enclosing placements × four invalid case/default forms. Its focused owner
is **1/1 PASS**, all generated sources are printed, and module cleanup is
asserted. The authoritative full SDK rerun now contains **560 passed tests**:
**559 without warnings and 1 with the established CallbackLifecycle warning**,
with zero failed/not-run/in-process tests, normal shutdown, `GIsCriticalError=0`,
and exit code `0`. The current planning count is **366 rows: 186 checked and
180 unchecked**. The unchecked rows are still planned semantic depth rather
than current automation failures; the scheduled test total is distinct from
the catalog's **141 products / 40,443 IDs** (**40,376 current-fork**, **65
future Disabled**).

The Frontend tokenizer owner was then extended from the initially active keyword
spellings to the complete token-family comparison against `as_tokendef.h`. The
first probe failed because it assumed `funcdef` was active; source inspection
showed the fork intentionally comments out that `tokenWords[]` registration, as
it does for the other selected 2.38-style spellings. The corrected test records
those exact `ttIdentifier`/`ttNot` outcomes, labels the generated source as
fork-rejected where applicable, and preserves identifier-suffix checks only for
identifier-like inputs. The repaired tokenizer prefix is **5/5 PASS**, and the
fresh full SDK aggregate is **560/560 PASS** with zero warnings, failures,
not-run, or in-process entries and normal shutdown. The task count is now
**368 rows: 188 checked and 180 unchecked**; the unchecked tasks remain planned
semantic depth rather than current regression failures. The catalog is **141
products / 40,465 IDs** (**40,398 current fork**, **65 future Disabled**).

The operator owner was then widened to the remaining punctuation and longest-
match definitions: slash/divide-assignment, percent/modulo-assignment,
bitwise-not, dot, scope, statement/list/block/grouping delimiters, question,
colon, and the fork-rejected `@` handle spelling. The focused tokenizer owner
is **5/5 PASS**, and its generated source prints each input. The authoritative
full SDK rerun is **560/560 PASS** with zero warnings/failures/not-run/in-process
entries and normal shutdown. The planning count is now **370 rows: 190 checked
and 180 unchecked**. The catalog is **141 products / 40,483 IDs** (**40,416
current-fork**, **65 future Disabled**). The 180 unchecked rows are still
semantic-depth work, not current test failures.

The Runtime Debug callstack owner was then extended with a boundary-focused
product: one-frame, three-frame, and recursive-depth execution paths crossed
with first, last, and exact-depth queries. Valid frames retain function, line,
pointer, and size evidence; exact-depth queries return the current fork's null
function/frame and invalid line result. The first build's missing lambda
`this` capture was recorded and repaired. The focused owner is **1/1 PASS**,
and the authoritative full SDK rerun is **560/560 PASS** with zero warnings,
failures, not-run, or in-process entries and normal shutdown. The planning
count is now **373 rows: 193 checked and 180 unchecked**. The catalog is **142
products / 40,492 IDs** (**40,425 current-fork**, **65 future Disabled**).

The tokenizer text owner was then expanded to 23 exact inputs covering CRLF
whitespace/comments, empty and unterminated blocks, string/character escape
forms, CRLF multiline and heredoc text, escaped backslashes, and UTF-8 byte
lengths. The focused tokenizer owner is **5/5 PASS** with every input printed;
the authoritative full SDK rerun remains **560/560 PASS**, with zero warnings,
failures, not-run, or in-process entries and normal shutdown. The planning
count is now **374 rows: 194 checked and 180 unchecked**. The catalog is **142
products / 40,504 IDs** (**40,437 current-fork**, **65 future Disabled**).

The next quality review covered all ten Functions raw-SDK owners. Their
semantic products were already substantial, but method-local engine creation
did not meet UnitTest.md's class-level lifecycle rule. The repair moved each
owner to one class-owned engine with explicit creation, per-method reset, and
final destruction, without reducing any generated parameter/default/reference/
return/indirect-call/recursion/lifecycle case or its source output. A first
build exposed C4458 name hiding in the indirect-call helpers; the member was
renamed and the helper arguments were preserved. The repaired build passed,
the Functions prefix passed **14/14**, and the fresh SDK prefix passed
**560/560** with no warnings, failures, missing, in-process, or crash results.
The checklist is now **376 rows: 196 checked and 180 unchecked**. The catalog
remains **142 products / 40,504 IDs** (**40,437 current-fork**, **65 future
Disabled**). The unchecked rows continue to represent planned semantic depth,
not current automation failures.

The Functions semantic follow-up adds a real signature-shape owner. Four
arities × four scalar type arrangements × four direction arrangements × three
targets produce 192 stable generated IDs in one printed source. The owner
asserts exact parameter count/type/direction metadata, configured float type
identity, exact entry invocation, return aggregation, and caller writeback for
out/inout arguments. Its initial invalid temporary calls, namespace lookup, and
float type-id oracle were repaired from direct compiler/API evidence and retained
in issues.md. The signature owner passes **1/1**, the Functions parent passes
**15/15**, and the full SDK prefix records **560 succeeded**, one known
CallbackLifecycle warning, zero failures/not-run/in-process, and normal
shutdown. The catalog is now **143 products / 40,696 IDs** (**40,629
current-fork**, **65 future Disabled**). The checklist is now **378 rows:
198 checked and 180 unchecked**; open rows remain planned semantic depth, not
current automation failures.

The next Functions review added typed default arguments as an independent depth
owner. It crosses fourteen valid arity/omission pairs, four homogeneous or
alternating int/bool type arrangements, and three call targets for **168
isolated generated cells**. Every cell prints source and checks exact scalar
type metadata, the fork's normalized `asTM_CONST` by-value flag, parameter names,
canonical default-expression metadata, runtime result, exact entry lookup, and
module cleanup. The first compile and two fork-oracle mismatches are recorded in
issues.md; no case was disabled. The final owner is **1/1 PASS** with 168 unique
source IDs, the Functions parent is **16/16 PASS**, and the fresh SDK aggregate is
**562/562 PASS** with zero warnings/failures/not-run/in-process entries, normal
shutdown, exit code 0, and no crash. The checklist is now **380 rows: 200
checked and 180 unchecked**. The catalog is **144 products / 40,864 planned IDs**
(**40,797 current-fork**, **65 future Disabled**); open rows remain planned
semantic depth rather than current failures.

The next Functions review adds parameter-list scale and scalar-type depth as a
separate product. Eight arity scales (zero through sixty-four slots), four
homogeneous/alternating int-bool arrangements, and three declaration targets
produce **96 isolated generated cells**. Every printed source is checked for
exact slot count, scalar type IDs, names, fork-normalized `asTM_CONST` flags,
exact entry lookup, runtime aggregation, and module cleanup. The focused owner
is **1/1 PASS**, the Functions parent is **17/17 PASS**, and the fresh SDK
aggregate is **563/563 PASS** with zero warnings, failures, not-run, or
in-process entries, normal shutdown, and no crash. The full log contains
28,522 unique printed source IDs. The catalog is now **145 products / 40,960
planned IDs** (**40,893 current-fork**, **65 future Disabled**); the checklist
now has 179 open rows for planned semantic depth, not observed test failures.

An independent Runtime checkpoint was also completed after the latest Functions
addition. It schedules 32 Runtime owners, including the raw Debug descendants,
and records **32/32 PASS** with zero warnings/failures/not-run/in-process,
normal shutdown, exit code 0, and `GIsCriticalError=0`. This is intentionally
recorded as a domain checkpoint rather than as closure of the remaining Runtime
semantic, StaticJIT, or debug-metadata tasks.

The same independent-prefix review now covers Engine, Compiler, and Module.
Their results are **21/21**, **109/109**, and **41/41 PASS** respectively, with
zero warnings/failures/not-run/in-process and normal shutdown. The logs retain
30, 22, and 9 unique generated-source IDs. This confirms those domain runners
are green after the latest source addition without implying that their open
semantic, optimization, or parser tasks are complete.

After that review, the independent Runtime, Engine, Compiler, and Module
checkpoints changed the live task accounting to **384 rows: 208 checked and
176 open**. The additional checks are recorded as verification checkpoints;
they do not turn the remaining language-depth and StaticJIT tasks into green
claims without their own semantic evidence.
The Debug review then adds a dedicated uncaught-exception catchability owner.
Four nested-depth sources exercise the direct fork `asCContext` query, exact
exception function/text, retained stack depth, same-context recovery, and
module cleanup. The initial three C++ harness defects are retained in
`issues.md`; the repaired focused owner is **1/1 PASS**, the Runtime.Debug
parent is **6/6 PASS**, and the fresh SDK aggregate is **564/564 PASS** with
zero warnings/failures/not-run/in-process and 28,526 unique printed source
IDs. The catalog is now **146 products / 40,964 planned IDs** (**40,899
current-fork**, **65 future Disabled**). This closes the current-fork direct
catchability checkpoint while leaving the selected 2.38 handler behavior and
the broader debug metadata checklist explicitly open.

The live checklist after this Debug addition is **386 rows: 211 checked and
175 open**. The open set remains planned semantic and StaticJIT work; it does
not represent a failure in the new catchability owner or its aggregate rerun.

The Conversions review then repairs the existing Boolean owner’s test lifecycle
without reducing its semantic cases. The owner retains all 13 source kinds × 6
Boolean contexts × 3 values, but now uses class-owned engine lifecycle and
per-cell reset under `UnitTest.md`. Conversions is **17/17 PASS** with 7,286
unique printed sources, and the fresh SDK aggregate remains **564/564 PASS**
with zero warnings/failures/not-run/in-process. This is a structural quality
repair; remaining conversion-depth tasks stay open. Live checklist accounting
is now **388 rows: 213 checked and 175 open**.

The next Conversions review repairs the existing conversion-failure owner. It
now uses class-owned raw SDK lifecycle and per-case reset while retaining its
compile-failure/recovery combinations, diagnostic checks, generated-source
logging, and module cleanup. The repair build succeeds; Conversions is
**17/17 PASS** with 7,286 unique printed sources, and the fresh authoritative
SDK aggregate is **564/564 PASS** with zero warnings/failures/not-run/in-process
entries and 28,526 unique printed sources. This changes test structure only;
the catalog remains **146 products / 40,964 planned IDs** and the remaining
semantic checklist is still open. Live checklist accounting is now **390 rows:
215 checked and 175 open**.

The next quality batch repairs four more Conversions owners: EnumAlias,
ConversionResolution, ValueObject, and ObjectCast. Their semantic combinations
are unchanged; each now uses class-owned raw SDK lifecycle, explicit CQTest
hooks, per-case reset, printed sources, diagnostics, runtime/metadata checks,
and cleanup. The first EnumAlias build exposed and recorded one missing C++
namespace import, then the batch build succeeded. Conversions is **17/17 PASS**
with 7,286 unique printed sources, and the authoritative SDK aggregate is
**564/564 PASS** with zero warnings/failures/not-run/in-process and 28,526
unique printed sources. Live checklist accounting is now **392 rows: 217
checked and 175 open**; this is structural quality progress, not semantic
closure of the remaining conversion tasks.

The numeric conversion review now closes the previous oracle weakness. All
4,200 source/type/form/value cells remain active and source-first. Accepted
portable cells compare the VM result with an independent C++-computed literal;
rejections retain located diagnostics; and the 336 accepted float-to-integer
cells without a portable exact result are explicitly tagged as fork-limited
while retaining compile, metadata, runtime, and cleanup evidence. The focused
owner is **1/1 PASS** with 4,200 unique printed sources, Conversions is
**17/17 PASS**, and the fresh SDK aggregate is **564/564 PASS** with zero
warnings/failures/not-run/in-process and 28,526 unique sources. The initial
oracle mismatches were fixed and recorded rather than suppressed. Checklist
accounting is now **394 rows: 220 checked and 174 open**; this closes one
semantic product, not the remaining conversion/operator/runtime domains.

The EnumAlias review then removed the remaining conversion-oracle weakness in
the nominal-enum/typedef owner. All 1,260 source/target/form/value cells still
print and execute their original conversion sites; accepted cells now compare
against a C++-constructed target literal with source-width and target-width
normalization, including unsigned alias wrapping and enum member identity.
The focused owner is **1/1 PASS** with 1,260 source IDs, Conversions is
**17/17 PASS**, and the authoritative SDK aggregate is **564/564 PASS** with
28,526 unique sources, zero warnings/failures/not-run/in-process entries, and
normal shutdown. The checklist is now **396 rows: 223 checked and 173 open**;
the remaining open rows are the broader frontend, compiler, runtime, and
cross-product follow-up tasks, not missing EnumAlias evidence.
The latest Frontend tokenizer review closes the numeric literal depth item
without overstating the remaining parser work. The original numeric boundary
owner remains intact, while the new sign/termination product contributes 160
independent cells and malformed-recovery contributes 12. Sign tokens, exact
numeric token kinds and lengths, next-token boundaries, and recovery token
offsets are all direct tokenizer observations. Generated source is printed for
each cell, and the stable ID repair keeps catalog tokens separate from prose
descriptions. The focused owner is 7/7, the complete Frontend prefix is
140/140, and the authoritative SDK prefix is 566/566 with 28,698 unique
printed source IDs and normal shutdown. Static reconciliation reports 148
products, 41,136 planned IDs, 41,069 current-fork IDs, 65 future Disabled
IDs, 147 implemented, 1 intentionally Disabled, and zero incomplete records.

This closes task 3.3's numeric tokenizer requirement for the current fork;
the remaining Frontend tasks still cover parser/source-node families,
preprocessor and broader token-source behavior. The one source-accounting
defect found during the batch is retained as SDK-DEPTH-081 in `issues.md`.

The post-review formatting audit found one ordinary `"\\n"` occurrence in the
new numeric termination table. It was changed to an equivalent hexadecimal
byte representation, then rebuilt and rerun at all relevant layers. The final
focused tokenizer owner is 7/7, Frontend is 140/140, and the authoritative SDK
prefix is 566/566 with complete exit metadata and 28,698 source IDs. This
quality repair preserves the exact byte and token-length behavior; it does not
weaken or exclude the newline cell. The first host-side wait timeout after
report export is recorded as SDK-DEPTH-082, while the longer-wait rerun is the
authoritative final evidence.
The live checklist after this final verification row is **399 rows: 227 checked and 172 open**. The open rows remain the planned semantic areas beyond this tokenizer slice; none is an unrecorded failure from the numeric-depth batch.
The next Frontend depth review closes the text/escape boundary requirement
with two explicit products: 60 delimited-literal cells and 48
comment/whitespace cells. The first red run correctly exposed that raw EOF is
the fork's unrecognized-token sentinel, not `ttEnd`; a later run reproduced a
process crash in `asCTokenizer::IsIdentifier()` for the bare-tokenizer
non-ASCII successor path. The final owner does not hide either result: EOF is
asserted exactly, while the unsafe successor is logged as an explicit fork
limitation after the primary whitespace span is verified.

The final focused owner is 9/9, Frontend is 142/142, and the authoritative SDK
prefix is 568/568 with 28,700 source markers and normal shutdown. This closes
task 3.4 for current-fork tokenizer behavior while retaining the raw SDK crash
as SDK-DEPTH-083 for a future runtime repair. The live checklist is now **401
rows: 230 checked and 171 open**; the remaining open rows are other semantic
themes, not omitted text cells.

## Latest review — operator context depth (2026-07-25)

The operator review is now complete for the current tokenizer owner. The
prefix/tail owner remains in place, and the new owner adds 40 operators × 4
left operands × 4 right operands × 4 spacing forms = 2,560 direct cells. It
prints each generated input and stable ID, checks every token span, and keeps
the source in the CQTest log for later review. Numeric adjacency is not
silently forced into a standalone-dot expectation: the current fork's
trailing-dot and leading-dot float paths are asserted explicitly and recorded
in SDK-DEPTH-085.

Evidence is green at all three layers: the focused owner is 1/1, Frontend is
143/143, and the authoritative SDK prefix is 569/569 with zero warnings,
failures, not-run, or in-process entries, normal shutdown, and 28,701 printed
source markers. The static catalog is 151 products and 43,804 unique planned
IDs, with 150 implemented owners, one intentionally Disabled owner, and no
incomplete records. The checklist is **402 rows: 232 checked and 170 open**;
remaining open work is in parser, compiler, runtime, and other language
themes, not this operator slice.

## Latest review — recovery and contextual-word depth (2026-07-25)

The tokenizer owner now covers the remaining current-fork recovery and
contextual-word branches. The malformed-prefix product executes 5 unknown
prefixes × 4 recovery tails = 20 cells, and the contextual-word product
executes 3 words × 2 boundaries = 6 cells. Both print each source and stable
case ID before direct raw-tokenizer assertions. The 3.1 and 3.2 frontend
tasks are therefore closed for the current fork; 2.38-only behavior remains
explicitly rejected or Disabled rather than silently enabled.

The focused tokenizer class is 12/12, Frontend is 145/145, and the
authoritative SDK prefix is 571/571. All have zero warnings/failures/not-run/
in-process entries and normal shutdown; the SDK run contains 28,727 printed
source markers. Static records are 153 products and 43,830 unique IDs, with
152 implemented owners, one intentionally Disabled owner, and no incomplete
records. The checklist is **403 rows: 234 checked and 169 open**.

## Latest review — parser parameter and expression depth (2026-07-25)

The internal parser-class review identified two concrete gaps that were too
shallow in the predecessor owner: function declarations had only one example
per family, and expression parsing did not systematically cross operator
precedence with grouping. The repair keeps the test focused on the fork's raw
SDK parser objects (`asCParser`, `asCBuilder`, `asCScriptCode`, and
`asCScriptNode`) and does not expand into UE/add-on behavior.

The declaration owner now executes 24 cells (4 parameter forms × 3 body forms
× 2 line-ending forms), and the expression owner executes 24 cells (8
operator/grouping forms × 3 grouping forms). Source IDs are deterministic,
the complete generated source is printed before parsing, and every temporary
module is discarded. The source uses the class-owned engine and explicit CQTest
matcher assertions required by `UnitTest.md`.

The coherent build passes; the parser class is **6/6**, Frontend is **147/147**,
and the authoritative SDK prefix is **573/573**, all with zero warnings,
failures, not-run, or in-process entries and normal shutdown. The new catalog
records and reconciliation are the remaining bookkeeping checkpoint for this
batch; compiler, runtime/debug, module, embedding, and other language-depth
owners remain open and are not being counted as completed by this parser work.

## Static review checkpoint after parser registration (2026-07-25)

The new parser products reconcile cleanly: **155 products, 43,878 planned
IDs, 43,811 current-fork IDs, and 65 future-disabled IDs; 154 implemented
owners, one intentionally Disabled owner, and zero incomplete records**.
The focused parser owner remains 6/6, Frontend 147/147, and the authoritative
SDK prefix 573/573. API, boundary, inline-format, strict OpenSpec, terminology,
and whitespace checks are all green. This is a bookkeeping and evidence
checkpoint only; it does not close the remaining compiler, runtime/debug,
module, embedding, or other language-depth tasks.

## Latest review — node ownership and script-code positions (2026-07-25)

The second parser review found that the existing node-copy owner still had no
depth boundary and that `asCScriptCode` had only one CRLF declaration probe.
The new owners are direct internal-class tests: 12 deep-node cells and 12
line/column cells, with complete generated sources and stable IDs. The
statement parser is selected deliberately for nested statement roots, while
namespace cells retain full script parsing; no broad compile-only shortcut is
used.

The first red run is recorded as SDK-DEPTH-086/087. The repaired focused parser
class is **8/8**, Frontend is **149/149**, and the full SDK prefix is **575/575**;
all reports have zero warnings/failures/not-run/in-process entries and normal
shutdown. Static reconciliation now reports **157 products, 43,902 planned
IDs, 43,835 current-fork IDs, 65 future-disabled IDs, 156 implemented owners,
one intentionally Disabled owner, and zero incomplete records**. The remaining
language/compiler/runtime/debug themes stay open.

## Latest review — Power operator lifecycle depth (2026-07-25)

The Power owner was reviewed against `UnitTest.md` after its semantic products
were already green. The lifecycle now has one class-owned raw SDK engine and
context, explicit before-all/before-each/after-all boundaries, and no method-
local ownership. The refactor leaves all 1,920 current-fork generated cells in
place: 1,600 universal, 240 negative-exponent, and 80 fractional-exponent.
Source printing, independent result/diagnostic classification, bytecode checks,
follow-up execution, same-name recovery, and module cleanup remain part of each
method.

The first lifecycle build and the intermediate hook repair are retained as
SDK-DEPTH-088/089. The repaired build and focused Power owner pass; the
Operators parent is **28/28**, and the authoritative SDK prefix is **575/575**
with zero warnings/failures/not-run/in-process entries and normal shutdown.
Static scope remains **157 products, 43,902 planned IDs, 43,835 current-fork
IDs, 65 future-disabled IDs, 156 implemented owners, one intentionally
Disabled owner, and zero incomplete records**. This is a lifecycle-quality
repair, not a reduction of language coverage.
## Latest review — Engine message-callback Cartesian depth (2026-07-25)

The Engine callback owner now has explicit cross-product depth instead of
relying only on four hand-selected messages. The 36 cells cover every current
callback severity, zero/normal/large source coordinates, distinct section
names, plain/empty/punctuation payloads, exact return values, and exact native
collector records. The existing replacement/clear/restore owner remains
separate, so callback lifecycle state is not conflated with payload coverage.

The source follows `UnitTest.md`: one class-owned raw engine, explicit hooks,
generated review source printed before every direct SDK observation, and matcher
assertions in the test flow. SDK-DEPTH-090 records and resolves the registry
print-site mismatch exposed by static validation. The focused class is **3/3**,
Engine is **22/22**, and the authoritative SDK prefix is **576/576**, all with
zero warnings/failures/not-run/in-process entries and normal shutdown. Static
reconciliation is **158 products, 43,938 planned IDs, 43,871 current-fork IDs,
65 future-disabled IDs, 157 implemented owners, one intentionally Disabled
owner, and zero incomplete records**.

## Latest review — Engine atomic operation depth (2026-07-25)

The existing atomic tests had useful smoke/concurrency behavior but no
catalogued per-operation/value/mode ownership. `ENG-ATOMIC-OPERATIONS` now
retains 32 direct raw cells: four operations, four signed initial values, and
single versus four-worker execution. The aggregate assertions distinguish
set/get, monotonic increment/decrement, and balanced pairs; worker creation,
join, and release are visible in the test flow and no production global state
is torn down.

The first build exposed only a helper-parameter shadowing error (SDK-DEPTH-091),
which was corrected before runtime verification. Focused Atomic is **5/5**,
Engine is **23/23**, and the authoritative SDK prefix is **577/577**, all with
zero warnings/failures/not-run/in-process entries and normal shutdown. Static
reconciliation is **159 products, 43,970 planned IDs, 43,903 current-fork IDs,
65 future-disabled IDs, 158 implemented owners, one intentionally Disabled
owner, and zero incomplete records**.

## Latest review — Frontend internal lexical/parser classes (2026-07-25)

The direct source audit answers the internal-class question with a qualified
yes. There are dedicated raw SDK test owners for tokenizer/parser/node/code
internals: 17 Frontend files and 149 CQTest methods, including direct
`asCTokenizer::GetToken`/definition probes, direct `asCParser` entry-point and
recovery calls, direct `asCScriptNode` tree/copy observations, and direct
`asCScriptCode` position conversion. Twenty tokenizer/parser/node products are
catalogued, and the latest recorded Frontend checkpoint is 149/149 with normal
shutdown.

It is not yet correct to say that every internal method has its own closed
owner. Protected parser productions/predicates are covered behaviorally through
their public entry points but are not yet mapped one-to-one in the method audit;
`asCString` and `asCStringPointer` have inventory rows but no dedicated
class-method owner. SDK-DEPTH-092 and tasks 22.82/22.83 preserved this gap as
an explicit follow-up rather than overstating the then-current coverage. Tasks
22.82–22.84 subsequently close that accountability gap; this paragraph is
retained as the historical review snapshot.

## Latest review — Compiler builder recovery depth (2026-07-25)

`COMPILER-BUILDER-REBUILD-RECOVERY` is now an explicit 2 × 3 × 2 product: two
valid builder shapes, three invalid source families, and same/fresh engine
recovery. It uses the raw builder stages rather than the higher-level module
build shortcut, prints both source versions for every cell, checks the failure
diagnostic and lack of executable publication, and then verifies same-name
rebuild metadata and execution result 42.

The first build and source-registry validation failures are retained as
SDK-DEPTH-093/094. After repair, the focused builder owner is **2/2**,
Compiler is **110/110**, and the authoritative SDK prefix is **578/578** with
zero warnings/failures/not-run/in-process entries and normal shutdown. Static
reconciliation is **160 products, 43,982 planned IDs, 43,915 current-fork IDs,
65 future-disabled IDs, 159 implemented owners, one intentionally Disabled
owner, and zero incomplete records**. This closes the builder recovery slice,
not the remaining compiler expression/bytecode and internal Frontend method
accountability work.

## Latest review — Frontend internal-class implementation depth (2026-07-25)

The earlier qualified gap is now addressed by implementation, not by a
catalog-only claim. The dedicated tokenizer owner directly calls all six
protected character/dispatch helpers through a narrow accessor and retains a
12-character × 4-radix digit product (**48** cells). The dedicated parser
owner directly calls seven protected token predicates over **98**
predicate/token pairs, six identifier/probe pairs, and `TokenEquals`; its
oracle was aligned to the fork's actual operator families after the first
focused red result. A new native string owner covers six operations × four
source states (**24** cells) and explicit mutation/comparison/edit-distance/
pointer behavior.

`audits/frontend-internal-method-map.csv` now maps all **69** rows from the
existing internal-method inventory (10 tokenizer, 48 parser, 6 script-code,
5 script-node) to direct or behavioral evidence and an owning source file.
`asCString`/`asCStringPointer` are separately named as native-owner scope,
with no UE/add-on expansion. Every source-driven cell uses the project source
printer, and the raw owners use class-level lifecycle where an engine is
required.

The implementation batch is green: internal tokenizer/parser/string owners
are **2/2 each**, Frontend is **155/155**, and the authoritative SDK prefix is
**584/584** with zero warnings/failures/not-run/in-process, normal shutdown,
and 28,993 unique source IDs. SDK-DEPTH-095 through SDK-DEPTH-099 retain the
compile, fork-oracle, mutation-oracle, signature, and host-wait observations;
none caused a product removal or Disabled case. The remaining known raw
tokenizer non-ASCII successor crash is the previously recorded fork safety
limitation SDK-DEPTH-083.

The post-review formatting checkpoint also passed. The tokenizer's whitespace
and line-comment bytes no longer use escaped newline-bearing C++ strings;
explicit byte arrays preserve the exact input while satisfying
`ASInlineFormattingRule.md`. The rebuilt Tokenizer owner is **2/2**, Frontend
is **155/155**, and the final authoritative SDK prefix is **584/584** with
zero warnings/failures/not-run/in-process entries, normal shutdown, exit code
0, and 28,993 unique source IDs. The inline audit is **213 conforming / 0
violations**; boundary is 0 violations and API-use is 370 rows / 301 observed
/ 0 missing required direct debug calls.

## Latest review — current-fork exception-handler rejection depth (2026-07-25)

The active Exceptions scope now has an explicit negative owner for syntax that
the fork does not currently implement. This complements, rather than
duplicates, the tagged 2.38 positive desired-behavior owner. The owner covers
four handler spellings, three function placements, and two line endings for
**24** cells. It prints both the rejected fixture and the same-name recovery
fixture for every cell, then checks diagnostics, absence of a partial function,
module discard, clean rebuild, execution, return value, context unprepare, and
final cleanup.

The source follows the reviewed CQTest contract: one class-owned raw engine,
`BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL`, explicit `FNoDiscardAsserter` checks,
Allman generated AngelScript with one statement per line, stable catalog IDs,
and no external add-on or UE wrapper dependency. The first build failure was a
test-only namespace qualification defect, recorded as SDK-DEPTH-100 and fixed
without weakening the oracle or shrinking the product. Catalog validation now
reports **168 products / 44,228 expected IDs / 44,101 current-fork IDs / 65
future-disabled IDs**. Declarations, Language, and full-prefix verification
are complete at 3/3, 152/152, and 586/586 with zero warnings or failures.

## Latest review — Declarations malformed-form rejection and recovery (2026-07-25)

The new declaration owner closes the previously open failure/recovery hole. Its
six malformed forms are not generic parser smoke tests: they are paired with
three concrete placements and both supported line endings, retain diagnostics,
check publication atomicity, and prove same-name module recovery and execution.
All generated sources are visible in the log, and the owner uses the same raw
SDK lifecycle and formatting contract as the internal tokenizer/parser tests.

The focused owner passes 1/1, the Declarations parent passes 3/3, the Language
parent passes 152/152, and the authoritative SDK prefix passes 586/586. No new
runtime crash or fork limitation was found. The product is classified
`RejectByFork`, while any future 2.38-positive syntax remains a separate
disabled/compatibility decision rather than being silently enabled here.

The follow-up structural review found two older declaration owners with
method-local engine setup. They are now class-owned and lifecycle-managed under
the same `UnitTest.md` contract. The focused Declarations parent and full SDK
regression after that repair remain 3/3 and 586/586, with no semantic-product
count change and no new issue record required.

## Latest review — Compiler/Runtime/Debug/Frontend raw depth checkpoint (2026-07-25)

The next raw SDK source batch is structurally accounted for and has been
verified as executable, not merely catalogued. Compiler owns builder stages and
bytecode mutation/optimization; Runtime owns context scalar access and script
object lifecycle; Runtime.Debug owns instruction callback phases; and Frontend
owns the active tokenizer families and recovery/definition boundaries. The
owners keep source generation visible, use class-owned raw-engine lifecycle
where an engine is required, and do not cross into UE bindings or add-ons.

Parent results are Compiler **110/110**, Runtime **33/33**, and Frontend
**155/155**, with no warnings, failures, not-run, or in-process entries and
normal shutdown. The authoritative **585/585** report contains 29,041 unique
printed source IDs. Runtime's weak-reference/reference-class observations are
explicit current-fork evidence in the log and `fork-limitations.md`, not
silently weakened assertions. The OpenSpec task and verification records now
name every product owner and retain the exact report paths.

## Latest review — exception metadata and call-stack depth (2026-07-25)

`LANG-EX-METADATA-STACK` is now an executable depth owner rather than a
catalog-only promise. Four call shapes crossed with LF, CRLF, and
LF-with-comment source layouts produce 12 stable current-fork cells. The
generated source for every cell is printed before build, and the oracle checks
the exception's text, function, source row/column/section, retained frame
functions/coordinates, context reset, and module cleanup. The value-type method
fixture is intentional: a reference-style local class value currently enters
the fork's null-reference path, so using `struct FMetadataProbe` makes the
method-depth behavior observable without hiding that fork behavior.

The source follows the reviewed `UnitTest.md` contract: one class-owned raw
engine, explicit CQTest lifecycle hooks, non-fatal per-cell assertions, Allman
source generation, one statement per generated line, stable IDs, and no
UE/add-on dependencies. Initial missing-bridge and method-reference failures
are recorded as SDK-DEPTH-101/102; the final LF/CRLF generator correction is
included in the implementation task. Focused, Exceptions, Language, and full
SDK verification are **1/1**, **4/4**, **153/153**, and **587/587** with clean
process metadata and 29,125 printed source IDs.

The final source-state rerun after the LF-layout correction remains green:
Exceptions **4/4**, Language **153/153**, and SDK **587/587**, with the exact
reports retained in `verification.md` and no additional runtime issue.

## Latest review — TypeSystem primitive qualifier semantics (2026-07-25)

The new TypeSystem owner is a genuine direct native-class test rather than a
catalog-only entry. `FDataTypeQualifierCartesianTests` constructs
`asCDataType` values through the vendored API and checks the eleven primitive
token families (including the fork-defined `uint8` and `uint16`) across
mutable, const, reference, and const-reference states. The 44 cells
independently verify token/category predicates, qualifier flags,
canonical `Format`, size/dword/alignment rules, exact and relaxed equality,
instantiation/copyability, handle support, a compiled/executed witness, module
discard, and class-owned engine reset. Every witness is printed before its raw
module build using the reviewed Allman source convention.

The test deliberately takes the integer/unsigned predicates from this fork's
`asCDataType` implementation. This avoids silently applying a newer 2.38
classification to the current 2.33-derived fork. The first compile and oracle
defects are preserved in `issues.md` and do not reduce the 36-cell product.

The initial nine-token pass was **1/1**, TypeSystem **33/33**, and SDK
**588/588**. During source-accountability review, the fork token definition
was checked directly and `uint8`/`uint16` were found to be missing from the
owner. The corrected 44-cell rerun is now green: focused **1/1**, TypeSystem
**33/33**, and SDK **588/588**, with zero warnings/failures/not-run/in-process,
exit code 0, normal shutdown, no crash, and **29,169 unique printed source
IDs**. Catalog validation is **170 products / 44,284 expected IDs / 44,157
current-fork IDs / 65 future-disabled IDs**. The earlier 36-cell result is
retained as discovery evidence, not as the completeness claim. The broader
TypeSystem checklist remains open, so this review closes only the
qualifier/type-helper slice.

The Frontend internal-class review remains valid alongside this batch: direct
owners exist for protected `asCTokenizer` and `asCParser` predicates, while
`asCScriptCode` token-span comparison and `asCScriptNode` tree copy/traversal/
source-range behavior have separate direct owners. Those tests are tracked by
the 69-row method map and are not being replaced by the TypeSystem product.

## Latest review — Functions direction/default depth (2026-07-25)

The new owner closes a concrete interaction omission in the Functions theme:
the existing direction and default-argument owners were individually green,
but did not prove their combined behavior. The implementation is one
class-owned CQTest owner with **528** stable cells (11 primitive types × four
directions × four default/call states × three targets). It is a raw SDK test;
there are no UE wrappers, add-ons, delegate bindings, or DebugServer calls.

The source-generation review confirms that every cell is printed before
compilation and uses the repository's Allman/one-statement-per-line convention.
The native oracle checks exact probe metadata (`TypeId`, normalized flags,
parameter name, and default expression), then resolves the exact entry
declaration and observes read/writeback behavior. Invalid omission cells retain
diagnostics and verify module absence after discard. The engine lifecycle is
class-owned and reset between cells as required by `UnitTest.md`.

The fork-specific oracle is explicit: by-value omitted defaults compile;
`&out`/`&inout` omitted calls reject; `&in` omitted calls compile only for
exactly typed defaults in `int`, `float32`, `float64`, and `bool`. Narrow and
unsigned integer `&in` cells remain negative cases. Explicit `float32` and
`float64` spellings prevent engine-policy resolution of bare `float` from
collapsing the two width categories. This is a characterization of the
current fork, not an assertion that 2.38 semantics are already available.

The implementation review found and repaired four integration errors before
the final focused run: an `FString` format argument needed dereferencing, the
type lookup needed UTF-8 conversion, the SDK invoker required its namespace,
and the boolean invoker fallback takes a boolean rather than `INDEX_NONE`.
The source/oracle review then corrected namespace/member metadata lookup,
explicit float spellings, fork-dependent omission legality, and the accepted
raw build-result convention. A final source-format review found that generated
namespace/struct declarations did not indent their functions to the required
Allman level and that the body helper could leave a tab-only blank line; the
generator now normalizes both cases. All red artifacts and the formatting
finding remain documented in `issues.md`.

Final focused evidence is **1/1** with 528 unique source IDs and zero
whitespace-only generated-source lines at
`Saved/Tests/as-native-sdk-function-direction-default-format-focused-final2/20260725_124936_325_992627d5/Report/index.json`;
the Functions parent is **18/18** with 1,153 unique source IDs at
`Saved/Tests/as-native-sdk-function-direction-default-format-parent-final/20260725_125022_183_c91d06ba/Report/index.json`;
and the authoritative SDK prefix is **589/589**, `succeededWithWarnings=0`,
zero failed/not-run/in-process, `ExitCode=0`, `ProcessExitCode=0`,
`TimedOut=false`, normal shutdown, no crash, and **29,697 unique printed
source IDs** at
`Saved/Tests/as-native-sdk-full-after-function-direction-default-format-final/20260725_125108_671_aa23b300/Report/index.json`.
The static catalog and reconciliation updates are recorded separately in
`verification.md`; this slice is fully recorded, while the broader OpenSpec
language/runtime checklist remains open.

## Latest review — NativeDebug line-callback source paths (2026-07-25)

The new owner closes a concrete NativeDebug depth gap: the existing callback
lifecycle test proved installation, replacement, and clear behavior across
many paths, but did not require the callback to identify the selected source
line or exclude an untaken branch/body. `FNativeLineCallbackSourceTests` owns
40 cells (LF/CRLF × five source paths × four callback states) and uses one
unique module/context per cell.

The generated source contains executable marker statements rather than
comments-only labels. Active recorder cells require the selected marker line,
reject the untaken branch or zero-iteration body marker, and validate positive
line/column, exact source section, and exact `int LineProbe()` declaration.
Absent, replaced, and cleared states verify recorder routing and zero events.
The owner explicitly disables optimization and retains line cues, prints every
source before compilation, uses the class-owned raw engine lifecycle, and
clears user data/callbacks before module discard.

Final focused evidence is **1/1** with 40 unique source IDs;
Runtime.Debug is **7/7** with 50 source IDs; and the authoritative SDK prefix
is **590/590**, zero warnings/failures/not-run/in-process, exit code 0,
`TimedOut=false`, normal shutdown, no crash, and 29,737 unique printed source
IDs. The source-path owner strengthens raw debug evidence without adding UE
DebugServer, DAP, or add-on scope.

## Latest review — NativeDebug stack-pop exit/depth (2026-07-25)

`FNativeStackPopCallbackDepthTests` closes the next concrete debug gap: the
older callback lifecycle owner proved one nested pop, but did not combine call
depth, exit behavior, callback clearing, and same-context recovery. The new
owner keeps all 24 cells (three depths × four exits × two states), prints each
generated source, and uses exact function lookup plus runtime/exception
assertions before inspecting debug events.

The pointer contract is deliberately safe. The test requires only non-null,
non-equal old-frame pointer endpoints and never dereferences or orders them.
Callback clear is checked as zero events, and exception paths unprepare before
recovery on the same context. During focused execution the fork showed one
pop for nested exception unwinding and one top-level pop in the post-reset
recovery phase; both are now explicit exit/depth expectations and are recorded
as characterization, not hidden by a low global threshold.

The final focused owner is **1/1**, Runtime.Debug is **8/8**, and the
authoritative SDK prefix is **591/591**, with zero warnings/failures/not-run/
in-process entries, normal shutdown, no crash, and 29,765 unique printed source
IDs. This is a NativeDebug core slice only; it does not claim closure of the
remaining Language, Compiler, Runtime, Module, TypeSystem, Embedding, or
Conformance products.

## Latest review — ControlFlow loop condition/transfer depth (2026-07-25)

`FLoopConditionTransferDepthTests` closes a specific gap in the existing loop
owner: loop form and transfer behavior were covered, but condition-expression
shape and condition evaluation count were not independently crossed. The new
owner retains the full 180-cell product (three loop forms × five condition
shapes × three counts × four transfer forms), prints every generated Allman
source before compilation, and runs each cell through an exact `int Entry()`
lookup, context reuse check, recovery-safe unprepare, and module discard.

The body count and condition-call count have separate oracles. Only the
side-effect condition uses the native callback counter; variable, comparison,
logical, and negated conditions remain independent language expressions. The
generated `for` variable form updates its condition state inside the body, and
the do-while zero-count form has an explicit preguard, so no cell can become an
unbounded loop merely because it is generated. Break, continue, and return are
kept as distinct source forms; return cells encode early transfer separately
from ordinary loop result values.

The focused owner is **1/1** for all 180 cells; ControlFlow is **10/10**;
Language is **155/155**; and the accepted authoritative SDK rerun is
**592/592**, with zero warnings/failures/not-run/in-process entries, normal
shutdown, no crash, and 29,941 unique printed source IDs. The first aggregate
attempt's unrelated References source-identity failure was reproduced as an
isolated 1/1 pass and retained as order/state-sensitive evidence. This slice
does not add UE bindings, external add-ons, or a claim that all remaining
control-flow families are complete.

## Latest review — ControlFlow branch condition depth (2026-07-25)

`FBranchConditionDepthTests` closes the multi-branch condition gap without
reusing the original single-`if` smoke path. It owns 90 cells across three
branch forms (`if`, `if/else`, and `else-if` chain), five condition shapes,
three selector states, and both LF/CRLF source layouts. Every generated source
is printed before compile, uses Allman braces, and has distinct branch markers
so selection errors cannot be hidden by a common return value.

The selector axis is meaningful: the first selection enters the first arm,
the second enters the second arm where that arm exists, and the no-match
selection reaches the final else arm in the chain. Side-effect conditions use
an independent native callback counter. The owner asserts that an else-if
first selection evaluates one condition while second/no-match selections
evaluate two, and that non-side-effect forms do not accidentally share that
counter. Exact entry lookup, context unprepare, module discard, and per-cell
state reset remain hard assertions.

The first focused run exposed the current fork's requirement for explicit
`ASAutoCaller` payloads on non-generic callbacks; the active source now uses
caller-backed registration and retains all 90 cells. Final focused is **1/1**,
ControlFlow is **11/11**, Language is **156/156**, and the authoritative SDK
prefix is **593/593**, with zero warnings/failures/not-run/in-process entries,
normal shutdown, no crash, and 30,031 unique printed source IDs. This remains
raw AngelScript control-flow coverage, not UE or add-on integration.

## Latest review — ControlFlow live-local cleanup depth (2026-07-25)

The new owner is a substantive lifetime test, not a larger loop-count smoke
test. Its four scope shapes, five exits, three depths, two local counts, and
two line endings produce 240 source cells. Each source is printed before raw
compilation and has distinct local construction/destruction IDs. The native
recorder checks exact counts, identity, reverse destruction order, zero live
objects, and no duplicate or unrelated events. The execution oracle separately
checks normal transfer, early return, exception cleanup, same-context recovery,
and module publication/discard.

The implementation follows `Documents/UnitTest/UnitTest.md`: class-owned static
engine/context lifecycle, per-cell reset, explicit entry lookup, CQTest
assertions with `FNoDiscardAsserter` in static helpers, Allman-formatted
generated AngelScript, source output before compilation, and cleanup after each
cell. It uses only raw AngelScript SDK APIs and the native recorder bridge; no
UE properties, actors, bindings, external add-ons, or debugger APIs are in the
product.

The review retained six discovery observations in `issues.md`: namespace
qualification, static matcher/nodiscard usage, current-fork value-type
constructor semantics, one-time bridge registration, unreachable transfer
markers, and early-return trace accounting. After those repairs the focused
owner is **1/1**, ControlFlow is **12/12**, Language is **157/157**, and the
authoritative SDK prefix is **594/594**. All have zero warnings/failures/not-run/
in-process entries, normal shutdown, and no crash. The static catalog now has
176 products and 45,386 expected IDs; source reconciliation has 0 incomplete
products.

## Latest review — Engine property profile depth (2026-07-25)

`FEnginePropertyProfileTests` is a substantive profile/isolation owner rather
than a second property smoke test. It crosses the bare SDK and
fork-configured engine profiles with all sixteen properties touched by
`CreateNativeEngine` and both applied values, producing 64 current-fork cells.
Each profile has an independent control engine, and each cell captures its own
baseline instead of assuming that the two profiles share defaults. Set/get
return codes, exact generated function metadata, runtime execution, property
restoration, context unprepare, and module discard are all asserted.

The source follows `Documents/UnitTest/UnitTest.md`: class-owned static raw
engine lifecycle, explicit `BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL`, per-cell
reset, CQTest matcher assertions, exact declaration lookup, Allman-formatted
generated AngelScript, and source printing before compilation. It is confined
to core SDK engine behavior and intentionally contains no UE binding or
external add-on coverage.

The review retains the C7595 formatter correction and the independent-default
design constraint as SDK-DEPTH-122/123. After repair, the focused owner is
**1/1**, Engine is **24/24**, and the authoritative SDK prefix is **595/595**,
all with zero warnings/failures/not-run/in-process entries, normal shutdown,
and no crash. The static catalog is now 177 products and 45,450 expected IDs;
reconciliation is 176 implemented plus one DisabledImplemented product with
zero incomplete products, API/boundary audits are clean, and the current
inline-formatting audit is 213/213 conforming. The earlier Engine-profile
checkpoint retained its 215-row scan; the refreshed combined batch is the
authoritative current-state audit.

## Latest review — Combined raw depth and engine-default repair (2026-07-25)

The Compiler, Frontend, Runtime, and Runtime.Debug owners were verified as a
single source batch after all code was present. The isolated parent results are
Compiler **110/110**, Frontend **155/155**, and Runtime **35/35**. These are
raw SDK tests with printed generated sources and no UE bindings, actors,
external add-ons, or debugger integration.

The first authoritative full-prefix run was intentionally not accepted: it
reported one failure in the new Engine profile owner while all other owners
passed. Investigation found that the vendored `asCScriptEngine` constructor
never initialized `ep.typeCheckSwitchEnums`. This made a supposedly bare SDK
default depend on allocator reuse and allowed a focused fresh-process pass to
hide the defect. The repair adds the explicit `false` initialization and keeps
the exact profile restoration assertion intact.

The final focused profile rerun is **1/1**, and the accepted SDK prefix is
**595/595** with one established warning, zero failures/not-run/in-process,
normal shutdown, no crash, and 30,335 unique source IDs. The red aggregate and
runtime root cause are recorded as `FULL-SDK-089` and `SDK-DEPTH-124`; this is
evidence of a fixed core SDK initialization defect, not a weakened test oracle.

## Latest review — Foreach transfer/lifetime and structural mutation depth (2026-07-25)

The new Foreach owner is a substantive semantic/lifecycle slice, not a second
size-only smoke test. It adds 84 transfer/lifetime cells and 36 structural
mutation cells. Transfer coverage crosses seven exit forms, four nesting
shapes, and primitive/value-object copy/value-object const-reference binding;
mutation coverage crosses three initial sizes, four live-count changes, and
the same three binding forms. The native recorder checks iterator begin/value/
next counts, current-fork transfer boundaries, tracked value copies and
destructions, exception text, module discard, and zero live objects. Every
generated source is printed in full before compilation.

The source was reviewed against `Documents/UnitTest/UnitTest.md` and the raw
SDK rules: class-owned `FNativeTestEngine`, explicit `BEFORE_ALL`/
`BEFORE_EACH`/`AFTER_ALL`, exact function lookup, `FNoDiscardAsserter`-based
assertion helpers, Allman-formatted generated AngelScript, per-cell reset, and
context/module cleanup. It contains no UE world/object, plugin engine wrapper,
external add-on, or debugger integration dependency. Shared native declarations
are registered once per engine; only the recorder user-data pointer changes per
method, which prevents duplicate registration without allowing stale state to
cross cells.

The first focused run exposed duplicate registration, then the diagnostic runs
exposed the fork's one-value/no-next return and exception path, the middle-break
single `opForNext`, and the distinct nested range limits. These were repaired in
the generator/oracle and recorded as SDK-DEPTH-125 through SDK-DEPTH-129; no
cell was disabled or deleted. Final focused is **2/2** for all 120 cells,
Foreach is **4/4**, Language is **159/159**, and the authoritative SDK prefix
is **597/597** with zero failures/not-run/in-process entries, normal shutdown,
and no crash. Static catalog/source reconciliation, API, boundary, inline
formatting, strict OpenSpec, forbidden-term, and diff audits are all clean.

## Latest review — Runtime.Debug nested-context depth (2026-07-26)

The new `DBG-NEST-STATE-DEPTH` owner is a focused raw SDK behavior test, not a
single-depth smoke check. It covers four saved-state depths, two exact function
signature paths, and four terminal actions, yielding 32 current-fork cells.
Every cell emits and prints four complete AngelScript functions before compile;
the native assertions cover exact declarations, state transitions, saved-state
counts, caller restoration, exception consumption, fork-specific suspend/abort
results, context cleanup, module discard, and zero remaining nested state.

The source was reviewed against `Documents/UnitTest/UnitTest.md` and the raw SDK
rules: class-owned `FNativeTestEngine`, explicit `BEFORE_ALL`/
`BEFORE_EACH`/`AFTER_ALL`, explicit `FNoDiscardAsserter` result consumption,
exact declaration lookup, per-cell message reset, source logging, Allman
AngelScript formatting, and context/module cleanup. It contains no UE object or
world dependency, plugin-engine wrapper, external add-on, or debugger
integration. Recorder state is held in a context user-data slot and is replaced
per cell; the native declaration is registered once per raw engine.

Review of the diagnostic history found three test defects and one invocation
issue: a duplicate generated native declaration, ignored nodiscard matcher
results, an outer `TArray` element reference surviving recursive growth, and a
relative project-root audit invocation. All are recorded as SDK-DEPTH-130
through SDK-DEPTH-133 and AUDIT-INVOCATION-001; the first three were repaired
without weakening or deleting any cell, and the audit was rerun with the
required absolute root. The final focused owner is **1/1**, Runtime.Debug is
**9/9**, Runtime is **36/36**, and the final authoritative SDK prefix is
**598/598** with zero warnings/failures/not-run/in-process entries, normal
shutdown, no fatal markers, and 30,487 unique source IDs. Catalog, source
reconciliation, API, boundary, inline formatting, strict OpenSpec, forbidden
term, and diff audits all pass.
