# Readable generated layout and metadata refinement

## Why this refinement was added

The strict one-AS-module-per-profile translation-unit rule was already correct,
but its first physical layout was difficult to inspect:

```text
Generated/Profiles/EditorDevelopment/Modules/
363ba981d7c3e864c636826dc571c5d7e306f994e52ec1db353151967b367751.EditorDevelopment.jit.cpp
```

The full module key was safe as identity but hid the corresponding `.as` file,
discarded the source directory shape, and made generated diffs unnecessarily
hard to review. Full function symbols such as
`ASJIT_<full-function-key>_<full-execution-hash>_ParmsEntry` are intentionally
unchanged: they are linkage identity, not the human navigation surface.

## Current layout and identity split

The project output is now deliberately rooted directly in the UE module, with
no `Private` wrapper:

```text
Source/AngelscriptJIT/
├── AngelscriptJIT.Build.cs
├── AngelscriptJITModule.cpp
└── Generated/
    ├── Provider.generated.h
    ├── Provider.generated.cpp
    ├── EditorDevelopment/
    │   ├── Provider.generated.h
    │   ├── Provider.generated.inl
    │   ├── ProviderManifest.generated.json
    │   ├── OwnedFiles.generated.json
    │   ├── Tests/Test_Handles.07a7af43.EditorDevelopment.jit.cpp
    │   └── Examples/Core/Example_Math.7fca3709.EditorDevelopment.jit.cpp
    ├── GameDevelopment/
    └── GameShipping/
```

The fixed plugin test carrier uses the same convention:

```text
Plugins/Angelscript/Source/AngelscriptTestJIT/
├── AngelscriptTestJIT.Build.cs
├── AngelscriptTestJITModule.cpp
├── AngelscriptTestJITProbes.cpp
├── AngelscriptTestJITProbes.h
└── Generated/EditorDevelopment/...
```

The probe header is physically root-level as well. `AngelscriptTest` adds only
that sibling module root to its private include search path and keeps the
`AngelscriptTestJIT` dependency private. The `ANGELSCRIPTTESTJIT_API` macro,
not a `Public` folder name, supplies the required DLL import/export annotation.

The responsibilities are deliberately separated:

- directory and source stem are human navigation;
- the short StableModuleKey prefix disambiguates same-named sources;
- the profile suffix protects UBT's flattened intermediate-object basenames;
- the complete StableModuleKey remains in the module header and manifest;
- complete StableFunctionKey and ExecutionHash remain in every internal C++
  symbol.

The short key starts at 8 hexadecimal characters. All generated module
basenames are compared case-insensitively across the complete provider output.
On collision the conflicting basenames extend in deterministic four-character
steps (12, 16, and so on) until unique. Directory differences alone are not
accepted as collision resolution because UBT may flatten basenames.

Virtual source mapping is deterministic:

| Virtual source domain | Profile-relative generated domain |
|---|---|
| `/Angelscript/Game/<path>` | `<path>` |
| `/Angelscript/Plugin/<Name>/<path>` | `Plugin/<Name>/<path>` |
| memory-backed module | `Memory/<Provider>/<path>` |

## Metadata contract

The ownership marker remains the first line:

```cpp
// @angelscript-jit-owned revision=2 kind=module-source
```

It is followed by a deterministic module block containing virtual source path,
canonical module name, target profile, complete StableModuleKey, ProviderId,
artifact profile, native environment, and function count. There are no
timestamps, absolute machine paths, or self-hashes.

Every function has a deterministic block containing canonical AS declaration,
virtual source line/column, complete StableFunctionKey, ExecutionHash,
DebugHash, and EntryAbiHash. Every emitted Raw, VM, and Parms entry also has an
immediately preceding three-line comment with AS declaration, source, and entry
kind. This makes a long symbol locally understandable without weakening its
identity.

Manifest schema is now revision 3. Ownership marker/inventory remains revision
2 and Provider ABI remains revision 2 because neither owned-file trust nor the
runtime view layout changed.

## Progressive issue: compiler-synthesized functions had no source line

The first real TestJIT Generate failed with:

```text
Generated function 3 has an incomplete stable identity:
Declaration='UStaticJITAotVirtualChild UStaticJITAotVirtualChild()'
Source='/Angelscript/Game/ASStaticJITAotFixture.as' Line=0 Column=0.
```

Evidence tracing showed this is an AngelScript-generated default constructor.
This fork's `as_builder.cpp` still deliberately passes `declaredAt=0` for
generated default constructors/factories/init-defaults/destructors, and the
ordinary script type also does not provide a usable `asCTypeInfo::declaredAt`.
Inventing line 1 or weakening all line validation would make navigation
misleading.

The resolved source hierarchy is:

1. function `scriptData->declaredAt`;
2. declaring/returned type `declaredAt` when available;
3. authoritative `FAngelscriptClassDesc::LineNumber` retained by the UE
   preprocessor for compiler-synthesized class functions;
4. first bytecode debug line as the final fallback.

The generated default constructor now points to the actual class declaration
line and uses column `0` to state that only line precision is available. This
changes comments/manifest metadata only; generated code and symbols are
unchanged.

## Progressive issue: old and new roots cannot share ordinary publication

The normal generated-file store compares one output root. The old
`Generated/Profiles/<Profile>` and new `Generated/<Profile>` roots are siblings,
so ordinary publication could write the new output but could not prove that
deleting the old root was safe.

The migration therefore has an explicit cross-root inspection/retirement
contract:

1. Verify inspects legacy output read-only and reports it stale or invalid.
2. Generate preflights the revision-2 inventory, profile, ProviderId, inventory
   self-membership, and every existing listed file's revision-2 marker before
   publishing anything.
3. Generate publishes the new root atomically.
4. It revalidates and removes only inventory-listed old files, inventory last.
5. It removes only empty directories non-recursively; user files preserve their
   containing legacy directories.
6. Any invalid inventory or user-replaced listed file blocks migration and is
   preserved. Live Coding is not used because the UBT source set changed.

If retirement fails after the new root has published, both roots may remain so
the operation is recoverable and rerunnable; no unowned data is deleted.

## Progressive refinement: remove both Private wrappers

The next readability pass removes `Private` from both generated-code carrier
modules, not only from the host project. For these two modules `Private` does
not describe an API boundary: project `AngelscriptJIT` is an owned carrier,
while `AngelscriptTestJIT` exposes one DLL-annotated probe header only to its
private test-module consumer. A `Public` wrapper for that single internal test
header is unnecessary as well. Keeping multiple physical conventions would
add path and tooling complexity without providing encapsulation.

The current roots are therefore `Source/AngelscriptJIT/Generated` and
`Plugins/Angelscript/Source/AngelscriptTestJIT/Generated`. The immediately
preceding `Private/Generated/<Profile>` layout and the older
`Private/Generated/Profiles/<Profile>` layout are both legacy inputs. Verify
detects them read-only. Generate validates revision-2 ownership before retiring
inventory-listed generated files. Project Scaffold validates scaffold ownership
before retiring its old module entry and selector files. Empty directories are
removed non-recursively; an unowned file preserves its directory and blocks an
unsafe migration. Checked-in TestJIT implementation `.cpp` files are normal
repository moves, not generator-owned deletions.

Alternatives considered were (1) moving only `Generated` while retaining the
manual entry `.cpp` files under `Private`, and (2) flattening only the project
carrier. The selected approach flattens both because it is the only one that
leaves a single path convention with no semantically meaningless wrapper.

## Real generation evidence

- TestJIT Generate after the synthesized-line fix: exit `0`,
  `Saved/StaticJIT/TestJIT/Commandlet/staticjit-readable-layout-testjit-generate-preprocessor/20260813_185232_149_d1aa16d5`.
- TestJIT generated-source build: exit `0`, including compile actions for
  `ASStaticJITAotFixture.c8f22911.EditorDevelopment.jit.cpp` and
  `ASStaticJITAotImportProvider.363ba981.EditorDevelopment.jit.cpp`,
  `Saved/Build/staticjit-readable-layout-testjit-generated/20260813_185501_526_45c67a3c`.
- Project Scaffold: exit `0`,
  `Saved/AngelscriptJITRuns/staticjit-readable-layout-scaffold/20260813_190007_262_fec79eac`.
- Project Generate All: exit `0`, produced 9 EditorDevelopment, 8
  GameDevelopment, and 8 GameShipping module sources with no remaining
  `Generated/Profiles`,
  `Saved/AngelscriptJITRuns/staticjit-readable-layout-generate-all/20260813_190054_942_b5cae415`.
- Project generated-source build: exit `0`; UBT compiled all 25 readable
  `.jit.cpp` inputs,
  `Saved/Build/staticjit-readable-layout-project-generated/20260813_190248_158_322a8251`.

Final focused Verify/test/tool reports are recorded in `verification.md` after
the closing matrix completes.

## No-Private implementation closure

The final pass exercised both legacy forms instead of treating the change as a
manual repository move. Project Scaffold preflights the exact revision-2 fixed
files, publishes the root module/selector files, retires only validated old
files, and removes only empty wrappers. Per-profile Generate separately
preflights both `Private/Generated/<Profile>` and
`Private/Generated/Profiles/<Profile>` before any current-root publication.
TestJIT uses the equivalent two-root inventory migration and keeps the probe
header root-level through an `AngelscriptTest` private include path.

The real checkout now has all three properties simultaneously:

- `Source/AngelscriptJIT/Private` is absent;
- `Plugins/Angelscript/Source/AngelscriptTestJIT/Private` is absent;
- `Plugins/Angelscript/Source/AngelscriptTestJIT/Public` is absent.

Every generated module source retains the revision-2 owner marker, the readable
module metadata block (virtual source, canonical name, full StableModuleKey,
ProviderId, profile/environment hashes, function count), and per-function
declaration/source/key/hash metadata. Only physical carrier layout changed;
stable keys and content-addressed C++ symbols were not shortened.

The long AOT closure was inspected while running rather than assumed hung. Its
log showed repeated full Engine creation, a 45.159-second UE DerivedDataCache
maintenance pass, Cache V2 compile/restore, and a second Engine whose class
layout step took 14.032 seconds. The Editor process remained responsive and its
CPU usage and log length continued to increase. The complete AOT prefix then
passed 20/20. This timing is diagnostic evidence, not a performance threshold.
