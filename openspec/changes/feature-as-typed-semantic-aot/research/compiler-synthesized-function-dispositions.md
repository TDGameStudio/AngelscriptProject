# Compiler and synthesized function disposition inventory

## Purpose

Task 2.9 requires every compiler/build artifact family to have one honest,
observable disposition: verified HIR, stable no-HIR reason, deterministic
compile rejection, or a source-backed explanation that the family does not
enter the script compiler. This attachment is the exhaustive inventory for the
maintained fork; it also records the test owner so new cases do not accumulate
in a generic compiler test file.

The artifact enum is authoritative at
`ThirdParty/angelscript/source/as_buildartifact.h:30-43`. Its current values are
`INVALID`, ordinary global/method/constructor/destructor/factory, generated
default constructor/destructor, `INIT_DEFAULTS`, public single function and
lambda. A list factory is not a member of this compiler artifact enum.

## Disposition table

| Family | Current compiler/source path | Typed Semantic IR disposition | Capability-owned proof | Status |
| --- | --- | --- | --- | --- |
| Invalid invocation | Descriptor default in `as_buildartifact.h:48-57` | Not compilable; invalid coordinate is rejected before publication | Existing artifact descriptor/eligibility tests | Covered as invalid input |
| Global function | `as_builder.cpp:5546-5555` selects `GLOBAL_FUNCTION`; ordinary `CompileFunction` transaction | Complete provisional HIR is verified and published only after successful compilation | Foundation, expression, operator and resolved-call TypedSemanticIR tests | Covered |
| Method | `as_builder.cpp:5546-5555` selects `METHOD`; ordinary `CompileFunction` transaction | Complete verified HIR, including effective receiver facts | Property and implicit-member capability tests | Covered |
| User constructor | `as_builder.cpp:5546-5555` selects `CONSTRUCTOR`; ordinary `CompileFunction` transaction | Complete verified HIR when the authored body is representable | Foundation/lifetime compiler tests | Covered |
| User destructor | `as_builder.cpp:5546-5555` selects `DESTRUCTOR`; ordinary `CompileFunction` transaction | Complete verified HIR when the authored body is representable | Foundation/lifetime compiler tests | Covered |
| Generated default constructor | `as_compiler.cpp:1939-1944` | No HIR; stable `unsupported compiler-synthesized function: default-constructor` diagnostic; bytecode/runtime unchanged | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLifecycleTests.cpp` | Covered |
| Generated default destructor | `as_compiler.cpp:2015-2020` | No HIR; stable `unsupported compiler-synthesized function: default-destructor` diagnostic; bytecode/runtime unchanged | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLifecycleTests.cpp` | Covered |
| Generated script factory | `as_compiler.cpp:2128-2133` | No HIR; stable `unsupported compiler-synthesized function: factory` diagnostic; construction behavior unchanged | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLifecycleTests.cpp` | Covered |
| Generated `__InitDefaults` | `as_compiler.cpp:2874-2885`; default statements compile at `as_compiler.cpp:3034-3039` | No HIR; stable `unsupported compiler-synthesized function: init-defaults`; bytecode is capture-invariant and real execution applies defaults | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedDefaultsTests.cpp` | Covered |
| Explicit `__generated` trait function | Builder records `asTRAIT_GENERATED_FUNCTION`; HIR builder marks `CompilerSynthesizedFunction` at `as_compiler.cpp:336-337` and `782-793` | Complete verified HIR with one deterministic unsupported marker | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedFunctionTests.cpp` | Covered |
| Public single function | Builder selects `PUBLIC_SINGLE_FUNCTION` at `as_builder.cpp:1048-1050`; ordinary compiler transaction follows | Complete HIR when the coordinate is stable; otherwise artifact coordinate is explicitly ineligible | Existing public-single/compiler transaction coverage | Covered; keep normal transaction owner |
| Virtual-property accessor | Parser emits `TXT_VIRTUAL_PROPERTY_REMOVED` at `as_parser.cpp:3487`; text is defined at `as_texts.h:248`; old registration path documents it is unreachable at `as_builder.cpp:5874-5878` | Deterministic compile rejection with capture off/on; no partial type or HIR publication | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedAccessorTests.cpp` | Covered |
| Lambda | Internal registration and artifact kind remain at `as_builder.cpp:5388` and `5417-5420`, but the current public source syntax cannot reach them | Deterministic compile rejection with capture off/on; no function/HIR publication. This does not advertise 2.38 lambda support | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLambdaTests.cpp` | Covered current source boundary |
| List factory | Registered as `asBEHAVE_LIST_FACTORY` system/native behavior, e.g. standalone array add-on `scriptarray.cpp:314` and dictionary add-on `scriptdictionary.cpp:1300` | No compiler-generated script function transaction. The registered behavior remains `asFUNC_SYSTEM`, owns no `scriptData` or Typed Semantic HIR, and callers cross the normal resolved `CALLSYS` boundary | `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedListFactoryTests.cpp` compiles and executes a three-element native list with capture off/on, verifies registration/type behavior identity, and compares bytecode after normalizing only documented Engine-local pointer operands | Covered |

## Verification checkpoint

- `Saved/Build/typed-semantic-synthesized-boundary-partition/
  20260816_205540_756_aec01d17/` — build PASS;
- `Saved/Tests/typed-semantic-synthesized-accessor-exact/
  20260816_205552_057_b2f5c5fa/` — `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-lambda-exact/
  20260816_205629_730_fc055492/` — `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-boundary-partition-group/
  20260816_205706_789_ef45e33a/` — complete TypedSemanticIR prefix `35/35
  PASS`, zero failed/skipped;
- `Saved/Build/typed-semantic-list-factory-engine-local-normalization/
  20260816_212532_082_2172bed4/` — list-factory and fork fix build PASS;
- `Saved/Tests/typed-semantic-list-factory-engine-local-normalization-exact/
  20260816_212549_262_5825c26c/` — exact list-factory boundary `1/1 PASS`;
- `Saved/Tests/typed-semantic-list-factory-engine-local-normalization-group/
  20260816_212625_822_f4f1b01b/` — complete TypedSemanticIR prefix `36/36
  PASS`, zero failed/skipped.

The list-factory proof exposed a maintained-fork ownership defect rather than
an HIR defect: `asCScriptFunction::listPattern` was declared static, so every
new function constructor reset the one process-global pointer and a successfully
registered list factory later crashed compilation with a null pattern. The
field is now per-function, matching the fixed AngelScript 2.38 reference at
`Reference/angelscript-v2.38.0` commit
`0601da029d846a658bf23f2888e953a45a94450a`. The Unreal fork continues to use
its accepted implicit-handle/no-`@` behavior declaration; the reference's
ordinary handle declaration is research evidence, not a syntax migration.

Every current compiler/build artifact family now has a source-backed,
capability-owned observable disposition. Task 2.9 is complete.
