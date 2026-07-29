# Background and Decision Record

## Current State

Before this change, the runtime's only public version authority lived in `Core/angelscript.h`:

- `ANGELSCRIPT_VERSION` was `23300`.
- `ANGELSCRIPT_VERSION_STRING` was `2.33.0 WIP`.
- `asGetLibraryVersion()` returned that upstream-derived string.
- `asCreateScriptEngine()` required equal major and minor components and allowed only an older-or-equal requested patch.
- `Angelscript.uplugin` independently declared integer version `1` and display version `1.0`.

The numeric macro is not merely documentation: it is passed by headers into `asCreateScriptEngine()` and therefore controls header/library compatibility. Existing tests also pinned `23300` and `2.33.0 WIP` as the current runtime identity.

The fork is not vanilla AngelScript 2.33. It contains UE-owned memory, object lifetime, type metadata, APV2 module storage, bytecode restoration, binding, hot reload, debugging, editor, and selective 2.38 compatibility behavior. The existing shared identity specification already required an owned runtime identity, but left its numeric policy open.

## User Decisions

The approved product identity and version are:

```text
Unreal AngelScript 1.0.0
```

The approved compatibility and delivery decisions are:

1. Perform a hard version cut. `asCreateScriptEngine(23300)` must fail; no deprecated or transitional acceptance path is retained.
2. Use SemVer compatibility. A runtime accepts a requested version when both versions have the same major and the requested encoded version is not newer.
3. Use one version for the core UE plugin, embedded runtime, future standalone CLI/package, and GitHub release.
4. Keep the optional `AngelscriptGameplayTags` and `AngelscriptGAS` plugin versions independent.
5. Keep upstream provenance visible only as separate lineage metadata.

## Encoding

The public integer encoding remains compatible with the existing AngelScript-shaped field width:

```text
major * 10000 + minor * 100 + patch
```

The current encoded version is therefore `10000`. Minor and patch components are constrained to `0..99`. A breaking public C API or ABI change requires a major-version increment.

For available runtime `A` and requested header `R`, compatibility is:

```text
R > 0
major(R) == major(A)
R <= A
```

At runtime 1.0.0:

- `10000` succeeds.
- `10001`, `10100`, `20000`, `23300`, and `0` fail.

The pure compatibility function is also tested with synthetic later 1.x available versions so that backward-compatible minor and patch behavior is fixed before the first upgrade.

## Public Identity and Lineage

Normal version reporting returns `Unreal AngelScript 1.0.0` (with ` DEBUG` appended in debug builds). A separate query returns:

```text
AngelScript 2.33.0 WIP lineage + selective 2.38 backports
```

The 2.33 value remains only in source-provenance constants, technical documentation, historical evidence, and the regression proving that the old header version is rejected. It is not the current product version.

## Impact Boundaries

Changed:

- Public header version macros and version compatibility behavior.
- Runtime version and lineage query strings.
- Core plugin descriptor identity/version.
- Native SDK version regression coverage.
- Release validation and documentation.

Unchanged:

- Bytecode and restore layout.
- Script language semantics.
- Runtime module and plugin directory names.
- Unreal config keys and generated asset paths.
- Debug protocol and schema versions.
- Automation test prefixes.
- Optional plugin versions.
- Upstream source audit history.

## Execution Discipline

The implementation writes the complete test and production code batch before invoking the expensive UE build. Static parsing, OpenSpec validation, and the plugin-owned version validator may run before that build. After compilation succeeds, focused tests run first, followed by NativeCore and the full plugin suite. Every build or test issue is recorded in `issues.md`; fresh evidence is recorded in `verification.md`.
