## Context

The core runtime currently exposes the upstream-derived AngelScript 2.33 numeric and text values as its public version. That value participates in `asCreateScriptEngine()` compatibility checks, while the UE descriptor independently reports `1.0`. Planned standalone packaging also needs a stable product version. A single owned version contract must therefore span public headers, runtime queries, the core plugin descriptor, tests, and release evidence without making UE a dependency of the standalone runtime.

## Goals / Non-Goals

**Goals:**

- Make `Unreal AngelScript 1.0.0` the authoritative core product identity.
- Intentionally reject callers passing the legacy upstream `23300` value.
- Define and test a reusable SemVer compatibility algorithm.
- Keep upstream provenance queryable without presenting it as the product version.
- Give UE and standalone release workflows a non-mutating consistency check.

**Non-Goals:**

- Do not preserve header compatibility with the old `23300` identity.
- Do not change bytecode, serialization, language, binding, debugger, or module behavior.
- Do not rename plugin directories, Unreal modules, config keys, or automation prefixes.
- Do not force optional extension plugins to use the core version.
- Do not implement the not-yet-landed standalone executable in this change.

## Decisions

### 1. Use a UE-independent public version header

`Core/UnrealAngelscriptVersion.h` owns product, numeric, and lineage constants plus pure `constexpr` encoding and compatibility functions. `angelscript.h`, the UE module, and future standalone CMake targets can consume it without generated files or UE types.

A JSON authority was rejected because it would require generated public C++ headers. Keeping all values directly in `angelscript.h` was rejected because it would continue mixing product identity, upstream API declarations, and release metadata.

### 2. Preserve legacy macro names but replace their meaning

Existing source continues to compile with `ANGELSCRIPT_VERSION` and `ANGELSCRIPT_VERSION_STRING`, but those macros alias the owned version. The numeric value becomes `10000`, and the string becomes `Unreal AngelScript 1.0.0`. This is an intentional compatibility break at engine creation, not an API spelling migration.

### 3. Use SemVer-compatible engine creation

The encoding is `major * 10000 + minor * 100 + patch`. Compatibility requires non-zero versions, equal major components, and `requested <= available`. This permits an older 1.x header to connect to a later compatible 1.x runtime and rejects a newer header against an older runtime. Breaking ABI changes require the next major.

### 4. Separate current identity from source lineage

`asGetLibraryVersion()` reports the product version. A new `asGetLibraryUpstreamVersion()` query reports `AngelScript 2.33.0 WIP lineage + selective 2.38 backports`. The normal product string does not append lineage because consumers must be able to treat it as a stable release identity.

### 5. Duplicate descriptor fields with enforced validation

Unreal's `.uplugin` format cannot include a C++ header, so `Version`, `VersionName`, and `FriendlyName` are necessarily duplicated. A plugin-owned PowerShell validator parses both sources, checks the encoding and exact strings, performs no writes, and returns non-zero on drift. Future standalone packaging and GitHub release automation consume the same header and invoke the validator.

### 6. Batch compilation after the code phase

Tests are authored before production behavior, but the expensive UE compile is delayed until the complete code batch is written. Static/OpenSpec checks may run earlier. One focused build is followed by focused runtime tests, NativeCore, and the full suite.

## Risks / Trade-offs

- **[Existing external callers pass 23300]** → The hard failure is intentional; document that callers must build against this fork's header and cover the rejection in regression tests.
- **[SemVer promise is violated by a future 1.x ABI break]** → Record the rule in the public header/spec and require a major bump for breaking changes.
- **[Descriptor and header drift]** → Fail the read-only validation script and release gate with field-level diagnostics.
- **[2.33 provenance is accidentally removed]** → Preserve it in dedicated lineage constants, the new query, fork documentation, and source audit records.
- **[Technical history is mistaken for current identity]** → Require public product text to use `Unreal AngelScript 1.0.0` and classify remaining 2.33 references.

## Migration Plan

1. Add the tests and canonical version header/API changes in one source batch.
2. Update the core descriptor and add the consistency validator.
3. Replace obsolete current-version assertions and update Chinese-first documentation.
4. Build once, fix compilation as a batch, then run focused and broad regressions.
5. Commit the plugin submodule first, then parent OpenSpec/docs and the gitlink.

Rollback requires reverting both the plugin commit and parent gitlink/OpenSpec commit. Partial rollback is unsupported because mixing the old header with the new runtime or descriptor would recreate the identity mismatch.

## Open Questions

None. Product name, initial version, hard-cut behavior, SemVer policy, delivery scope, and lineage text are approved.
