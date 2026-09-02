# Runtime default-argument ownership and projection audit — 2026-08-30

## Outcome

### CTA-S94 — unreferenced qualified Runtime default type closure

The final missing qualified-default case is now closed. A Runtime default may
be the only place that introduces both a type spelling and a namespaced native
global property, for example `FLinearColor::LucBlue` when the authored caller
signature otherwise never mentions `FLinearColor`. The original focused RED
was:

```text
Saved/Tests/cta-s94-runtime-default-qualified-type-red/
  20260830_173218_444_d9f554eb/Report/index.json
```

It failed first with `unresolved-scope:FLinearColor` and, depending on the
partial projection reached, `unresolved-identifier:LucBlue`. `LucBlue` is not
an instance field or enum constant: `Bind_FLinearColor.cpp` registers it as an
Engine global property in the exact Runtime namespace `FLinearColor`.

The repair keeps one semantic authority and adds no numeric Runtime TypeId to
the AST:

- Canonical Sema resolves the structured scope path with the same lexical
  namespace rules as Builder, matches the exact registered-global namespace
  pointer plus property name, and interns one pointer-free `VarDecl` beneath
  the actual Canonical namespace;
- the property type is projected through `asCRuntimeTypeBridge`, so dynamic
  Engine-local TypeId numbers are not persisted or used as stable identity;
- Bytecode CodeGen resolves the Canonical declaration namespace and binds the
  exact registered property by namespace, name and compatible exact type,
  instead of accepting the first Engine-wide name/type match;
- a representation-preserving Canonical conversion around the POD default is
  transparent to lvalue-address emission only when it has no selected
  conversion declaration and source/destination are equal except ref/const.
  Real `opImplConv` calls remain explicit and are not bypassed.

The first projection build passed at
`Saved/Build/cta-s94-qualified-native-global-projection-build/20260830_182621_729_a2d5b0ff/Build.log`.
That moved the focused test past name resolution and exposed the adjacent
identity-conversion address RED at
`Saved/Tests/cta-s94-qualified-native-global-projection-focused/20260830_182707_813_40185d1a/Report/index.json`.
The final build passed at
`Saved/Build/cta-s94-identity-conversion-address-build/20260830_182917_469_891a233a/Build.log`,
and the exact qualified-default execution is **1/1 PASS** at
`Saved/Tests/cta-s94-identity-conversion-address-focused/20260830_182931_349_790f5825/Report/index.json`.

This closes exact Runtime namespace/property projection and POD identity-copy
lowering for this default. It does not claim that every remaining expression
or statement family is lowered, or that the complete final cutover matrix has
passed.

Follow-up implementation status: the central ownership/projection repair and
the registered-native factory named/default construction path are now green.
Canonical Sema keeps ordinary function lookup first, recognizes an exact
nominal type-name call only when appropriate, interns that type's Runtime
factory/constructor declarations without renaming their `$behN` Runtime
identity, and selects the exact constructor through the same named/default
call plan used by ordinary calls. The selected constructor is then carried
directly into construction so a later positional-only selector cannot replace
it.

The expanded CallArguments matrix is now **10/10 PASS**. The exact factory
fixture `CNativeDefaultFactory(B: 7)` proves that source argument `B` maps to
formal ordinal 1 while formal ordinal 0 receives the registered typed default
`40 + 2`; execution returns `427`. The scoped-enum, floating and null-handle
cases remain classified as corrected fixture contracts (`GetArgByte`,
`asEP_FLOAT_IS_FLOAT64=1`, and retained implicit-handle `nullptr` syntax), not
product defects.

## Final focused closure evidence

The build after correcting only the fixture contracts passed at
`Saved/Build/cta-s91-default-breadth-fixture-contract-build/20260830_140717_391_3a74aa82`.
The complete expanded CallArguments class first ran at
`Saved/Tests/cta-s91-default-breadth-fixture-contract/20260830_140734_943_a89b03c7`
with **9 passed, 1 failed**. The exact RED was independently reproduced at
`Saved/Tests/cta-s91-factory-call-plan-red-20260830/20260830_142243_547_53c717da`
with:

```text
unresolved-callee:CNativeDefaultFactory nargs=1 hits=0 arg0=int
```

The implementation and current GREEN evidence are:

- factory call-plan build: PASS at
  `Saved/Build/cta-s91-factory-call-plan-green-build-20260830/20260830_142746_664_3ab47376`;
- exact factory RED -> GREEN: **1/1 PASS** at
  `Saved/Tests/cta-s91-factory-call-plan-green-20260830/20260830_142819_115_a92a3677`;
- complete CallArguments: **10/10 PASS** at
  `Saved/Tests/cta-s91-callarguments-green-20260830/20260830_142854_282_e1dab20a`;
- complete ProductionCodeGen after the adjacent native-tree repair:
  **167/167 PASS** at
  `Saved/Tests/cta-s91-production-codegen-regreen-20260830/20260830_143242_201_5a1e48d4`;
- CodeGen transaction/rollback: **21/21 PASS** at
  `Saved/Tests/cta-s91-codegen-transaction-adjacency-20260830/20260830_143333_454_1cf4f3ec`.

The now-green cases prove:

- direct Runtime shells own authored defaults;
- named/default and hidden-middle call plans execute from sealed formal facts;
- registered native globals project integer and typed expression defaults;
- registered native methods project and execute a named/default call;
- the double-backed floating default executes under
  `asEP_FLOAT_IS_FLOAT64=1`;
- scoped enum explicit/default calls execute when the byte-sized generic ABI is
  observed correctly;
- the retained implicit-handle `nullptr` default executes.

The factory RED root cause was a missing type-name construction candidate, not
missing Runtime metadata after projection. Runtime behaviours are
intentionally named `$behN`, while authored source calls the object type. The
repair therefore leaves `$behN` untouched, resolves the complete nominal type,
materializes its constructor set, and ranks that set without a source-name
filter through `TryBuildCallArgumentPlan`. Rejected alternatives were renaming
the Runtime behaviour, selecting by numeric Runtime ID, or inserting defaults
in CodeGen; each would either break Runtime identity/template-factory
disambiguation or create a second semantic authority.

The first broad ProductionCodeGen rerun then exposed a second deterministic
RED: `PreparedImportBindsExactShellAndExecutes` crashed in
`asCBuilder::GetParsedFunctionDetails()` because the CANONICAL parameter parser
had replaced the original default-argument `snExpression` wrapper with a raw
`snAssignment`. Builder still consumes the native Parser AST for Stage-2
Runtime registration and expects the established
`TYPE / TYPEMOD / NAME / snExpression` sequence. The minimal repair restores
that transparent `snExpression` wrapper and retains the complete parsed
assignment beneath it. This preserves both authorities: Sema receives the full
typed expression, while the original AS AST remains valid for
syntax/LEGACY/reference/registration use. Isolated evidence went from a stable
access violation at `as_builder.cpp:6738` to **1/1 PASS** at
`Saved/Tests/cta-s91-prepared-import-native-tree-green-20260830/20260830_143210_632_7bf513ac`.

The adjacent constructor-provenance obligation is now closed by CTA-S92.
Ordinary `asAST_EXPR_CONSTRUCT` publishes, verifies, persists through Sidecar
V11 and executes from the same complete `asSASTCallArgument` source-to-formal
relation as `asAST_EXPR_CALL`, while list-pattern aggregates retain their
separate protocol. The focused named/default producer and verifier gates, the
same-typed adversarial Bytecode consumer, ProductionCodeGen **168/168** and
ASTBodySidecar **25/25** are green. Full evidence is in
`attachments/cta-s92-construct-call-argument-provenance-gate-2026-08-30.md`.

### CTA-S92 current-module authority follow-up

The first full Cache V11 run exposed one additional production ownership gap:
the global/default compile route projected Runtime defaults without installing
the same `CurrentModuleAuthority` scope already used by module-local
projection. The exact persistence-layer regression failed **0/1** at:

```text
Saved/Tests/cta-s92-global-default-persistence-layer-red-20260830/
  20260830_155842_639_22f9fa54/Report/index.json
```

The repair establishes the authority around the global route before typed
default projection. It does not add a second parser, replay the native syntax
tree in CodeGen or move default insertion into the backend. The exact gate is
now **1/1 PASS**:

```text
Saved/Tests/cta-s92-global-default-authority-green-20260830/
  20260830_160034_794_d98afd03/Report/index.json
```

The final complete Cache regression is **585/585 PASS** at
`Saved/Tests/cta-s92-cache-v11-super-full-green-20260830/20260830_161926_505_ec756f82/Report/index.json`.

The older post-crash enum, float, null and factory sections below are retained
as investigation history. Where they describe those observations as open
product gaps, this latest section is authoritative and supersedes them.

This read-only audit confirms that default arguments are not merely display
metadata. `asCScriptFunction::defaultArgs` is an owning Runtime contract used
by public reflection, Cache capture, Hot Reload signature comparison and
Runtime-to-Canonical call projection.

The current implementation is correct for prepared Stage-2 authored
functions/imports and for synthesized formals that genuinely have no default.
It is incomplete in two independent production layers:

1. detached/direct Runtime shell materialization writes null instead of
   owning the Canonical default expression;
2. current-module, automatic-import and registered-native Runtime-to-Canonical
   projections do not recreate typed default expressions.

The second defect can make a named call with one omitted defaulted formal fail
to compile; it is not limited to `GetDeclaration()` presentation.

## Ownership contract

Canonical declaration Sema owns both the default-expression spelling and the
typed initializer. Runtime `asCScriptFunction` separately owns a parallel
`defaultArgs` array of heap-allocated `asCString*` values and deletes every
non-null entry during destruction.

The maintained Builder contract is:

```text
formal has authored default
  -> allocate independent asCString
  -> transfer ownership to Runtime function/import shell

formal has no authored default
  -> store nullptr as the same-formal-ordinal placeholder
```

Borrowing an AST string pointer would violate lifetime ownership, while
writing null for a non-empty Canonical default loses observable structure.

## Correct routes

### Prepared Stage-2 authored functions

Builder parses and allocates default strings, `AddScriptFunction` transfers
them to the exact Runtime shell, and prepared Canonical CodeGen binds that
existing shell rather than replacing it. This path preserves defaults.

### Prepared explicit imports

Builder likewise parses defaults and transfers them through
`AddImportedFunction`. Prepared CodeGen reuses the exact Stage-2 import shell.

### Synthesized no-default formals

Null remains correct for lambda capture formals, generated accessor formals
and any authored formal with no default expression. Null is a parallel-array
placeholder in those cases, not an ownership mechanism for non-empty data.

## Confirmed detached shell defects

### Direct/detached authored function

Public Canonical `asIScriptModule::Build()` may materialize a new Runtime
function directly. `FillFunctionSignature` copies formal type, name and
passing but currently pushes null into `defaultArgs` unconditionally.

Observable consequences:

- `GetParam(..., &defaultArg)` returns null;
- `GetDeclaration(includeDefaultValues=true)` omits `= ...`;
- Cache captures absence rather than the authored expression;
- default-only signature changes can be invisible if such a shell reaches a
  Hot Reload comparison;
- a generated constructor factory can only copy the already-missing default.

### Detached explicit import

The detached import loop also pushes null for every formal before transferring
the array to `CreateCanonicalPendingImport`. That callee already has the
correct ownership cleanup/transfer behavior; the caller simply never
allocates a copy for a non-empty Canonical default.

### Canonical CompileFunction shell

`CompileFunction` uses detached `GenerateFunction`/`GenerateInternal`, so a
new function such as `int F(int V = 7)` publishes a Runtime shell whose first
`GetParam` default is null.

## Confirmed Runtime-to-Canonical projection defects

The following projections create `ParamDecl` type/name data but do not
reconstruct default ownership and typed initializer state:

- current-module script functions used by `CompileFunction`;
- automatic-import script functions;
- registered native global functions;
- registered native methods;
- registered native constructors/factories.

A representative reachable failure is:

```angelscript
int Pack(int A = 1, int B = 2)
{
    return A * 10 + B;
}

int G()
{
    return Pack(B: 7);
}
```

The projected name allows `B` to bind, but missing typed/default data for `A`
makes the candidate non-viable. The same shape applies to an automatic import
or registered native `Pack` declaration.

## Why copying only text is insufficient

The call planner first consumes a typed default initializer. If that is
missing, the current text fallback is effectively integer-oriented and cannot
correctly represent the full language family:

```angelscript
float Scale = 1.5
string Label = "Default"
EMode Mode = EMode::Fast
UObject@ Object = null
int Count = Namespace::BaseCount + 1
```

Therefore `SetDefaultArg(runtimeText)` alone may make a candidate appear
viable while materializing the wrong value. A complete product fix must parse
and type-check the default in the callee declaration namespace and attach the
resulting typed expression to the projected formal.

## Cache and Hot Reload classification

Cache capture and restore correctly read, persist, hash, allocate and compare
Runtime default strings. They are observers of the Runtime shell and cannot
repair an upstream null. If detached materialization loses the default, Cache
faithfully records the wrong absence.

Runtime Hot Reload signature comparison also correctly compares default-array
length, null presence and text. Main UE prepared Hot Reload currently receives
correct Stage-2 shells, so this audit does not claim all normal Hot Reload is
broken. It records that a detached null shell cannot express a default-only
change if it reaches that comparison boundary.

## Required implementation slices

### Slice A: Runtime shell invariant

Introduce one ownership helper that creates an independent `asCString` for a
non-empty Canonical `ParamDecl.defaultArg`, otherwise returns null. Use it in:

- `FillFunctionSignature`;
- detached explicit import materialization.

The detached import caller must use RAII or explicit cleanup for strings
allocated before a later formal fails; `CreateCanonicalPendingImport` can only
clean the complete array after ownership reaches it.

Prepared shells should be authenticated against the Canonical presence/text
but not overwritten, because Builder already owns the correct transfer.

### Slice B: typed Runtime-to-Canonical projection

Centralize projection of:

- name;
- source/direct ABI type, according to script versus native origin;
- exact formal ordinal;
- default text presence;
- declaration namespace/source context;
- typed default expression;
- hidden-argument special metadata.

Use it for current-module, automatic import and all registered-native
function families. Unsupported default syntax must fail with a precise
diagnostic; it must not silently fall into numeric conversion.

## Required TDD matrix

1. Direct function Runtime reflection preserves `"1"` and `"2"` while the
   existing named/default execution still returns 17.
2. `CompileFunction` can call an existing `Pack(B: 7)` and publishes its own
   `= 7` Runtime metadata when added to the module.
3. Automatic-import `Pack(B: 7)` executes and returns 17.
4. Detached explicit import preserves default strings.
5. Prepared explicit import remains an ownership non-regression.
6. Cache capture/restore preserves a defaulted function's Runtime metadata.
7. Registered native global/method/constructor/factory omitted-default calls
   execute through the selected target.
8. String, float, enum/namespace constant, null/handle and expression defaults
   prove typed projection rather than integer-text fallback.

## Follow-up implementation closure

The implementation now establishes two separate, explicit boundaries.

### Owning Runtime shell defaults

`FillFunctionSignature` deep-copies every non-empty Canonical formal default
into the owning `asCScriptFunction::defaultArgs` array. Detached explicit
imports use the same clone operation plus a local RAII owner, so partial type
or allocation failure cannot leak already-created strings before ownership is
transferred to `CreateCanonicalPendingImport`.

The explicit-import materializer also normalizes its live parameter
datatype/passing pair through the maintained script-shell ABI. Exact authored
qualifiers remain in `canonicalASTSourceParameterQualifiers`; import binding
therefore compares the same Runtime ABI as the provider Builder path without
weakening source identity.

### Typed Runtime-to-Canonical defaults

Runtime projections now use one `ProjectRuntimeDefaultArgument` path for:

- current-module functions used by `CompileFunction`;
- automatic-imported script functions;
- registered native globals;
- registered native methods;
- registered native constructors/factories.

The helper creates a generated, stable source section keyed by callable
identity and formal ordinal, reuses the existing Canonical Parser/Sema to
parse and type-check the expression, attaches the exact typed expression to
the projected `ParamDecl`, and then restores the surrounding authored parse
state. The call planner now requires that typed initializer; the old default-
text numeric materialization fallback has been removed.

This is important for expressions such as `40 + 2`: the call evaluates the
typed expression to 42 rather than accepting `strtoull("40 + 2") == 40`.

## RED/GREEN evidence

The initial semantic RED matrix is valid evidence:

- build:
  `Saved/Build/cta-s91-runtime-defaults-valid-red-build/20260830_130656_127_a9184898`;
- tests:
  `Saved/Tests/cta-s91-runtime-defaults-semantic-red/20260830_130728_564_e42f80df`;
- result: **0/6 PASS**, covering direct shell metadata, explicit import
  metadata, `CompileFunction` shell/projection, automatic import and
  registered-native projection.

The typed-expression RED is:

- build:
  `Saved/Build/cta-s91-runtime-defaults-expression-red-build/20260830_131148_368_e4f2630e`;
- tests:
  `Saved/Tests/cta-s91-runtime-defaults-expression-valid-red/20260830_131238_223_a943c14c`;
- result: **2/5 PASS, 3/5 FAIL**, including the `40 + 2` registered-native
  default.

The first GREEN matrix after central projection was:

- build:
  `Saved/Build/cta-s91-runtime-defaults-first-green-build/20260830_131732_314_04c2b603`;
- CallArguments: **5/5 PASS** at
  `Saved/Tests/cta-s91-runtime-defaults-callarguments-first-green/20260830_131825_462_10d6a9a1`;
- Cutover: **15/15 PASS** at
  `Saved/Tests/cta-s91-runtime-defaults-cutover-first-green/20260830_131906_819_9c04a125`.

The first broad ProductionCodeGen run was **161/162 PASS** at
`Saved/Tests/cta-s91-runtime-defaults-productioncodegen-first-green/20260830_131937_995_f07e80d6`.
Its sole failure proved that detached explicit imports had retained raw
primitive `int` while the provider used the maintained `const int` script-
shell ABI. `BindImportedFunction` does not compare default metadata. A focused
diagnostic run captured the exact mismatch at
`Saved/Tests/cta-s91-runtime-defaults-import-diagnostic/20260830_132259_304_4676c2df`.

After normalizing only the live import ABI while preserving exact source
qualifiers:

- final build: PASS at
  `Saved/Build/cta-s91-runtime-defaults-import-abi-green-build/20260830_132409_876_5a203830`;
- focused explicit import: **1/1 PASS** at
  `Saved/Tests/cta-s91-runtime-defaults-import-abi-green/20260830_132426_000_9fda77d6`;
- complete ProductionCodeGen: **162/162 PASS** with zero failures/skips at
  `Saved/Tests/cta-s91-runtime-defaults-productioncodegen-green/20260830_132459_281_dc883216`.

## Breadth hardening discovery: engine-only expression Parser crash

The next CTA-S91 breadth batch added registered-native method,
constructor/factory, float, scoped-enum and null-handle defaults, plus prepared
import and Cache round-trip coverage. The build passed at
`Saved/Build/cta-s91-default-breadth-red-build/20260830_133010_137_55cf32bb`.
The grouped CallArguments run at
`Saved/Tests/cta-s91-default-breadth-red/20260830_133028_346_89bbbb4c`
is intentionally retained as incomplete RED evidence because the scoped-enum
case crashed the test process before the ten-test matrix could finish.

The crash is deterministic for the generated Runtime default expression
`ENativeDefaultMode::Fast`. `ActOnProjectedRuntimeDefaultArgument` constructs
`asCParser(engine)`, whose `builder` member is null. Public
`ParseExpression(asCScriptCode*)` then sets `checkValidTypes = true`; the first
identifier in the scoped enum reaches `IsDataType`, which calls
`builder->DoesTypeExist(...)` without a null guard. Integer literals and the
earlier `40 + 2` expression do not enter that type-disambiguation branch,
which explains why the central projection matrix passed before the breadth
case exposed this lifecycle mismatch. The captured stack terminates at
`asCBuilder::DoesTypeExist`, `asCParser::ParseExprTerm`, and
`asCSema::ActOnProjectedRuntimeDefaultArgument`; its snapshot is
`Saved/Angelscript/CrashSnapshots/9504_20260830_133055_988/AngelscriptCrashSnapshot.json`.

This finding is a Parser context-contract defect in the new Runtime-default
projection route, not evidence that Canonical enum expressions are generally
unsupported. The repair keeps normal Parser construction Builder-backed and
adds a narrow `DoesTypeExist` boundary for engine-only expression parsing. In
that mode Parser asks Sema's pointer-free copied declaration/runtime type facts
whether the token is type-shaped; it neither constructs a second Builder nor
silently disables `checkValidTypes`.

The repair build passed at
`Saved/Build/cta-s91-scoped-enum-parser-green-build/20260830_133727_093_4559f861`.
The focused rerun at
`Saved/Tests/cta-s91-scoped-enum-parser-green/20260830_133820_292_6419a99f`
completed without a crash, proving the Parser lifecycle root cause and repair,
but remained **0/1 FAIL** because the function returned `0` instead of `47`.

## Post-crash diagnostic: native enum call is default-independent

The enum test was then split into an explicit-argument baseline and the omitted
default call, with a native callback observation recording whether the callback
ran and the received `Mode`/`B` values. The diagnostic build passed at
`Saved/Build/cta-s91-enum-default-layer-diagnostic-build/20260830_133958_807_5581c3f4`.
The focused run at
`Saved/Tests/cta-s91-enum-default-layer-diagnostic/20260830_134014_739_fbca9241`
completed without a process crash but failed the explicit baseline itself:

- returned value: `0` instead of `47`;
- callback-called observation: `false`;
- observed enum value: `0` instead of `4`;
- observed integer argument: `0` instead of `7`.

Because `NativeEnumDefault(ENativeDefaultMode::Fast, 7)` does not use a default
argument, this evidence separates the remaining enum failure from Runtime-
default parsing/projection. The confirmed open product gap is now the broader
CANONICAL registered-native global enum-call execution chain: resolution,
Runtime target binding, `CALLSYS` emission/relocation or the system-call ABI
route can still suppress the call. The exact layer is not yet proven, so no
speculative production patch has been applied.

### Follow-up layer isolation: exact target is published, failure is below relocation

Three subsequent focused diagnostics narrow that open gap without changing
production behavior:

- `Saved/Tests/cta-s91-enum-call-target-diagnostic/20260830_134743_672_11673d8e`
  decodes the final call operand as function ID `12`, equal to the registered
  native function ID. The resolved target is `asFUNC_SYSTEM`, the opcode is
  `CALLSYS`, and there is no same-name script/module projection. This excludes
  a detached ghost function and the reviewed CodeGen target resolver/relocation
  path for this fixture.
- `Saved/Tests/cta-s91-enum-bytecode-trace/20260830_134902_934_cd8e9204`
  records the final instruction order as
  `SUSPEND, SetV1, PshC4, PshV4, CALLSYS, CpyRtoV4, CpyVtoV4, JMP,
  CpyVtoR4, RET`. `CALLSYS` is reachable before the return, so the failure is
  not a misplaced unreachable call instruction.
- `Saved/Tests/cta-s91-enum-vm-dispatch-diagnostic/20260830_135030_053_27af50fc`
  proves the Engine function slot still refers to the exact registered system
  function after module Build. A direct prepared context finishes and invokes
  the native callback, while the in-script `CALLSYS` route still returns zero
  without invoking the callback. The direct invocation returns `7`, not `47`,
  after `SetArgDWord(0, 4)` and `SetArgDWord(1, 7)`, which is additional evidence
  that the compact enum formal's argument width/offset or Generic ABI view is
  not equivalent to an ordinary DWORD formal.

The remaining root-cause search is therefore below Canonical call resolution
and stable-function relocation. It is concentrated on registered compact-enum
parameter layout, `parameterOffsets`/`spaceNeededForArguments`, generic
argument addressing, `CALLSYS` stack state and parameter-pop accounting. No
production patch has been applied because these diagnostics do not yet prove
which one owns the mismatch. One fixture-only diagnostic build failed Unreal's
checked `FString::Printf` format validation before being corrected; it is not
product evidence. The corrected diagnostic builds all pass.

The same interrupted batch also produced two execution-result mismatches for
float and null-handle defaults, which still require isolated diagnostics, and
one native-factory registration failure. The factory failure is currently a
test-fixture/protocol failure and is excluded from product RED evidence until
the registration sequence is valid. These three observations must not be
collapsed into the scoped-enum Parser crash.

### Excluded evidence

- The earlier build that attempted to call a private import API through the
  public interface was a fixture compile error and is not product RED.
- `Saved/Tests/cta-s91-runtime-defaults-expression-red/20260830_131203_375_300fe3ac`
  selected no tests because the CQTest class segment was omitted; it is not
  semantic evidence.
- The first build invoked through the resolved `.worktrees` path was rejected
  by the worktree `AgentConfig.ini` guard before compilation. The valid build
  evidence uses the configured `D:\\as-cta` entry.

## Remaining breadth before product-default cutover

The central code paths are repaired, but this attachment does not yet claim
the entire default-argument language family is cutover-complete. Still
required are focused production fixtures for:

- repair and authenticate registered native constructor/factory lookup so the
  authored type identity reaches the existing named/default call planner;
- string and namespace/global constant defaults;
- Cache round-trip reflection of non-empty default strings;
- prepared explicit-import ownership authentication and failure cleanup;
- negative parse/type diagnostics for an invalid Runtime default expression.

## Non-claims

- No production code was changed by this audit.
- The preceding statement describes the original read-only audit; the
  follow-up implementation closure above records the later production change.
- The normal prepared Stage-2 authored function/import route is not classified
  as broken.
- Null remains correct for genuinely no-default synthesized formals.
- Cache and Hot Reload are not designated as repair layers.
- Product default remains LEGACY until this and the remaining final gates are
  closed.
- Standalone is excluded.
