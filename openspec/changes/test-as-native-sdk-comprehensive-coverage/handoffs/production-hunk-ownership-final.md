# Production Hunk Ownership Final Audit

## Scope

This is an independent, hunk-level ownership audit for comprehensive task 2.6.
The population is the current tracked production diff:

```powershell
git -C Plugins/Angelscript diff --unified=0 -- Source/AngelscriptRuntime
```

At the reviewed workspace state that command contains exactly:

- 23 changed production files;
- 166 zero-context hunks; and
- 166 unique `File + NewLineOrContext` keys.

Test files, test support, OpenSpec records, untracked files, and line-ending-only
status noise are not part of this population. `runtime-change-map.md` and the
linked OpenSpecs now use the same 166-hunk population.

Every row, including comment-only and export-visibility changes, is recorded in
`production-hunk-ownership-final.csv`. Ownership is assigned by the exact
changed behavior, not by the containing file.

## Result

| Primary owner | Hunks | Linked-change state |
| --- | ---: | --- |
| `fix-as-reference-bytecode-ownership-persistence` | 64 | Ownership includes P022, P138/P142/P149/P150/P151, P165, and P166. P165 is a layout-neutral read-only accessor on the internal `asCTypeInfo` class; the class definition remains identical across Runtime/Test module compilation, while only its regression caller is unit-test-only. P166 owns successful-GC retirement of discarded modules. The unit-tests-disabled build and final linked validation remain open. |
| `fix-as-script-class-restore-lifecycle` | 56 | Ownership is consistent; raw public/VM ownership has focused evidence, while restored-layout, StaticJIT, teardown, and full linked gates remain open. |
| `fix-as-object-last-native-calling-convention` | 34 | Ownership is consistent; ABI-shape, cleanup, persistence, and full linked verification remain open. |
| `fix-as-engine-property-default-initialization` | 1 | Ownership is consistent and the linked change is closed. |
| `refactor-as-native-sdk-regression-suite` | 2 | Ownership is consistent and closed: tasks 2.4 and 5.3 explicitly own real string-scan export visibility and direct Frontend coverage. |
| `fix-as-static-jit-debug-text-whitespace` | 1 | P019 has an exact owner/regression; fresh linked AOT evidence remains open. |
| `fix-as-switch-int-max-lowering` | 4 | P066-P069 have an exact owner/regression; fresh linked build/runtime evidence remains open. |
| `fix-as-double-int64-bytecode-execution` | 2 | Ownership is consistent and the linked change is closed: P091-P092 have exact interpreter owners passing Parameters `1/1` and Numeric `4/4`; exact generated owner `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` passes in canonical regenerated/built AOT `11/11`; complete SDK passes `674/674`; strict/planning/whitespace gates pass; the standalone coherent `-NoXGE` build succeeds with terminal `0/0` exit metadata. |
| Explicit user-authorized non-semantic terminology cleanup | 2 | P073/P074 are terminal without a behavioral root-cause owner. |
| **Total** | **166** | **No duplicate, omitted, or `Unowned` current hunk.** |

The reconciled audit supports closing task 2.6. Task 2.7 remains open because
historical red/green artifacts do not substitute for fresh final verification
inside every open linked change.

## Mixed-file review

The three main mixed ThirdParty files were classified hunk by hunk:

| File | Reference | Lifecycle | Object-last | Switch | Numeric | User-authorized non-semantic | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `as_compiler.cpp` | 20 | 7 | 2 | 4 | 0 | 2 | 35 |
| `as_context.cpp` | 9 | 15 | 11 | 0 | 2 | 0 | 37 |
| `as_restore.cpp` | 10 | 14 | 10 | 0 | 0 | 0 | 34 |

The important boundaries are:

- compiler typed `REFCPY`/`FREE` emissions belong to reference persistence;
  default destructor/member initialization/reverse destruction and return
  ownership belong to script-class lifecycle; by-value call-frame movement
  belongs to object-last/native calling; P066-P069 belong to upper-bound switch
  lowering; P073/P074 are the two explicitly authorized non-semantic rows;
- context `REFCPY`/`RefCpyV` interpreter changes belong to reference
  persistence; raw object construction/release, exception unwinding, and raw
  parameter retirement belong to script-class lifecycle; generic cleanup,
  return cleanup, and object-last argument placement belong to the calling
  change; P091/P092 belong to double-to-64-bit interpreter execution; and
- restore class layouts, default behaviors, and reconstructed object-variable
  lifetime metadata belong to script-class lifecycle; typed type operands,
  stream framing, GETOBJ `asBCTYPE_W_rW_ARG`, and generic reference persistence belong to the reference
  change; native-call pointer identity, parameter layout, and `CALLSYS`/
  `Thiscall1` translation belong to object-last calling.

## StaticJIT, Core, and ClassGenerator review

These files were not assigned as packages:

- ClassGenerator: 5/5 hunks belong to script-class lifecycle because they
  implement raw SDK allocation, dynamic type registration, balanced
  retain/release, destructor re-entry state, per-engine cleanup, and
  raw-versus-UObject construction routing.
- Core: `angelscript.cpp` has one lifecycle hunk; `angelscript.h` has two
  reference-operand format hunks; the two numeric string-scan export hunks in
  `AngelscriptEngine.cpp` are owned by
  `refactor-as-native-sdk-regression-suite`, whose tasks 2.4 and 5.3 explicitly
  require real exported scan functions and direct Frontend coverage.
- StaticJIT: 3 hunks belong to raw lifecycle release/free, 8 to reference
  operand retention/precompiled reference processing including P022, 5 to
  object-last native argument placement, and P019 to deterministic debug text.

The StaticJIT object-last rows are consistent with the linked requirement that
all supported execution paths place the object and explicit arguments according
to one ABI. The StaticJIT raw-release rows are explicitly supported by
script-class lifecycle task 3.3.2. Reference-copy StaticJIT/precompiled rows are
already acknowledged by the current runtime change map as part of the
reference-bytecode repair. P022 is its narrow test-module access dependency,
not a separate archive behavior.

## Former gaps and terminal dispositions

The 15 formerly unowned hunks now have these exact dispositions:

| Gap family | Hunks | Disposition |
| --- | ---: | --- |
| `FAngelscriptPrecompiledFunction::Process` Runtime export | 1 | P022 is supporting integration for `fix-as-reference-bytecode-ownership-persistence`; its exact regression produced the pre-export link failure and calls production `Process`. |
| StaticJIT debug-string trailing-whitespace trimming | 1 | P019 belongs to `fix-as-static-jit-debug-text-whitespace`. |
| Switch range arithmetic and dense iteration at `INT_MAX` | 4 | P066-P069 belong to `fix-as-switch-int-max-lowering`. |
| `dTOi64` / `dTOu64` interpreter decoding | 2 | P091-P092 belong to `fix-as-double-int64-bytecode-execution`; no save/load hunk is included. |
| GETOBJ/reference reader/writer contract | 5 | P138/P142/P149/P150/P151 belong to `fix-as-reference-bytecode-ownership-persistence`; uppercase `W_rW_ARG` is distinct from the numeric format. |
| Compiler terminology cleanup | 2 | P073/P074 are explicitly user-authorized, non-semantic, terminal, and intentionally have no behavioral root-cause owner. |
| **Total** | **15** | **13 exact linked ownership rows plus two terminal non-semantic rows.** |

No semantic hunk was forced into a nearby owner merely because it shares a
file. The GETOBJ restore rows were reassigned only after opcode metadata,
interpreter/StaticJIT operand use, and the active reference-persistence design
proved the exact contract.

## Linked-change consistency

- Reference persistence owns only type/function operand lifetime, optimizer
  symmetry, module reference remapping, interpreter/StaticJIT reference-copy
  execution, stream framing, and stable type-operand translation. Native-call
  placement and call-specific function identity are left to the calling
  change.
- Script-class lifecycle owns only class special members, member/base ordering,
  raw allocation and registry containment, public/VM compatible ownership,
  exceptional cleanup, restored property/layout reconstruction, and associated
  object-lifetime metadata.
- Object-last calling owns call preparation, by-value argument movement,
  generic/native cleanup, return storage cleanup, object-last placement in the
  interpreter and StaticJIT, and call-specific save/load pointer identity.
- Engine-property defaults owns exactly the single
  `ep.typeCheckSwitchEnums = false` constructor hunk.
- StaticJIT debug text owns only P019's terminal whitespace normalization.
- Upper-bound switch lowering owns only P066-P069's overflow-safe compiler
  intermediates.
- Double-to-64-bit execution owns only P091/P092's interpreter decoding; it
  does not own GETOBJ/reference serialization. Its interpreter owners pass
  Parameters `1/1` and Numeric `4/4`; exact generated StaticJIT
  `dTOi64`/`dTOu64` owner
  `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter`
  passes in canonical AOT `11/11`, and the complete SDK prefix passes
  `674/674`. This evidence does not cover NativeCore, the whole-project
  full-suite, Disabled tests, obj-last, or counted-reference StaticJIT
  products.

Those file/behavior assignments agree with the linked proposals, designs,
specifications, and task boundaries. Open linked changes still require their
fresh final verification checklists.

## Verification and constraints

The final accounting must satisfy all of the following:

- current diff file count = 23;
- current diff hunk count = 166;
- CSV data rows = 166;
- unique CSV `HunkId` values = 166;
- unique CSV `File + NewLineOrContext` keys = 166;
- current diff keys missing from CSV = 0;
- CSV keys absent from the current diff = 0; and
- terminal disposition counts sum to 166;
- `Unowned` rows = 0; and
- semantic hunks owned only by the coverage change = 0.

This reconciliation changed OpenSpec/handoff records only. No production
source, test source, or catalog was changed, and no build or automation was
run.
