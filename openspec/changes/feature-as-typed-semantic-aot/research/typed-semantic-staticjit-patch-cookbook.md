# Typed Semantic StaticJIT patch cookbook

> 2026-08-13 naming/integration note: this cookbook preserves historical fixture and probe names such as `SemanticScalarBranch`, but production classes and BackendIds are `FAngelscriptBytecodeJIT`/`"bytecode"` and `FAngelscriptTypedASTJIT`/`"typed-ast"`. There is no production `Dual` backend. Any older `SemanticAOT` path/class skeleton below must be translated to `StaticJIT/TypedASTJIT` and `FAngelscriptTypedASTJIT`; production integration waits for the shared Static backend/generation-view foundation in `refactor-as-unified-jit-coordinator`.

## 1. Purpose and authority

This cookbook turns the first typed-semantic StaticJIT slice into a sequence of
small, independently verifiable patches. It intentionally prioritizes frontend
capture and generated-code behavior over the provider/runtime architecture that
is evolving in parallel.

The normative requirements remain the delta specs in this change. This file is
implementation guidance. If a code skeleton here conflicts with a requirement,
keep the requirement and update the skeleton.

The first completion claim is deliberately narrow but real:

```text
AngelScript source
  -> normal semantic compiler + unchanged bytecode
  -> verified function-owned typed HIR
  -> HIR-only scalar C++ emitter
  -> checked-in AOT test translation unit
  -> compiled native probe
  -> isolated VM == BytecodeJIT == TypedASTJIT native result
```

This slice is not complete when only a JSON fixture, HIR dump, or C++ string
exists. The generated TypedASTJIT function must compile and execute, and a probe
counter must prove that the TypedASTJIT body ran.

## 2. Frozen first-slice behavior

### 2.1 Source fixture

Add this global UFUNCTION to the existing StaticJIT AOT fixture source. The
ClassGenerator exposes it through the existing generated statics-class surface,
but the AngelScript function itself remains directly resolvable from the module:

```angelscript
UFUNCTION()
int SemanticScalarBranch(int A, int B)
{
	int Sum = A + B;
	if (Sum > 10)
		return Sum * 2;

	return Sum - 1;
}
```

The first slice supports exactly the semantics needed by this body:

- by-value `int` parameters and `int` return;
- parameter and local symbols;
- integer literals;
- local initialization;
- `+`, `-`, `*`, and `>`;
- a block, `if`, and `return`;
- deterministic source spans and node IDs.

Do not implement native calls, properties, objects, references, containers,
coroutines, exception cleanup, provider routing, backend CLI parsing, or LLVM in
this slice. If another valid source construct is seen while capture is enabled,
capture an explicit unsupported marker and let normal bytecode compilation
continue.

### 2.2 Differential matrix

Execute all three paths with fresh, equivalent inputs:

| `A` | `B` | expected | path covered |
| ---: | ---: | ---: | --- |
| 3 | 4 | 6 | false branch |
| 6 | 7 | 26 | true branch |
| -5 | 2 | -4 | signed negative input |
| 10 | 0 | 9 | `Sum == 10` boundary |

For every row, compare:

1. an isolated engine that executes the source in the interpreter;
2. the current legacy bytecode StaticJIT AOT fixture path;
3. the generated Semantic test probe called as compiled C++.

The Semantic probe owns a test-only atomic entry counter. Assert that the
counter increases by exactly four. A matching return value with a zero counter
is a failed test, because fallback may have hidden the missing native body.

### 2.3 Functional ordering

Implement this vertical slice before production backend selection and provider
publication:

```text
P1 HIR model/lifetime
  -> P2 compiler capture
  -> P3 pure analyzer/emitter
  -> P4 checked-in probe + execution parity
  -> later: engine config, root indexing, native calls, provider adapter
```

The production provider work may change names and packaging, but it must not
force P1-P3 to depend on provider catalogs, runtime routes, buckets, refresh,
code memory, or hotness state.

## 3. Stable source anchors

Use symbol names rather than line numbers when applying patches. The maintained
fork and tests currently provide these stable anchors:

| Responsibility | Stable anchor |
| --- | --- |
| expression state | `asCExprContext` in `as_compiler.h` |
| capture transaction start | `asCCompiler::Reset()` |
| raw parser lifetime | local `asCParser` in `asCCompiler::CompileFunction()` |
| successful source commit point | call to `FinalizeFunction()` near the end of `CompileFunction()` |
| bytecode publication | `asCCompiler::FinalizeFunction()` |
| function-owned sidecars | `asCScriptFunction::ScriptFunctionData` |
| sidecar allocation | `asCScriptFunction::AllocateScriptFunctionData()` |
| sidecar destruction | `asCScriptFunction::DestroyInternal()` / `DeallocateScriptFunctionData()` |
| fork-private engine settings | `asCScriptEngine::ep` in `as_scriptengine.h` |
| engine-setting defaults | `asCScriptEngine::asCScriptEngine()` |
| Standalone source list | `Standalone/CMakeLists.txt` / `ANGELSCRIPT_MAINTAINED_FORK_SOURCES` |
| native compiler tests | `AngelscriptTest/AngelScriptSDK/Compiler` |
| generated-output tests | `AngelscriptTest/StaticJIT` |
| compiled AOT fixture | `AngelscriptTest/StaticJIT/AOT` |

Before applying any patch, inspect the current definitions of these symbols.
The surrounding provider code is volatile; the compiler anchors are the stable
baseline for the feature core.

## 4. Patch P1 — function-owned typed HIR

### 4.1 Files

Create or modify:

```text
ThirdParty/angelscript/source/as_typed_semantic_ir.h
ThirdParty/angelscript/source/as_typed_semantic_ir.cpp
ThirdParty/angelscript/source/as_scriptfunction.h
ThirdParty/angelscript/source/as_scriptfunction.cpp
Standalone/CMakeLists.txt
Standalone/Tests/AngelscriptTypedSemanticIRTests.cpp
AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeTypedSemanticIRTests.cpp
```

`as_typed_semantic_ir.cpp` is compiled automatically by the Unreal module
source scan, but must be added explicitly to
`ANGELSCRIPT_MAINTAINED_FORK_SOURCES` for Standalone.

### 4.2 Tests first

Start with Native Core and Standalone tests that construct HIR directly. The
first red tests must cover:

- invalid-by-default IDs;
- zero-based contiguous symbol/expression/statement arenas;
- a valid `SemanticScalarBranch` model;
- deterministic dump equality across two separately constructed models;
- `DanglingExpressionId` from the research negative fixture;
- a non-block root;
- statement multiple ownership;
- missing unsupported category;
- destruction of function-owned HIR;
- no public addition to `angelscript.h`.

Use the research corpus under `research/fixtures/semantic-aot-v1/` as an oracle,
not as a Runtime input. The C++ tests construct equivalent in-memory values and
compare the native normalized dump with `expected.hir.txt`.

### 4.3 ID types

Use distinct typed IDs so a symbol ID cannot be passed where an expression ID
is required:

```cpp
template<typename Tag>
struct asTTypedSemanticId
{
	asUINT value = asUINT(-1);

	bool IsValid() const { return value != asUINT(-1); }
	bool operator==(const asTTypedSemanticId& Other) const
	{
		return value == Other.value;
	}
};

struct asSTypedSemanticSymbolTag;
struct asSTypedSemanticExpressionTag;
struct asSTypedSemanticStatementTag;

using asTypedSemanticSymbolId =
	asTTypedSemanticId<asSTypedSemanticSymbolTag>;
using asTypedSemanticExpressionId =
	asTTypedSemanticId<asSTypedSemanticExpressionTag>;
using asTypedSemanticStatementId =
	asTTypedSemanticId<asSTypedSemanticStatementTag>;
```

IDs are function-local arena indexes. Never derive an ID from a pointer,
bytecode offset, source line, or source variable name.

### 4.4 Initial enums and records

The first header should make the eventual expansion explicit without requiring
all nodes to be emitted immediately:

```cpp
enum class asETypedSemanticExpressionKind : asBYTE
{
	Literal,
	Symbol,
	Conversion,
	Assignment,
	Unary,
	Binary,
	ShortCircuit,
	ResolvedCall,
	Unsupported,
};

enum class asETypedSemanticStatementKind : asBYTE
{
	Block,
	LocalDeclaration,
	Expression,
	If,
	For,
	While,
	DoWhile,
	Switch,
	Case,
	Break,
	Continue,
	Return,
	Unsupported,
};

enum class asETypedSemanticSymbolKind : asBYTE
{
	Receiver,
	Parameter,
	Local,
};

enum class asETypedSemanticUnsupportedKind : asBYTE
{
	None,
	Ternary,
	ObjectAccess,
	PropertyAccess,
	Reference,
	Handle,
	Container,
	ConstructionOrLifetime,
	Lambda,
	ExceptionCleanup,
	SuspendPoint,
	CompilerSynthesizedFunction,
};
```

Add a normalized function header at the same time; do not postpone receiver
shape until the C++ emitter:

```cpp
enum class asETypedSemanticReceiverKind : asBYTE
{
	None,
	NativeObjectThis,
	ExplicitParameterAlias,
	MixinFirstParameter,
};

enum class asETypedSemanticInvocationKind : asBYTE
{
	Global,
	InstanceMethod,
	Constructor,
	Destructor,
	Factory,
	Imported,
	System,
	Funcdef,
	Synthesized,
};

struct asSTypedSemanticEffectiveReceiver
{
	asETypedSemanticReceiverKind kind =
		asETypedSemanticReceiverKind::None;
	asTypedSemanticSymbolId symbol;
	int parameterIndex = -1;
	asCDataType type;
};

struct asSTypedSemanticFunctionHeader
{
	asDWORD declaredTraitBits = 0;
	asETypedSemanticInvocationKind invocationKind =
		asETypedSemanticInvocationKind::Global;
	asSTypedSemanticEffectiveReceiver receiver;
	asECompileOutType compileOutType = asECompileOutType::CompileCalls;
	int hiddenArgumentIndex = -1;
	int determinesOutputTypeArgumentIndex = -1;
	bool returnsOnStack = false;
	bool hasSuspendState = false;
	bool hasExceptionCleanup = false;
};
```

The exact field names may move while implementing, but these invariants do not:

- native instance `this` is a synthetic Receiver symbol and never a declared
  parameter;
- `external_implicit_this` retains declared parameter symbol zero and aliases
  the receiver to it;
- a function mixin retains formal zero, while the source-call receiver maps to
  that formal only at the call expression;
- hidden WorldContext or native ABI inputs are not receivers;
- unknown trait bits remain visible and make initial Semantic eligibility fail
  closed.

Store owned source identity, not a pointer into parser memory:

```cpp
struct asSTypedSemanticSourceSpan
{
	asCString section;
	asUINT sourceOffset = 0;
	asUINT sourceLength = 0;
	asUINT row = 0;     // zero-based internally
	asUINT column = 0;  // zero-based internally
};
```

`asSTypedSemanticExpression` contains, at minimum:

- its exact compiler-resolved `asCDataType`;
- kind and source span;
- ordered operand IDs;
- optional symbol ID;
- operator token;
- literal bytes/text in normalized form;
- resolved function ID for a call, never a retained function pointer;
- unsupported category.

`asSTypedSemanticStatement` contains, at minimum:

- kind and source span;
- ordered owned statement IDs;
- condition/initializer/increment/value expression IDs;
- optional declared local symbol ID;
- switch-case/default shape;
- unsupported category.

`asCTypedSemanticFunction` contains the declaration text, arenas, root block,
and verification result. It must contain no `asCScriptNode*`, `FMemStackBase*`,
bytecode cursor, provider key, or UE reflection object.

### 4.5 Type and target lifetime rule

The HIR is only consumed while its owning source-compiled function and engine
are alive. For v1:

- keep exact `asCDataType` values as non-owning semantic descriptors;
- store resolved script/system target IDs, not function pointers;
- resolve a target ID against the same engine only during analysis;
- never persist HIR or use it after module replacement;
- delete the HIR before `DestroyInternal()` releases function/type references.

Add an explicit helper instead of relying only on the final
`ScriptFunctionData` destructor:

```cpp
void asCScriptFunction::DiscardTypedSemanticFunction()
{
	if (scriptData == 0 || scriptData->typedSemanticFunction == 0)
		return;

	asDELETE(scriptData->typedSemanticFunction, asCTypedSemanticFunction);
	scriptData->typedSemanticFunction = 0;
}
```

Call it at the start of `DestroyInternal()`, before `ReleaseReferences()`. Also
call it before publishing a replacement HIR. This prevents an HIR destructor or
debug assertion from observing already released type/function state.

In `ScriptFunctionData` add only a private-fork field:

```cpp
asCTypedSemanticFunction* typedSemanticFunction = 0;
```

Initialize it in `AllocateScriptFunctionData()`. Keep a defensive delete in
`DeallocateScriptFunctionData()` after the variable cleanup, but assert in debug
that the normal `DestroyInternal()` path already discarded it.

### 4.6 Verifier contract

Return a stable enum and source-located detail rather than a bool:

```cpp
enum class asETypedSemanticVerificationError : asBYTE
{
	None,
	MissingRoot,
	RootIsNotBlock,
	NonContiguousSymbolId,
	NonContiguousExpressionId,
	NonContiguousStatementId,
	DanglingSymbolId,
	DanglingExpressionId,
	DanglingStatementId,
	StatementHasMultipleOwners,
	StatementOwnershipCycle,
	InvalidNodeShape,
	InvalidSourceSpan,
	MissingUnsupportedCategory,
};

struct asSTypedSemanticVerificationResult
{
	asETypedSemanticVerificationError error =
		asETypedSemanticVerificationError::None;
	asTypedSemanticExpressionId expression;
	asTypedSemanticStatementId statement;
	asSTypedSemanticSourceSpan span;
	asCString detail;

	bool IsValid() const
	{
		return error == asETypedSemanticVerificationError::None;
	}
};
```

Verification is deterministic: traverse arenas in ascending ID order and stop
at the first invalid record. No hash-table iteration order may select the first
error.

### 4.7 Normalized dump

Expose only a fork-private helper:

```cpp
asCString DumpTypedSemanticFunction(
	const asCTypedSemanticFunction& Function);
```

Match the research dump conventions:

- `S`, `E`, and `T` prefixes for typed IDs;
- arena order, never pointer or map order;
- canonical type spelling;
- canonical integer/float/enum literal spelling;
- LF newlines;
- no addresses;
- source spans as `section@offset+length`.

Do not add `asITypedSemanticFunction` or an accessor to `angelscript.h`.

### 4.8 P1 verification

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" `
  -Label semantic-ir-model `
  -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite Standalone `
  -LabelPrefix semantic-ir-model-standalone `
  -TimeoutMs 600000
```

Do not proceed to capture until both layers construct, reject, dump, and destroy
the same first-slice model.

## 5. Patch P2 — transactional compiler capture

### 5.1 Files

Modify:

```text
ThirdParty/angelscript/source/as_scriptengine.h
ThirdParty/angelscript/source/as_scriptengine.cpp
ThirdParty/angelscript/source/as_compiler.h
ThirdParty/angelscript/source/as_compiler.cpp
AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeTypedSemanticIRTests.cpp
Standalone/Tests/AngelscriptTypedSemanticIRTests.cpp
```

### 5.2 Tests first

Add red tests for:

- capture defaults off;
- capture must be set before source compilation;
- capture-off and capture-on bytecode/dump metadata are identical;
- successful capture publishes one verified HIR;
- a source compile error publishes no HIR;
- a deliberately invalid provisional HIR publishes no HIR but does not turn
  otherwise valid bytecode compilation into failure;
- parser destruction leaves HIR usable and leaves no parser-node address in it;
- repeated source compilation produces identical normalized dumps;
- `asCExprContext::{Clear,Copy,Merge}` follow the ID propagation table below.

Do not use the sparse semantic observer as a reconstruction source. One overlap
test may confirm that observer and HIR resolved-call IDs agree, but capture must
remain independent.

### 5.3 Fork-private capture switch

Add a field to `asCScriptEngine::ep` and initialize it to false in
`asCScriptEngine::asCScriptEngine()`:

```cpp
bool captureTypedSemanticIR;
```

Add fork-private, non-interface methods on `asCScriptEngine`:

```cpp
void SetTypedSemanticIRCapture(bool Enabled)
{
	ep.captureTypedSemanticIR = Enabled;
}

bool IsTypedSemanticIRCaptureEnabled() const
{
	return ep.captureTypedSemanticIR;
}
```

These methods are not new `asIScriptEngine` virtuals and do not change
`angelscript.h`. Production freezing through `FAngelscriptEngineConfig` is a
later adapter patch. The first slice sets this switch directly on its isolated
test/generation engine before any fixture module build.

### 5.4 Compiler builder owner

Add to `asCCompiler`:

```cpp
asCTypedSemanticIRBuilder* typedSemanticIRBuilder = 0;

void DiscardTypedSemanticIRBuilder();
void CommitTypedSemanticIR();
```

The compiler constructor initializes the pointer. The destructor discards it.
`Reset()` must always discard an earlier provisional builder before assigning
the next compilation state:

```cpp
void asCCompiler::Reset(...)
{
	DiscardTypedSemanticIRBuilder();
	// Existing Reset assignments remain unchanged.
	...
	if (engine->IsTypedSemanticIRCaptureEnabled())
	{
		typedSemanticIRBuilder = asNEW(asCTypedSemanticIRBuilder)(
			engine, script, outFunc);
	}
}
```

Builder writes must be observational. No builder return value may select a
bytecode instruction, overload, conversion, variable slot, or control-flow
label.

### 5.5 Expression identity

Add to `asCExprContext`:

```cpp
asTypedSemanticExpressionId typedSemanticExpression;
```

Lock the propagation behavior before editing individual compile functions:

| operation | resulting ID |
| --- | --- |
| constructor / `Clear()` | invalid |
| `Copy(Other)` | `Other.typedSemanticExpression` |
| `Merge(After)` | `After.typedSemanticExpression` via existing copy behavior |
| `SetVoidExpression()` | invalid |
| discarded expression | invalid after its enclosing statement captures it |
| final implicit/explicit conversion | new Conversion expression ID |
| final assignment | new Assignment expression ID |
| final resolved call | new ResolvedCall expression ID |
| logical `&&` / `||` | new ShortCircuit ID with ordered left/right operands |
| compile error | invalid or unreachable provisional ID; never published |

Copying an ID does not clone a node. Arena nodes are immutable after insertion.

### 5.6 First-slice hook map

Capture after the existing compiler has made its decision:

| Existing compiler function | Capture action |
| --- | --- |
| compiler reset/function setup | snapshot traits, object/function kind, return ABI, hidden-argument and cleanup disposition before body capture |
| `SetupParametersAndReturnVariable` | create parameter symbols in declaration order; when `EXTERNAL_IMPLICIT_THIS` is valid, alias receiver to parameter symbol zero without deleting it |
| `CompileVariableAccess` | after local/parameter/member/property resolution, create Symbol or resolved-member expression with an explicit receiver operand; preserve lookup shadowing |
| `CompileExpressionValue` | after literal type/value resolution, create Literal expression |
| `CompileMathOperator` | after operand conversions and result type, create Binary expression |
| `CompileComparisonOperator` | after comparison selection, create Binary expression with bool result |
| `CompileFunctionCall` before ordinary call emission | capture `CompileOutEntirely`, `ReplaceWithFirstParam`, or `CompileOutAsMethodChain` as the final value/effect and do not create an executable call |
| `CompileFunctionCall` after mixin/overload/default resolution | record source receiver/argument roles once, effective formal bindings, the maintained compiler's authoritative evaluation sequence, receiver position, hidden/default origins and concrete result type; ordinary call arguments are reverse formal order, not generic left-to-right |
| `PerformFunctionCall` | attach the exact resolved script/system/imported target and dispatch/ABI-only requirements after all compiler decisions are final |
| `CompileDeclaration` | after local allocation and initializer conversion, create local symbol + LocalDeclaration |
| `CompileReturnStatement` | after return conversion, create Return statement |
| `CompileIfStatement` | after condition conversion and branch compilation, create If + branch blocks |
| `CompileStatementBlock` | create Block with children in source/evaluation order |

Do not create a Binary node at the start of overload selection. If operator
overload resolution selects a call, capture the final resolved call or an
unsupported marker instead of a guessed primitive operator.

Do not derive receiver kind from syntax in the emitter. In particular,
`external_implicit_this` is a global function whose real parameter zero also
backs unqualified member lookup; a mixin is a global function whose method-call
receiver becomes real argument zero; and an ordinary instance method has a
separate VM object slot. The model and verifier rules are detailed in
`function-traits-and-effective-receiver.md`.

### 5.7 Statement assembly

Use a builder stack for lexical statement ownership:

```cpp
class asCTypedSemanticIRBuilder
{
public:
	void BeginBlock(const asSTypedSemanticSourceSpan& Span);
	asTypedSemanticStatementId EndBlock();
	void AppendStatement(asTypedSemanticStatementId Statement);
	...

private:
	asCArray<asTypedSemanticStatementId> blockStack;
	asCArray<asTypedSemanticStatementId> pendingChildren;
};
```

The exact storage may differ, but these invariants are mandatory:

- a statement has one owner;
- source/evaluation order is explicit;
- `if` owns then/else blocks through IDs;
- no statement points at raw parser nodes;
- bytecode labels are not copied into structured HIR.

### 5.8 Commit/discard sequence

The successful source path already checks compile errors before calling
`FinalizeFunction()`. Keep bytecode finalization authoritative, then commit HIR:

```cpp
if (hasCompileErrors || builder->numErrors != buildErrors)
{
	DiscardTypedSemanticIRBuilder();
	return -1;
}

RemoveVariableScope();
byteCode.Ret(-stackPos);
FinalizeFunction();              // unchanged bytecode publication
CommitTypedSemanticIR();         // new, non-fatal sidecar publication
return 0;
```

`CommitTypedSemanticIR()` performs an atomic handoff:

```cpp
void asCCompiler::CommitTypedSemanticIR()
{
	if (typedSemanticIRBuilder == 0)
		return;

	asCTypedSemanticFunction* Candidate =
		typedSemanticIRBuilder->ReleaseFunction();
	DiscardTypedSemanticIRBuilder();

	const asSTypedSemanticVerificationResult Verification =
		VerifyTypedSemanticFunction(*Candidate);
	if (!Verification.IsValid())
	{
		asDELETE(Candidate, asCTypedSemanticFunction);
		return; // bytecode remains valid; Semantic later reports Missing/Invalid IR
	}

	outFunc->DiscardTypedSemanticFunction();
	outFunc->scriptData->typedSemanticFunction = Candidate;
}
```

The production implementation should retain the verifier failure detail in a
small transient diagnostic field if needed, but must not persist the HIR or
failure through bytecode archives.

Early parser failure, compiler errors, compiler destruction, and a subsequent
`Reset()` all discard the provisional builder. No path publishes a partial
function.

### 5.9 Bytecode equality sentinel

Compile the same source twice in two otherwise identical isolated engines. One
has capture off and one on. Compare:

- bytecode length and every bytecode word;
- line numbers and section indexes;
- artifact canonical source and dependencies;
- VM return values for the four scalar inputs.

Also save bytecode/cache from capture-on and prove that loading it produces no
HIR. Do not add HIR fields to save/restore code.

### 5.10 P2 verification

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" `
  -Label semantic-ir-capture-scalar `
  -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite Standalone `
  -LabelPrefix semantic-ir-capture-standalone `
  -TimeoutMs 600000
```

### 5.11 P2 receiver/trait patch slice

After the scalar body captures successfully, extend the same model before
production eligibility work. This slice is recognition and verification first;
it does not make UObject/property bodies Semantic-eligible.

Tests first in
`AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeTypedSemanticIRTests.cpp`:

1. compile a normal global scalar function and assert `Receiver=None`;
2. compile a normal instance method and assert one synthetic receiver plus an
   unchanged declared-parameter count;
3. compile
   `void Init(UReceiver Self) external_implicit_this` and assert parameter zero
   is both `Parameter(S0)` and `ExplicitParameterAlias(S0)`;
4. capture explicit `this`, unqualified field, unqualified method and property
   accessor operations with an explicit S0-derived receiver expression;
5. declare a local/parameter matching a receiver member and prove the final HIR
   references the normal symbol selected by existing lookup precedence;
6. cover missing, primitive, wrong-index, dangling-symbol and type-mismatched
   receiver records with stable verifier codes and zero HIR publication;
7. compile a function mixin method call and prove the receiver is evaluated
   once and becomes effective formal zero without giving the callee body an
   external implicit receiver;
8. cover all four `asECompileOutType` values and prove only `CompileCalls`
   creates an executable resolved call;
9. cover hidden WorldContext/default argument origin, determines-output-type,
   and a native script-function-first requirement without treating any of them
   as a receiver;
10. table-drive all current trait bits and one unknown bit; the unknown bit is
    preserved in the normalized dump and fails Semantic eligibility closed.

The minimal verifier extension is:

```text
None
  -> receiver symbol invalid, parameterIndex == -1
NativeObjectThis
  -> valid synthetic Receiver symbol, no declared parameter alias
ExplicitParameterAlias
  -> function is global, trait is set, parameterIndex == 0,
     symbol is declared Parameter(0), symbol/type agree and type is object
MixinFirstParameter
  -> target is mixin, parameterIndex == 0, symbol is declared Parameter(0)
unknown trait bits
  -> structurally valid raw snapshot, Semantic disposition UnsupportedFunctionTrait
```

Capture-on/off equality for this slice compares function traits/signature,
bytecode words, dependency/line metadata and VM results. It must include the
existing literal-asset-shaped initializer as a temporary regression oracle,
while recognizing that the sibling Dynamic Asset change later removes that
language lowering. The future Singleton lifecycle fixture replaces it as the
long-lived generated-function consumer.

Before editing the compiler, run the committed characterization material:

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/fixtures/semantic-aot-v1/Test-ValidateFixtures.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-FunctionTraitSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-ExternalImplicitThisRuntime.ps1
```

The full C++ test cell, private-trait include, smallest production sequence,
and focused UE commands are preserved in
`research/patches/external-implicit-this-test-first-patch.md`. Apply that cell
first when starting this slice. The virtual HIR and source-regex probes are
drift/evidence checks only; they do not satisfy the compiler-capture or
StaticJIT-entry tasks.

## 6. Patch P3 — provider-independent Semantic analyzer and emitter

### 6.1 Files

Create:

```text
AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTModel.h
AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTAnalyzer.h
AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTAnalyzer.cpp
AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTEmitter.h
AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTEmitter.cpp
AngelscriptTest/StaticJIT/AngelscriptSemanticAOTGeneratedOutputTests.cpp
```

Keep these new files independent of the provider registry and Runtime JIT
coordinator. They may use Core string/container types and maintained-fork HIR.

### 6.2 Tests first

Construct a verified in-memory `SemanticScalarBranch` HIR and add red tests for:

- exact declaration and definition text;
- deterministic generated symbol names;
- supported scalar eligibility;
- a dangling-ID HIR returns `InvalidIR` and no output;
- the property fixture returns `UnsupportedExpression` and no output;
- a valid external-implicit-this parameter alias verifies, returns
  `UnsupportedReceiver` in the first scalar emitter, and keeps parameter zero;
- a dangling/mismatched effective receiver returns `InvalidEffectiveReceiver`
  and no output;
- compile-out fixtures contain no generated call to the erased/replaced target;
- an unsupported type returns `UnsupportedType` and no output;
- repeated emission is byte-identical;
- emitted output contains no bytecode/provider symbols;
- failure leaves declaration, definition, includes, and registration fragments
  empty.

### 6.3 Core API

Use an input shape that contains only information already resolved before
provider packaging:

```cpp
enum class EAngelscriptSemanticAOTFallbackReason : uint8
{
	None,
	MissingTypedIR,
	UnsupportedFunctionKind,
	UnsupportedFunctionTrait,
	UnsupportedReceiver,
	UnsupportedSignature,
	UnsupportedType,
	UnsupportedStatement,
	UnsupportedExpression,
	UnsupportedCall,
	UnsupportedLifetime,
	InvalidEffectiveReceiver,
	InvalidIR,
	EmitterFailure,
};

struct FAngelscriptSemanticAOTFunctionShape
{
	FString SymbolName;
	TArray<asCDataType> ParameterTypes;
	asCDataType ReturnType;
	EAngelscriptSemanticAOTInvocationKind InvocationKind;
	EAngelscriptSemanticAOTReceiverKind ReceiverKind;
	int32 ReceiverParameterIndex = INDEX_NONE;
	bool bHasNativeObjectSlot = false;
	bool bReturnsOnStack = false;
};

struct FAngelscriptSemanticAOTEmitOptions
{
	bool bEmitTestProbe = false;
	bool bEmitNormalizedComments = false;
};

struct FAngelscriptSemanticAOTEmission
{
	bool bSuccess = false;
	FString Declaration;
	FString Definition;
	TArray<FString> RequiredIncludes;
	EAngelscriptSemanticAOTFallbackReason FailureReason =
		EAngelscriptSemanticAOTFallbackReason::None;
	asSTypedSemanticSourceSpan FailureSpan;
	FString FailureDetail;
};

FAngelscriptSemanticAOTEmission EmitSemanticFunction(
	const asCTypedSemanticFunction& Function,
	const FAngelscriptSemanticAOTFunctionShape& Shape,
	const FAngelscriptSemanticAOTEmitOptions& Options);
```

The core API must not accept:

- `asIScriptFunction*` or `asCScriptFunction*`;
- a bytecode buffer or bytecode cursor;
- `FStaticJITContext` or `FAngelscriptBytecode`;
- provider catalog, bucket, route snapshot, or runtime coordinator state;
- a UFunction or UObject.

The adapter that creates `FAngelscriptSemanticAOTFunctionShape` must prove it
matches the verified HIR header. The pure emitter does not receive raw function
traits and independently reinterpret them. For the first scalar slice every
receiver kind other than `None` returns `UnsupportedReceiver`; the shape still
exists now so later object support cannot silently change parameter-zero ABI.

This boundary makes accidental bytecode scanning structurally difficult. The
later adapter resolves the function-owned HIR and entry shape before calling
the core.

### 6.4 Analysis result

Separate support checking from text emission:

```cpp
struct FAngelscriptSemanticAOTAnalysis
{
	bool bEligible = false;
	EAngelscriptSemanticAOTFallbackReason FailureReason =
		EAngelscriptSemanticAOTFallbackReason::None;
	asSTypedSemanticSourceSpan FailureSpan;
	TArray<asTypedSemanticSymbolId> OrderedSymbols;
	TArray<asTypedSemanticStatementId> OrderedStatements;
};
```

For the first slice, analysis rejects anything beyond the frozen int/function
shape and node set. Walk symbols and nodes in arena order. Return the first
unsupported node by ascending statement/expression ID, not pointer/map order.

The analyzer always runs the HIR verifier first. Invalid HIR is `InvalidIR`, not
`UnsupportedExpression`.

### 6.5 Scalar emission rules

For `SemanticScalarBranch`, emit the same normalized shape recorded in
`scalar-branch/expected.cpp`:

- parameter symbols `as_sem_s0`, `as_sem_s1`;
- local symbol `as_sem_s2`;
- explicit `int32(...)` literal spelling;
- parentheses around every emitted binary expression;
- structured `if` and block braces from HIR ownership;
- no labels derived from bytecode offsets;
- no source names used as unique C++ identity;
- LF newlines and tabs according to the checked-in golden.

Use a two-phase buffer:

1. emit into a local `FAngelscriptSemanticAOTEmission Candidate`;
2. run final invariants/forbidden-token checks;
3. only then set `bSuccess` and return Candidate;
4. on any error, return a fresh failure result with no partial C++ fields.

### 6.6 Generated-output sentinel

The generated-output test must reject these tokens, case-insensitively:

```text
GetByteCode
FAngelscriptBytecode
FStaticJITContext
FAngelscriptJITProvider
ProviderPrivate
```

It must also reject hexadecimal pointer-like literals with eight or more hex
digits. The OpenSpec fixture validator already enforces the corresponding
research golden rule; the C++ test enforces it on actual emitter output.

### 6.7 P3 verification

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.GeneratedOutput" `
  -Label semantic-aot-scalar-output `
  -TimeoutMs 600000
```

## 7. Patch P4 — compiled AOT probe and three-path parity

### 7.1 Reuse the committed AOT fixture, not provider scaffolding

Use the existing committed surfaces under:

```text
AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotFixture.*
AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.*
AngelscriptTest/StaticJIT/AOT/Generated/
AngelscriptTest/StaticJIT/AngelscriptStaticJITAotTests.cpp
```

Do not make the first Semantic execution proof depend on any uncommitted or
volatile provider module. The existing AOT generation workflow already writes
and verifies checked-in generated translation units; extend that workflow with
a dedicated Semantic probe fragment.

At implementation time, re-read these files because parallel architecture work
may have changed their packaging. Preserve the behavior below even if a file
name has moved.

### 7.2 Fixture API additions

Add stable fixture helpers:

```cpp
const FString& GetSemanticScalarBranchDeclaration();

int32 ExecuteSemanticScalarBranchProbe(int32 A, int32 B);
void ResetSemanticScalarBranchProbeCount();
int32 GetSemanticScalarBranchProbeCount();
```

The execute/count functions are test-only and exported from the
`AngelscriptTest` module. They are not Runtime APIs and are not provider entries.

### 7.3 Generation changes

Before compiling fixture source, call the fork-private capture setter on the
isolated generation engine. Do this immediately after engine construction and
before the first module build.

After the fixture module has compiled:

1. resolve the global `SemanticScalarBranch` by exact declaration from the
   fixture `asIScriptModule`, not by loose name search;
2. cast to the internal script function only inside the adapter;
3. require a non-null, verified `typedSemanticFunction`;
4. construct `FAngelscriptSemanticAOTFunctionShape` from the already resolved
   function signature;
5. call `EmitSemanticFunction()` with `bEmitTestProbe = true`;
6. fail generation if the expected-eligible function reports fallback;
7. place the complete declaration/definition and counter wrapper into a
   dedicated generated file such as
   `AngelscriptSemanticAOTScalarProbe.generated.cpp`;
8. include that file in the existing generated-file Verify/Generate set;
9. run generation twice in one test and compare normalized HIR and output bytes.

The generated wrapper shape is:

```cpp
namespace
{
	TAtomic<int32> GSemanticScalarBranchProbeCount{0};

	int32 AS_Test_Semantic_SemanticScalarBranch(int32 A, int32 B)
	{
		GSemanticScalarBranchProbeCount++;
		// Emitter-generated body follows.
	}
}

int32 AngelscriptStaticJITAotFixture::ExecuteSemanticScalarBranchProbe(
	int32 A,
	int32 B)
{
	return AS_Test_Semantic_SemanticScalarBranch(A, B);
}
```

Keep the emitter body provider-independent. The fixture wrapper supplies the
counter and exported test seam.

### 7.4 Interpreter and Legacy execution

For each matrix row:

- Interpreter: compile the same fixture source in an isolated engine without a
  JIT provider, prepare the resolved function, set both integer arguments, and
  read the return DWORD after `asEXECUTION_FINISHED`.
- Legacy: use the existing checked-in legacy StaticJIT AOT load path, resolve the
  same declaration, assert the current legacy generated entry is registered,
  execute through the normal context, and read the return DWORD.
- Semantic: call `ExecuteSemanticScalarBranchProbe(A, B)` directly.

Compare all three to the expected result. Reset diagnostics/counters before
each backend phase so a prior execution cannot satisfy the assertions.

The Semantic path must not call the script context. Its direct exported fixture
function is the proof that the emitted C++ compiled and ran independently of
provider routing.

### 7.5 What P4 does and does not prove

P4 proves:

- real source produced the HIR consumed by the emitter;
- the generated C++ is a valid Unreal module translation unit;
- scalar behavior matches interpreter and Legacy;
- the Semantic body ran;
- output regeneration is deterministic.

P4 does not prove:

- production UFUNCTION root selection;
- `UASFunction` entry attachment;
- provider identity or runtime route publication;
- native-call linkage/bridging;
- runtime invalidation/hot reload.

Those remain later OpenSpec tasks and must not be marked complete by the probe.

### 7.6 P4 verification

Regenerate first, then rebuild because generated C++ cannot execute until it is
compiled:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.AOT.GeneratedOutput" `
  -Label semantic-aot-scalar-generate `
  -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunBuild.ps1 `
  -Label semantic-aot-scalar-probe `
  -TimeoutMs 1800000 `
  -NoXGE

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" `
  -Label semantic-aot-scalar-execution `
  -TimeoutMs 600000
```

If the repository's maintained generator uses a commandlet rather than a test
prefix after the parallel architecture work lands, use that maintained entry
point and update this cookbook and `tasks.md` together. Never hand-edit the
generated probe to make a stale-output test pass.

## 8. Later production adapter

Only after P1-P4 pass should the feature consume the final StaticJIT framework.
The adapter has four responsibilities:

1. freeze capture before target source compilation when Semantic/Dual is
   requested;
2. identify eligible resolved UFUNCTION roots;
3. walk and validate each root's reachable ordinary/generated helper closure,
   emitting an internal Semantic helper, selecting a proven bridge, or falling
   back the root before publishing partial symbols;
4. build the shared VM/raw/parameter entry shape from the normalized receiver,
   declared/hidden argument and return ABI;
5. package a successful `FAngelscriptSemanticAOTEmission` through the final
   provider ABI.

The adapter must not move frontend or emitter decisions into provider code. In
particular:

- missing HIR cannot be rebuilt from bytecode or semantic-observer events;
- provider identity cannot become HIR identity;
- Semantic reference analysis cannot call Legacy bytecode reference scanning;
- an external implicit receiver cannot erase parameter zero or become an
  instance object slot;
- mixin, hidden/default and compile-out semantics cannot be reconstructed in
  provider code;
- a non-UFUNCTION helper cannot be omitted merely because it is not a root;
- every direct Semantic helper must preserve the root's required execution
  profile, frame/depth accounting, exception contract, and recursion budget;
- debug frame/line metadata cannot be treated as debugger, coverage, timeout,
  abort, or suspend parity;
- runtime backend settings cannot transpile a missing Semantic body;
- changing provider APIs must require only adapter edits, not P1-P3 rewrites.

Native direct calls and scalar bridges are a separate capability extension.
Until their explicit linkage and marshalling descriptors exist, a call node is
an unsupported first-slice function and falls back as a whole.

The exact follow-on RED/GREEN cells for verified break/continue targets, loop
phases, switch invalid-enum edges, single-evaluation mutations, JIT frame/depth
RAII, native recursion protection, and instrument-or-VM routing are recorded in
`research/patches/execution-observability-and-control-flow-test-first-patch.md`.
Do not broaden P1-P4 eligibility to those forms merely because the synthetic
schema or patch cookbook can describe them.

## 9. Patch review checklist

Review each patch against this list before moving to the next:

- [ ] P1 contains no parser/bytecode/provider pointer in HIR.
- [ ] P1 destroys HIR before releasing referenced compiler/runtime state.
- [ ] P1 and Standalone produce the same normalized dump.
- [ ] P1 models native-this, external-parameter and mixin receivers distinctly.
- [ ] P1 verifier rejects a missing/dangling/type-mismatched receiver alias.
- [ ] P1 preserves unknown trait bits and Semantic fails them closed.
- [ ] P2 capture defaults off and is enabled before source build.
- [ ] P2 capture-on/off bytecode and VM behavior are identical.
- [ ] P2 compiler errors and invalid HIR publish no partial sidecar.
- [ ] P2 captures compile-out, hidden/default and determines-output-type final
      semantics instead of source spelling.
- [ ] P2 external implicit this retains declared parameter zero and explicit
      receiver operands for resolved member/property/call forms.
- [ ] P2 break/continue records and verifies the nearest legal target statement,
      loop phase, exited scopes, and switch invalid-value edge without bytecode
      labels.
- [ ] P2 mutation nodes prove one target evaluation/one store and distinguish
      prefix updated from postfix old result.
- [ ] P3 API cannot receive bytecode or provider state.
- [ ] P3 emission failure returns no partial C++ fragments.
- [ ] P3 actual output passes the bytecode/provider token sentinel.
- [ ] P3 scalar emitter returns typed fallback for every non-None receiver.
- [ ] P3 generated output contains no call for a compiled-out call expression.
- [ ] P4 generated source is checked in through the maintained generator.
- [ ] P4 rebuilds the generated translation unit before runtime parity.
- [ ] P4 compares VM, Legacy, and Semantic for all four rows.
- [ ] P4 Semantic counter proves four native calls.
- [ ] P4 does not claim production provider/UASFunction integration.
- [ ] Production Semantic frames/depth/recursion are proven for direct helpers
      before recursive closures become eligible.
- [ ] Position-only metadata is never advertised as breakpoint/step/locals,
      CodeCoverage, loop-timeout, abort, or suspend support.
- [ ] Every execution requirement is closed over direct Semantic callees or the
      invocation routes to VM.
- [ ] No task removes or silently changes Legacy StaticJIT.
- [ ] No UE Engine source, public `angelscript.h` ABI, or cache schema changes.

## 10. Final verification for the vertical slice

After P1-P4 pass individually, run the combined gates:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunBuild.ps1 `
  -Label semantic-aot-scalar-final `
  -TimeoutMs 1800000 `
  -NoXGE

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" `
  -Label semantic-aot-scalar-compiler-final `
  -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT" `
  -Label semantic-aot-scalar-staticjit-final `
  -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite Standalone `
  -LabelPrefix semantic-aot-scalar-standalone-final `
  -TimeoutMs 600000
```

Record the actual counts and failures. Do not copy historical suite baselines
into the change record and do not mark the later production/provider groups
complete from this functional proof.
