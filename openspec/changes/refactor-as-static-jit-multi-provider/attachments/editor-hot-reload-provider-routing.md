# Editor Hot-Reload Provider Route Refresh

## Scope

This note records the Cache V2/current-route gap found while implementing task
group 8. It is deliberately limited to authoritative Editor hot reload. Live
Coding generation/patching remains task group 9, and packaged immutable-set
behavior remains task group 10.

## Observed gap

Initial startup already performed the intended sequence:

1. preprocess and compile/restore authoritative AS modules;
2. publish the current Engine's verified stable-function route snapshot;
3. match copied Provider catalogs;
4. resolve Engine-local stable references;
5. attach complete VM/Raw/Parms/UserData bindings;
6. republish the route snapshot with Native/VM selections.

The production hot-reload sequence stopped after step 2. `CompileModules()`
correctly froze the new Cache V2 publication, swapped accepted modules,
discarded the old module, and rebuilt the current-function route snapshot, but
`PerformHotReload()` did not invoke `FAngelscriptJITProviderRouter::Refresh()`.

This did not normally call an old Native pointer: the old script functions and
their bindings were retired with the discarded module. The observable defect
was instead that every replacement function remained on VM, including
unchanged functions whose new current identity still exactly matched the
loaded Provider. In other words, Cache V2/current routes were correct, but the
consumer step was missing at the successful hot-reload transaction boundary.

## RED evidence

`AngelscriptJITEditorRoutingTests.cpp` creates a real Editor-configured
`FAngelscriptEngine`, compiles one disk-backed AS module with two global
functions, builds and registers one exact synthetic Provider from the current
verified routes, and publishes Native bindings for both functions. It then
changes only one function body and uses the public
`ForceCleanAngelscriptCache()` path, which goes through the normal queued
full-hot-reload transaction.

Before the fix, the changed function correctly became VM, but the unchanged
replacement also remained VM:

```text
Saved/Tests/staticjit-editor-routing-red/
  20260813_062258_168_4bebc14b/Report
Totals: total=1 passed=0 failed=1 skipped=0
Failure: expected UnchangedValue Native, observed VM
```

An earlier compile-only test correction is retained separately and is not
claimed as behavioral RED:

```text
Saved/Build/staticjit-editor-routing-red-build/
  20260813_062206_833_7d6d5007
```

## Safe-point fix

`FAngelscriptEngine::PerformHotReload()` now refreshes Provider routing only
after `CompileModules()` has returned a successful result.

That location is intentional:

- the Cache V2 compile mutation guard is already released, so route refresh can
  acquire its own `RouteRefresh` mutation token;
- the accepted module swap, ClassGenerator/reinstancing decision, old-module
  retirement, Cache V2 publication, and authoritative current-function route
  snapshot are complete;
- post-compile class/test/debug consumers have not yet been notified;
- `Error` and `ErrorNeedFullReload` return before the refresh, so a failed
  compile cannot alter the last-good route or binding publication.

The router remains function-granular. A body edit preserves the stable
function key but changes the Execution hash, producing `ContentMismatch` and
VM for that function. An unchanged function is rebound to the Provider entry
owned by its newly compiled current function. Debug-only identity changes do
not reject ordinary reloadable entries because they do not carry
`RequireExactDebugIdentity`. Signature changes create a different stable key;
deleted functions have no current route and therefore cannot be selected.

## GREEN matrix

The focused implementation build passed:

```text
Saved/Build/staticjit-editor-routing-green-build/
  20260813_062418_361_750ac90d
```

The first fixed route test passed and emitted the expected typed distribution:

```text
Saved/Tests/staticjit-editor-routing-green-tests/
  20260813_062441_130_853b182d/Report
StaticJIT Provider routing: verified=2 exact=1 native=1 vm=1
matchResults=[Exact:1, ContentMismatch:1]
Totals: total=1 passed=1 failed=0 skipped=0
```

The expanded Editor matrix passed 4/4:

```text
Saved/Tests/staticjit-editor-routing-matrix-tests/
  20260813_062748_110_d95a1f73/Report
```

It proves:

- body-only edit: changed function VM, unrelated unchanged function Native;
- whitespace/debug-site-only edit: stable key and Execution identity unchanged,
  Debug identity changed, both functions rebound Native;
- failed compilation: the exact last-good route snapshot pointer and Native
  binding remain unchanged;
- signature change plus deletion: the new signature has a different stable key
  and remains VM, the deleted stable key disappears completely, and the
  unrelated function is rebound Native.

Adjacent regressions also pass:

```text
Saved/Tests/staticjit-editor-uas-current-binding-green/
  20260813_062908_354_96c9094f/Report
Totals: total=1 passed=1 failed=0 skipped=0

Saved/Tests/staticjit-editor-cache-route-green/
  20260813_063003_016_25ffca3b/Report
Totals: total=5 passed=5 failed=0 skipped=0
```

These preserve route generation, failed-reload last-good behavior, reordered
FunctionId identity, two-Engine isolation, and current-binding UASFunction
dispatch.

## Global functions and diagrams

The test deliberately uses module-global functions. They are first-class AS
functions and Provider entries, and Cache V2 identifies them with module
ownership plus `GlobalFunction` invocation kind. They are not required to be
moved into a script class.

A strict UML class box describes types and their members, so an ordinary
module-global function should be shown under a `<<module>>` or `<<namespace>>`
node in a class-style architecture diagram. A reflected module-level
`UFUNCTION` additionally has the existing reflection-only `StaticsClass`
container on the Unreal side; that container has a generated `UClass` surface
but no AngelScript VM object type. The Cache V2 implementation and evidence for
that distinction are recorded in
`testjit-cache-v2-and-stable-reference-emission.md`.

## Remaining group-8 work

This closes the concrete hot-reload consumer gap but does not by itself close
all of tasks 8.1-8.5. The remaining matrix still includes explicit PIE
lifecycle/isolation, reflected metadata/class-layout/inheritance/import
classification with Provider observations, broader HotReload/Cache/UASFunction
prefixes, and the final audit of the old development-mode exclusion.

## Plan corrections discovered at the safe point

Two original checklist phrases were unsafe when compared with the real compile
transaction:

1. `CompileModules()` lets ClassGenerator decide and perform soft/full class
   replacement before it freezes Cache V2 and publishes the new current route
   snapshot. Provider matching cannot safely run before ClassGenerator because
   the accepted current functions do not exist yet. The task/spec now require
   refresh after the accepted ClassGenerator generation and before
   `PostCompileClassCollection` or the first reflected dispatch consumes it.
2. `FAngelscriptStaticJIT::OnFunctionReady()` still returns early in script
   development mode, but the guarded code is precisely the superseded global
   `FJITDatabase`/numeric-FunctionId lookup. The new Engine-local Provider
   router is installed independently and is already exercised in Editor. The
   group-8 audit must therefore retain this legacy safety guard until task 10.3
   deletes the legacy database; simply removing the condition would violate
   the specification by re-enabling the old Editor attachment path.

## Automatic-import Cache V2 gap found by the expanded matrix

The first import test draft explicitly disabled the product-default automatic
import method and therefore exercised AngelScript's legacy declared-import
`CALLBND` path. That result was classified rather than papered over:

- `UAngelscriptSettings::bAutomaticImports` defaults to true and explicitly
  makes declared `import ... from ...` statements obsolete;
- the maintained default compiles cross-module calls as ordinary script
  function dependencies;
- Cache V2 clean capture and fresh restore already covered that default path;
- legacy manual imports remain outside the admitted Cache V2 restore shape:
  current capture/authority/restore reject non-empty module import tables and
  do not materialize bind-information entries.

The forced-manual diagnostic is retained as boundary evidence, not as a
failure of the current product route:

```text
Saved/Tests/staticjit-import-identity-diagnostic-exact/
  20260813_065128_446_cbd8eb65/Report
```

Adding full legacy `CALLBND` persistence would require a separately approved
Cache extension: capture stable import declarations, materialize import
signatures during restore, bind them to restored provider modules, add CALLBND
relocations/semantic dependencies, and extend restore graph ordering. Group 8
does not silently broaden into that compatibility feature.

After the Editor test was corrected to the maintained automatic-import path,
it exposed a real incremental Cache V2 bug. Initial full compile captured both
provider and consumer. A provider-body-only reload recompiled the provider and
reference-updated the unchanged consumer in place, but the capture transaction
published only the provider. Consequently the current consumer route had no
verified artifact with which the JIT Provider could match.

The hot-reload overlap has three representations that must converge on one
stable authority:

1. the unchanged consumer's compiler dependency table can retain the
   predecessor provider-function pointer;
2. its updated bytecode already names the successor provider function;
3. the accepted provider module has a temporary internal `_NEW_n`/renamed
   lifecycle, while `asCModule::baseModuleName` remains the semantic module
   name.

The fix therefore:

- resolves a predecessor provider module to the accepted current descriptor by
  `baseModuleName`, never by a temporary internal module name;
- rebuilds the predecessor function's stable FunctionKey under that current
  module key and requires an exact current declaration match, so signature or
  owner changes still fail closed;
- maps both predecessor and successor transient function pointers to the same
  stable ScriptFunction reference, ABI, and current execution-content hash for
  the duration of capture only;
- makes the detached function-artifact reader ignore a module whose
  `ReloadNewModule` identifies it as a hot-reload predecessor, while preserving
  ambiguity rejection for every other same-name overlap;
- preserves detailed bounded reader diagnostics in the global-function capture
  error path.

No VM pointer, FunctionId, `_NEW_n` name, predecessor pointer, or successor
pointer is persisted. The published dependency remains only the stable
FunctionKey, expected ABI, and semantic content authority.

## Progressive RED/GREEN evidence for the Cache repair

The automatic-import Editor RED first showed that the unchanged caller did not
enter the refreshed Provider route set:

```text
Saved/Tests/staticjit-auto-import-editor-exact/
  20260813_070001_526_7f1c3113/Report
Totals: total=1 passed=0 failed=1 skipped=0
Cache capture: Candidates=2 Captured=1 Skipped=1
```

A dedicated Cache-layer regression was then added. Progressive failures
confirmed each boundary instead of weakening validation:

```text
# Predecessor module was outside current authority
Saved/Tests/cache-cross-module-successor-authority-green/
  20260813_070806_529_cd8f238e/Report

# baseModuleName resolved authority; detached reader rejected predecessor/current overlap
Saved/Tests/cache-cross-module-base-name-green/
  20260813_070949_918_1c8e5c06/Report

# reader selected current module; bytecode successor pointer lacked the old-pointer alias
Saved/Tests/cache-artifact-current-successor-green/
  20260813_071437_214_76f37b0f/Report
```

The focused Cache test is now green and publishes both modules after the
provider-only reload:

```text
Saved/Tests/cache-cross-module-dual-alias-green/
  20260813_071609_320_06e0f7b2/Report
Totals: total=1 passed=1 failed=0 skipped=0
Cache capture after reload: Candidates=2 Captured=2 Skipped=0
```

It asserts that the provider FunctionKey is stable while its Execution hash
changes, and that the unchanged consumer FunctionKey, Execution hash, and Debug
hash all remain stable. The Editor end-to-end proof then observes the intended
function-granular result:

```text
Saved/Tests/staticjit-auto-import-after-cache-fix/
  20260813_071712_263_c2989951/Report
Totals: total=1 passed=1 failed=0 skipped=0
Provider: ContentMismatch -> VM
Consumer: Exact -> Native
```

The complete focused matrices pass:

```text
Saved/Tests/staticjit-editor-routing-cache-fix-matrix/
  20260813_071811_095_2ec29d57/Report
Totals: total=8 passed=8 failed=0 skipped=0

Saved/Tests/cache-multi-module-successor-regression/
  20260813_071941_141_23e816c5/Report
Totals: total=5 passed=5 failed=0 skipped=0
```

The eight Editor tests now cover body-only, debug-only, failed compile,
signature/delete, structural layout plus inheritance and reflected metadata,
automatic cross-module import, ambiguous exact Providers, and a real PIE
reflected dispatch. The structural test observes the new class layout first,
then verifies that changed functions are VM and stable exact functions are
Native before post-compile consumers run.

## Group-8 closure

The final adjacent regressions are green:

```text
Saved/Tests/staticjit-editor-uasfunction-after-cache-fix/
  20260813_072157_635_7fee05e8/Report
Totals: total=3 passed=3 failed=0 skipped=0

Saved/Tests/staticjit-editor-hotreload-after-cache-fix/
  20260813_072302_759_c6c883e7/Report
Totals: total=122 passed=122 failed=0 skipped=0
```

The old script-development-mode guard was also audited at its exact call site.
`FAngelscriptStaticJIT::OnFunctionReady()` uses that guard only before looking
up `FJITDatabase::Functions` by process-local numeric FunctionId and installing
the legacy binding. Provider routing is not nested under the guard: each
`FAngelscriptEngine` installs its own lifecycle adapter, and Editor startup plus
successful `PerformHotReload()` independently invoke the Provider router.
Therefore the safe group-8 result is to retain the guard until task 10.3 removes
the entire legacy database path. Removing it now would revive the unsafe path
that this change is replacing.

Tasks 8.1-8.5 are closed. Automatic generation and Live Coding patch validation
are deliberately still owned by group 9.
