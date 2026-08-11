## Why

Math functions currently reach Angelscript through three competing namespace sources: the manual `Bind_FMath` compatibility switch, `UAngelscriptMathLibrary`'s `ScriptName="Math"`, and `UKismetMathLibrary`'s `ScriptName="MathLibrary"`. The resulting `Math::`, `MathLibrary::`, and optional `FMath::` spellings make the public API non-canonical and add avoidable ambiguity to completion, generated documentation, offline bundles, and AI-authored script.

## What Changes

- **BREAKING**: Make `FMath::` the only default public namespace for manual FMath globals, non-mixin `UAngelscriptMathLibrary` functions, and non-mixin `UKismetMathLibrary` static functions.
- **BREAKING**: Remove support for the legacy `Math::` and `MathLibrary::` spellings. They are not registered as public aliases and receive no hidden compiler redirect.
- Add restart-required project settings that map a Blueprint/function-library class by stable Unreal class path to one canonical Angelscript namespace. Ship exact default mappings for `/Script/Engine.KismetMathLibrary` and `/Script/AngelscriptRuntime.AngelscriptMathLibrary` to `FMath`.
- Preserve `ScriptMethod`/mixin placement on receiver types such as `FVector`, `FRotator`, `FQuat`, and `FTransform`; canonical library mapping applies only when a reflected static function remains a namespace function.
- Preserve full registered AS type names as the fallback for unmapped Blueprint libraries. Do not restore broad prefix/suffix trimming or class-`ScriptName` substitution for ordinary Blueprint libraries.
- Remove the one-off `EAngelscriptMathNamespace` / `MathNamespace` compatibility setting and the editor-only mutation of `UAngelscriptMathLibrary` metadata.
- Define deterministic validation for invalid mappings, conflicting duplicate class mappings, and declaration collisions when multiple libraries intentionally converge on one namespace.
- Ensure runtime reflection, manual bindings, state/API export, editor code generation, Standalone offline bundles, Static JIT, tests, examples, and AI-facing inventories expose only the resolved canonical spelling.

## Capabilities

### New Capabilities

- `as-library-namespace-canonicalization`: Defines stable class-path namespace mappings, default `FMath` aggregation, strict single-name visibility, validation, and collision behavior.

### Modified Capabilities

- `as-library-full-namespaces`: Changes the unconditional full-type-name rule into a canonical-mapping-first rule with full registered AS type names as the fallback, while continuing to prohibit heuristic prefix/suffix shortening.

## Impact

- Runtime settings and binding policy in `AngelscriptRuntime/Core`, `AngelscriptRuntime/Binds`, and `AngelscriptRuntime/FunctionLibraries`.
- The public script API is intentionally breaking for every active `.as` source that calls `Math::` or `MathLibrary::`; those calls migrate to `FMath::`.
- Function-library signature/contract tests, Math binding and coverage tests, Static JIT coverage, examples, current guides, and repository-owned script fixtures.
- Observer surfaces that consume the initialized AS engine, including dump/export, editor CodeGen/VSCode data, and Standalone offline bundles, must see one canonical namespace without adding observer-specific rewrite rules.
- The active `improve-as-runtime-function-libraries` change currently records `Math::` behavior and touches overlapping function-library signature files; implementation must reconcile or sequence that work rather than allowing the two records to preserve contradictory names.
- No new runtime dependency and no Unreal Engine source modification are required.
