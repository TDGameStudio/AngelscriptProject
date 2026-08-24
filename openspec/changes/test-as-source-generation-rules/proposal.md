# Why

The repository already contains three useful but disconnected sources of AngelScript test input: reviewed hand-written files under `TestSource`, hundreds of C++ tests that embed AS literals, and 271 Native SDK products whose C++ helpers mechanically assemble 45,760 matrix cells. The existing Python `Tools/AngelscriptCodeGen` experiment proves deterministic source production is feasible, but its executable model is still mostly one no-argument `int` function with `int`/`bool` expressions and statements; UE definitions are largely fixed profile fragments, and the catalog records compile intent rather than complete typed observations. That depth is insufficient for the current test surface, especially return values, out/inout writeback, metadata, diagnostics, lifecycle, cleanup, isolation, and save/load behavior.

The project therefore needs a reviewed source-generation contract before any current test is replaced. The contract must separate exhaustive coverage axes from controlled random variation, support both authored and generated source through one value model, produce byte-identical results from independent Python and portable C++ implementations, and let the Unreal plugin retain only a generated C++ release mirror.

# What Changes

- Define a language-neutral, versioned request/result/recipe contract under the future `TestSource/Generation` ownership boundary.
- Define exhaustive product enumeration followed by controlled, reproducible variation using `SplitMix64-v1`, UTF-8 FNV-1a CaseKey hashing, rejection sampling, deterministic Fisher-Yates, and named random substreams.
- Expand the planned generator surface beyond shallow definitions to declarations, functions, parameter directions and positions, expressions, statements, UE annotated types, reflected properties/functions, containers, frontend/compiler/runtime/module/type-system cases, structural negative mutations, recovery source, and complete typed oracles.
- Require independent Python and standard-C++ implementations under the future `Tools/AngelscriptCodeGen` tree to emit byte-identical UTF-8 AS source and canonical manifests.
- Unify authored `TestSource` export and rule-generated products behind generated plugin class `FAngelscriptTestCode`, with one static function per fixture/product CaseKey and a generated sorted dispatch table.
- Gate every authored `TestSource` export on the reviewed `authored-case-contract-v2` row owned by `test-as-manual-bind-source-coverage`. Legacy authored rules and semicolon-packed `plannedSymbols` are migration evidence only; they cannot supply or infer declarations, entry points, arguments, writebacks, exception oracles, comments, or pass status.
- Keep only generated `.h`/`.cpp` release artifacts in `Plugins/Angelscript`; do not ship Python, rule JSON, generation-time `.as` files, or registration side effects in the plugin.
- Preserve the existing exact planning inventory for its 614 legacy manual-bind authored-export candidates, 271 Native SDK generated products, all 1,022 current Coverage `TEST_METHOD`s, and all current inline AS source units. The 614-row catalog is a downstream subset and is not the 3,041-source denominator owned by `test-as-manual-bind-source-coverage`.
- Produce an execution-ready `tasks.md` whose entries name files, reference points, AS scope, axes, oracles, random/frozen boundaries, impact, tests, verification, requirements, and dependencies.
- Preserve all current builders, inline literals, and test drivers. This change defines and may later implement additive rules/release outputs, but it does not adopt, replace, delete, or relocate existing tests.

# Capabilities

## New Capabilities

- `as-test-source-generation-rules`: Versioned source-generation recipes, exhaustive axes, controlled randomness, complete typed oracles, structural negative generation, knowledge comments, canonical output, and Python/C++ parity.
- `as-test-code-static-release`: Generated `FAngelscriptTestCode` static functions and dispatch metadata that expose authored and generated cases while keeping only final C++ release artifacts in the plugin.
- `as-test-source-generation-inventory`: Reproducible inventories and disposition records that map every in-scope authored fixture, SDK product, Coverage method, and current inline AS unit to concrete future work without test adoption.

## Modified Capabilities

None. Existing OpenSpecs and runtime/test capabilities remain unchanged until a later explicit adoption change modifies their requirements.

# Impact

- Future shared rule/schema/golden ownership: `TestSource/Generation/**`.
- Future independent implementations and parity tooling: `Tools/AngelscriptCodeGen/**`.
- Future generated release mirror only: `Plugins/Angelscript/Source/AngelscriptTest/Generated/TestCode/**` plus the generated public value/API declaration.
- Planning evidence and validation scripts in this change: `openspec/changes/test-as-source-generation-rules/**`.
- Cross-change authored-export dependency: user-accepted normalized plan rows followed by reviewed `TestSource/Generation/Contracts/**` rows produced by `test-as-manual-bind-source-coverage`; source generation does not mutate either record.
- Current main-workspace creation pass: OpenSpec files only. It does not edit `TestSource`, `Tools`, any plugin/submodule file, any current test, or any other OpenSpec change.
- Compatibility: additive only. Existing source builders and automation names remain the execution authority.
