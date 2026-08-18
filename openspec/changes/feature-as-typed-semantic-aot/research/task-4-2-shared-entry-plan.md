# Task 4.2 — shared StaticJIT Entry Plan

## 2026-08-17 audit finding

Task 4.2 is a real architecture gap rather than an unchecked completed task.
The current generation snapshot shares only `bHasVMEntry`, `bHasRawEntry`,
`bHasParmsEntry`, and `EntryPlanHash`.  `FAngelscriptTypedASTJIT` subsequently
calls `BuildAngelscriptTypedASTJITProviderEntryPlan()` with the live
`asCScriptFunction` and independently derives C++ spellings, VM frame offsets,
the native object slot, reflected parameter layout, and return placement.
BytecodeJIT independently derives the same entry-facing facts inside
`FStaticJITContext::GenerateNewFunction()`.

That state contradicts the design/spec requirement that body analysis remains
backend-specific while entry ABI planning is Runtime-owned and shared.  It also
leaves parameter-zero preservation for `external_implicit_this` implicit in two
separate implementations.

## TDD RED

A focused capability owner was added at:

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/EntryPlan/AngelscriptStaticJITEntryPlanTests.cpp`

The first two cases require:

- a pointer-free `FStaticJITEntryPlan` with literal body/entry C++ spellings,
  VM frame offsets, reflected order, return placement, receiver classification,
  wrapper availability, and a stable hash;
- an `external_implicit_this` function to retain formal parameter zero in the
  parameter array while marking it as a declared receiver alias.

Expected build RED:

- label: `semantic-aot-task42-entry-plan-red`;
- evidence: `Saved/Build/semantic-aot-task42-entry-plan-red/20260817_031339_932_2fceb6dd/`;
- result: failed only because
  `StaticJIT/AngelscriptStaticJITEntryPlan.h` does not yet exist.

## Implementation boundary

The production change must not stop at adding an unused DTO.  The generation
snapshot/compiled graph must own and expose the plan, TypedASTJIT must consume
that frozen plan instead of rereading `asCScriptFunction` for entry layout, and
BytecodeJIT must consume or validate the same applicable plan while its
protected generated text remains byte-for-byte stable.  Unsupported complex
BytecodeJIT shapes remain on the legacy compatibility path; they must not be
misreported as Typed-representable merely because the base wrapper flags exist.

## Bytecode consumer RED

The initial model/snapshot tests proved that Runtime can freeze the common
facts, but they did not prove that BytecodeJIT consumes them. A separate
capability owner now exercises the real registered Bytecode backend:

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/EntryPlan/AngelscriptStaticJITEntryPlanBytecodeConsumerTests.cpp`

It builds a real scalar script function, freezes its Entry Plan, changes the
test-owned frozen carrier spelling and VM frame offset after capture, and sends
that immutable view through `IAngelscriptStaticJITBackend::Generate`. This is
not a source-text grep or a fake backend: the assertion observes the emitted
function returned by the production Bytecode backend. A consumer that reads
the shared plan emits the frozen values; the current implementation instead
re-derives `asDWORD` and the live offset from `asCScriptFunction`.

Evidence:

- compile-fix build:
  `Saved/Build/semantic-aot-task42-bytecode-consumer-red-build2/20260817_033539_390_da5b8f0b/`
  — PASS;
- expected RED:
  `Saved/Tests/semantic-aot-task42-bytecode-consumer-red/20260817_033557_162_0c075712/`
  — `0/1`, failing only `The raw Bytecode entry must use the frozen carrier
  spelling`.

The production fix must use the shared plan for representable entry-adapter
facts while keeping Bytecode body analysis and complex compatibility layout on
the existing `FStaticJITContext` path. After GREEN, the protected legacy
module output comparison still has to pass byte-for-byte.

## GREEN-attempt fixture correction

The first production build after wiring the shared plan passed:

- `Saved/Build/semantic-aot-task42-bytecode-consumer-green-build/20260817_034206_737_2675abbf/`

The first test attempt then asserted in `FStaticJITContext::VArg_Type` rather
than reaching the CQTest assertions:

- `Saved/Tests/semantic-aot-task42-bytecode-consumer-green/20260817_034230_918_44e2bc7c/`
- assertion: `AngelscriptBytecodeJIT.cpp:2351` while implementing
  `asBC_CpyVtoR4`.

This was a test-fixture invariant violation, not a reason to weaken production
consumption. The original test changed the only real parameter slot to the
nonexistent offset `37`. Once BytecodeJIT correctly consumed the frozen slot,
the body analyzer could no longer find a type for the real bytecode operand.
The revised fixture uses two same-type parameters and swaps their two existing
VM slots. Both bytecode-referenced slots therefore remain represented, while
the emitted entry still proves that the frozen plan, rather than the live
function metadata, controls the carrier and offset. Arbitrary nonexistent
frame offsets are not valid immutable Entry Plans and must not be accepted as
a realistic positive fixture.

## Byte-stability oracle boundary

Two attempted byte-stability seams exposed intentional architecture boundaries
and were rejected rather than weakening Engine isolation or exporting private
BytecodeJIT mechanics:

1. A full legacy-provider comparison built successfully under
   `semantic-aot-task42-bytecode-stability-build`, but the run at
   `Saved/Tests/semantic-aot-task42-bytecode-stability/20260817_035253_031_dc596c75/`
   failed with `StaticJIT generation cannot resolve stable module identities`.
   The legacy compatibility API reads the ordinary Engine publication/route
   authority, whereas the generation-only Engine intentionally exposes only
   its frozen snapshot adapters. Giving the isolated Engine process-wide route
   state merely to make this test pass would reopen a closed isolation bug.
2. A lower-level `FStaticJITContext` comparison then failed to link at
   `Saved/Build/semantic-aot-task42-bytecode-entry-stability-build/20260817_035840_276_162b8f44/`.
   `GenerateNewFunction()` and `WriteOutFunction()` are Runtime-private
   implementation methods and are deliberately not exported to the
   `AngelscriptTest` DLL. They must not become public DLL API for a test seam.

The accepted oracle therefore stays on the already-exported backend contract:
the test constructs one complete compiled-source graph with explicit stable
module/function identities and invokes the real registered Bytecode backend
twice. The first attempted backend comparison used a null Entry Plan and
correctly failed closed at
`Saved/Tests/semantic-aot-task42-bytecode-entry-stability/20260817_040052_138_9dd49f88/`
with `StaticJIT Provider generation received an incomplete shared Entry Plan`.
The compiled-source graph contract now requires every function to carry the
complete Runtime-owned plan, including complex Bytecode compatibility shapes;
null must not be reintroduced as a legacy escape hatch.

The corrected comparison therefore uses two complete copies of the same plan:
one has `bTypedAdapterRepresentable=false` and selects the documented legacy
complex-shape entry adapter, while the other selects the shared representable
adapter. Their `ImplementationTemplate` values must be exactly equal. A third
invocation mutates the test-owned frozen carrier and swaps two real VM slots,
proving the same backend consumes the plan. Existing full provider golden tests
continue to protect provider packaging independently.

## Existing provider-regression assertion correction

The focused full-provider regression at
`Saved/Tests/semantic-aot-task42-bytecode-provider-compat/20260817_040408_520_ec951615/`
reached and passed the compatibility/direct/explicit byte-for-byte comparisons,
then failed the older assertion that prohibited the substring
`FStaticJITFunction` anywhere in a module source. That assertion was broader
than its own documented purpose. The removed legacy registration was emitted
as:

`AS_FORCE_LINK static const FStaticJITFunction <symbol>_Register(0x<FunctionId>u, ...)`

Current generated bodies legitimately call exported Runtime exception/bridge
helpers such as `FStaticJITFunction::AdoptContextException`; checked AOT output
contains those calls without any persisted FunctionId or registration object.
The regression now rejects the exact legacy static-object prefix and the
`_Register(0x` numeric-id shape separately. It does not ban the helper type
name, so the test continues to enforce stable provider identity without
misclassifying valid Runtime helper calls.

## Final GREEN evidence

The Runtime-owned plan is now built once in the generation snapshot, copied
into function and descriptor views (including the generated WorldContext
overlay), and consumed by both TypedASTJIT and BytecodeJIT. The focused test
surface is split by capability under
`StaticJIT/TypedASTJIT/EntryPlan/`: base model/external receiver, native object
receiver, reflected/hidden layout, and the real Bytecode backend consumer.

Fresh verification from `V:/`:

- build PASS:
  `Saved/Build/semantic-aot-task42-final-build/20260817_040923_147_623294e3/`;
- Entry Plan capability prefix: `5/5 PASS`:
  `Saved/Tests/semantic-aot-task42-entry-plan-final2/20260817_040940_743_f4b3c561/`;
- complete compatibility/direct/explicit Bytecode Provider comparison:
  `1/1 PASS` at
  `Saved/Tests/semantic-aot-task42-bytecode-provider-compat2/20260817_040644_676_5c779b9e/`;
- generation profile frozen before source compile: `1/1 PASS` at
  `Saved/Tests/semantic-aot-task42-generation-profile/20260817_040735_583_d5d9d7bf/`;
- complete graph with separate emit set: `1/1 PASS` at
  `Saved/Tests/semantic-aot-task42-generation-snapshot/20260817_040815_938_7d073da2/`.

The Entry Plan tests cover literal body/entry C++ spellings, VM offsets,
formal/reflected order, direct return placement, VM/raw/Parms availability,
native-object versus declared-receiver identity, external implicit parameter
zero, the generated WorldContext suffix and return offset order. The Bytecode
consumer additionally proves an unmodified plan preserves text and a frozen
carrier/real-slot mutation controls actual backend output. This closes task
4.2 without exposing private BytecodeJIT methods, reopening ordinary Engine
route state, or making null Entry Plans legal.
