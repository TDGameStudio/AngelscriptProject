# Non-Language Native Domains

The language catalogs do not replace direct implementation and public-interface regression coverage. The predecessor's 97 missing non-language exact scenarios are inputs to these domain contracts.

## Engine

- engine creation/release profiles, every engine property touched by helpers, callback/user-data registration, independent engines, module/context ownership, allocation gateway, GC/shutdown cleanup, atomics, TLS/thread preparation, and invalid lifecycle calls;
- products: profile × property, engine A/B × registration/module visibility, resource type × shutdown path, atomic operation × value/boundary/thread count, TLS access × same/different thread × lifecycle, message severity × source location × payload form;
- `ENG-MESSAGE-CALLBACK-CARTESIAN` retains all 3 severity forms × 4 coordinate/section forms × 3 payload forms (36 direct `WriteMessage` cells), including empty payload and zero/large offsets;
- `ENG-ATOMIC-OPERATIONS` retains 4 `asCAtomic` operations × 4 signed initial values × single/concurrent worker modes (32 direct cells), with deterministic final values and balanced operation checks;
- `ENG-PRODUCT-VERSION-CONTRACT` owns the Unreal AngelScript product name, semantic and encoded version, upstream-lineage separation, current/legacy/newer/cross-major engine creation behavior, and synthetic same-major backward-compatibility rules;
- current process-global state must be observed/restored safely; non-restorable public operations remain explicit exclusions.

## Frontend

- complete token taxonomy from `as_tokendef.h`, longest-match operators, keywords accepted/rejected by this fork, numeric/string/character forms, whitespace/comments/BOM/EOF, malformed token recovery, and exact token ranges; the current tokenizer depth includes explicit sign/termination, escape/line-ending, comment/whitespace, and raw EOF products;
- parser entry points for script/expression/statement, every declaration and statement node family, precedence/associativity, error ownership/recovery, source ranges, node parent/child/sibling invariants, deep copy/ownership, CRLF/LF, and long/deep inputs;
- products: token × adjacent token class × whitespace form, overlapping operator prefix × following character, operator × left operand × right operand × spacing (including dot-plus-number lexical merging), malformed operator prefix × recovery tail, contextual parser word × identifier boundary, numeric form × suffix × termination, literal family × payload/escape × EOF/LF/CRLF/identifier boundary, comment/whitespace family × payload/BOM × EOF/LF/CRLF/identifier boundary, parser declaration family × parameter shape × body shape × LF/CRLF, expression operator shape × grouping form, node kind × depth × traversal/copy operation, LF/CRLF × script-code start/middle/end/EOF position, parser production × valid/missing/extra delimiter, node kind × traversal/copy/source-range operation;
- line-sensitive inputs use preserve-lines wrappers and explicit reasons.
- internal-class follow-up products now directly exercise tokenizer protected helper
  dispatch and radix classification, parser token predicates and exact identifier
  spelling, and `asCString`/`asCStringPointer` storage/comparison operations;
  these are native-only observations and do not replace source-level parser
  production coverage.

### Frontend internal-class accountability

The frontend owner is already a dedicated raw-SDK suite rather than only a
script-level integration suite. `asCTokenizer` is exercised directly through
the test-only `FTokenizerAccessor` (`GetToken` and token-definition lookup),
and `asCParser` is constructed directly for script, expression, statement,
error-recovery, and reset paths. `asCScriptNode` and `asCScriptCode` are also
observed directly for tree links, deep copy, source ranges, `SetCode`, and
row/column conversion. The current frontend directory contains 17 files and
149 CQTest methods, with 20 catalogued tokenizer/parser/node products.

This is class-level direct/behavioral coverage, not yet a one-to-one closure
for every implementation method. Parser protected productions and predicates
(`ParseType`, `ParseVarInit`, `Is*`, delimiter recovery, and similar helpers)
are currently reached through public parser entry points and AST/diagnostic
oracles; the audit does not yet prove an individual owner for each helper.
Likewise, `asCString` and `asCStringPointer` are present in the internal-class
inventory, while the current frontend tests cover the free string utilities
but do not yet provide a dedicated class-level method inventory for those two
types. This distinction is intentional and is tracked as an open follow-up,
not counted as completed internal-method coverage.

## Compiler

- builder parse/type/function/property/namespace/dependency/global stages, failure atomicity/rebuild, exact diagnostics, enum-description cleanup, compiler expression/type resolution, output buffer, instruction list mutation, bytecode generation, jumps, optimization, and debug markers;
- products: build stage × success/failure/rebuild, section order × dependency, diagnostic stage × section/row/column/severity, control construct × opcode/target/runtime result, optimization mode × result/branch/debug marker, builder shape × failure kind × same/fresh-engine recovery route;
- `COMPILER-BUILDER-SHAPE-FAILURE` embeds each malformed-signature, unknown-type, and unclosed-scope failure inside the selected basic-function, namespace-call, const-global, or class-property/method source shape; its invalid cells are semantic intersections rather than repeated generic failures;
- `COMPILER-BUILDER-REBUILD-RECOVERY` retains two builder shapes × three shape-aware invalid source families × same/fresh engine recovery (12 source/recovery cells), requiring failure diagnostics, module discard, successful re-publication, and runtime result after recovery;
- `COMPILER-BUILDER-FUNCTION-DECLARATION` retains three explicit-width return types × four parameter shapes × two trait states × two namespaces (48 cells), checking exact return, parameter/default, trait, and namespace metadata through the raw builder application interface;
- `COMPILER-BUILDER-SCALAR-DECLARATION`, `COMPILER-BUILDER-TEMPLATE-DECLARATION`, and `COMPILER-BUILDER-PROPERTY-VERIFICATION` retain 36 additional direct builder cells across scalar qualifiers/namespaces, template arity/identifier/whitespace, and property type/qualifier/conflict state;
- `COMPILER-BYTECODE-CONTAINER-OPERATIONS` retains four initial instruction counts × five mutation routes × three payloads (60 cells), including empty removal, prepend/append, clear/reuse, zero-size linked labels, serialized-size parity, and resolved forward jumps;
- `COMPILER-BYTECODE-OPCODE-DESCRIPTORS` walks every opcode through `asBC_MAXBYTECODE`, validates its index/name/encoding/serialized size, and prints the complete native descriptor input including stack delta for review;
- `COMPILER-BYTECODE-SHAPE` provides runtime/opcode evidence for arithmetic, branch, and loop shapes. Its class source proves type/method layout publication plus a safe executable `Entry`; it does not claim local reference-class construction or object-method invocation on the current fork;
- the current Compiler method disposition is regenerated after each coherent batch; the descriptor owner and reviewed diagnostic/optimization compatibility methods reduce the remaining unowned Compiler inventory without claiming API, internal-method, or predecessor closure;
- every internal/compiler assertion correlates to public build/runtime behavior where observable.

## Runtime

- prepare/arguments/object/execute/returns/suspend/abort/exceptions/recovery, generic interface, script object construction/copy/assignment/refcounts/weak flag, GC cycle/enumeration/statistics/repeatability, plus all `NativeDebug` coverage;
- products: argument/return accessor × type/valid-invalid index/state, context operation × state, exception/abort/suspend outcome × reuse action, object operation × ownership relation, GC graph shape × root/release/collection sequence.
- `RT-CTX-POOL-FALLBACK-LIFETIME` owns raw fallback `RequestContext`/`ReturnContext` and the public context reference lifecycle: exact engine identity, the balanced `AddRef`/`Release` pair, final cleanup callback, and null return safety are all observed without reading a returned context after its ownership is consumed;
- `RT-CTX-POOL-CALLBACK-ROUTING` owns paired callback installation, both one-sided `asINVALID_ARG` configurations, preservation of the installed pair after each rejection, exact engine/parameter/context routing, explicit callback release, clear, and restored fallback behavior;
- `RT-CTX-METHOD-OBJECT-REFERENCE-RETURN` owns prepared method receiver installation and reference return identity. The compiled script class proves constructor state, pre-execution null, exact property address after completion, mutation through that address, a second observable invocation, primitive-return null, and ordered object/context/module cleanup. Unsafe unprepared `SetObject` calls remain excluded because the current fork writes an unvalidated stack-frame pointer;
- `RT-CTX-VARTYPE-ARGUMENT-METADATA` owns the unprepared, one-past-index, and ordinary-parameter rejections plus int32, double-backed float64, and bool positive calls. Every positive type proves the exact generic callback count, function/engine identity, address, type ID, type-specific result, recovery, and cleanup.
- `RT-OBJ-TYPE-ENGINE-IDENTITY` owns live script-object identity for constructed, copied, and uninitialized origins. Each origin proves exact `GetObjectType`, `GetTypeId` plus engine TypeInfo round-trip, and `GetEngine` before and after balanced object reference ownership; stale, released, unregistered, and fabricated receivers remain unsafe and are never used as negative probes.
- `RT-OBJ-USERDATA-FORK-STUB` owns default/custom slots across initial, install, replacement, and clear. Every accessor remains null because this fork does not store script-object user data; the enabled owner prints the complete fixture and an explicit fork-limitation message rather than claiming working slot isolation or destruction cleanup.

## Module

- create/build/rebuild/discard/recreate, multi-section order/ownership, exact functions/types/globals, namespaces, imports bind/unbind/mismatch, current const-global semantics, state tables, save/load with/without debug info, corrupt/truncated streams, primitive restore where exposed;
- products: lifecycle operation × prior state, section count/order × dependency/failure, lookup family × exact/missing/ambiguous, import state × signature compatibility, saved content family × debug-strip/load/execute, corruption position × recovery.
- `MOD-SCRIPT-CLASS-SAVELOAD-LIFECYCLE` keeps two raw script-class save/load workflows: release the predecessor function before source-module discard, or retain it through destination load. Both retain exact base/derived layout, inherited metadata, four runtime reads, debug information, destination cleanup, engine teardown, and a post-teardown allocation control. The two paths are distinct predecessor-lifetime behavior, not duplicate execution.
- `MOD-BYTECODE-STREAM-RESTORE` keeps seven direct raw-stream scenarios separate: supported primitive and stripped-debug round trips; empty and truncated input rejection; failed-load cleanup; explicit version-one rejection after the stream-format change; and a nested non-POD `CopyScript` source. The last source is saved by two concurrent identical engines to prove deterministic output, then loaded into a replacement module to retain the current fork's exact shared-`$obj` rejection. It does not claim successful nested non-POD restore while that loader restriction remains.

## TypeSystem

- data types/flags/declarations/size/alignment, config groups, global properties, variable scopes, type info, object properties/methods/behaviors/base/subtypes, enum/alias/funcdef/function metadata, delegates, user data, default traits correlated to runtime behavior;
- products: type category × qualifier/handle/ref/const flag, metadata query × type kind × valid-invalid index, config group × owned registration × removal/use, function trait × declaration form, trait flag × actual construct/copy/destruct behavior.
- `TYPE-DATATYPE-QUALIFIER-CARTESIAN` directly exercises the vendored `asCDataType` implementation across eleven primitive tokens (`int8`, `int16`, `int`, `int64`, `uint8`, `uint16`, `uint`, `uint64`, `float32`, `float64`, `bool`) and four qualifier forms (mutable, const, reference, const-reference), retaining **44** cells. Each cell prints a generated AS witness, compiles and executes it, then uses an independent native oracle for token/category flags, size/alignment, canonical format, qualifier-insensitive equality, exact equality, and cleanup. This is a raw TypeSystem owner and does not test UE bindings or add-ons.
- `TYPE-TYPEINFO-SHADOW-SYSTEM-TYPE` owns `CopySystemType` with valid same-engine object types: clean, direct, transitive, method lookup, replacement, transitive replacement, and ordered clear states retain exact `ShadowsFrom` and method identities. Null is used only for cleanup; self/cyclic, cross-engine, primitive, typedef, funcdef, and dangling-owner inputs remain unsafe because the fork stores an unchecked non-owning pointer and has no traversal cycle guard.

## Embedding

- global/object/interface registration, duplicate/invalid registrations, factories/behaviors/properties/methods, CDECL/generic/thiscall paths that the fork actively supports, argument/return marshalling, generic interface, string-factory contract, JIT callbacks, thread-manager contract, user-data cleanup;
- products: calling convention × representative signature/type/arity, registration kind × valid/duplicate/invalid flags/declaration, native object kind × lifecycle behavior, generic argument/return accessor × type, user-data owner × replace/release callback count;
- unsupported ABI combinations remain exact active negatives, not permissive alternatives.

## Conformance

- current enabled fork behavior: const versus mutable globals, automatic references versus explicit handles, script-interface rejection versus native-interface support, mixin global versus mixin class, double-backed floating ABI, suspend behavior, and other audited divergences;
- future 2.38: using namespace, member initialization modes, generated/deleted special members, bool-context behavior, anonymous-function execution, variadic functions, and function templates only where syntax/API can be compiled as real Disabled tests;
- every classification names the vendored/current behavior and the desired target; no test accepts both.

## Closure

Each domain receives its own combination catalog during implementation planning expansion. The complete audit treats the predecessor's 122 non-language requirements as a minimum seed and fails while any inherited row or newly discovered public/internal behavior lacks a concrete test implementation location and evidence disposition.
