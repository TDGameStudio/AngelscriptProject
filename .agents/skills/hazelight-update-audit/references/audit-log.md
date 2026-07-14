# Hazelight Update Audit Log

## 2026-05-13 - Recent upstream trial audit

- Repo: `Hazelight/UnrealEngine-Angelscript`
- Branch: `angelscript-master`
- Upstream HEAD reviewed: `472bb2fab5a0bc76d0a86a1dd80750a4118b8418`
- Listed window: 20 recent commits, from `472bb2fab5a0` back to `5457adbc6e5a`
- Deep patch review: 8 commits
- Compare window used for file grouping: `5457adbc6e5a...472bb2fab5a0`
- Checkpoint before audit: none (`audit-state.json` has no `lastReviewedHeadSha`)
- State update: not recorded; this was a trial audit only
- UE-following signals in this window: none
- Local Hazelight clone observed: `K:\UnrealEngine\UEAS`, branch `angelscript-master`, HEAD `fb34aaf8bf10`, remote `git@github.com:straywriter/UnrealEngine-Angelscript.git`

### Deep-reviewed commits

- `472bb2fab5a0` - Dean Marsinelli - Update `FCollisionShapeType` binding to never need GC
- `abd98481b085` - Josh Wood - Add default constructors for `FTraceDatum` and `FOverlapDatum`
- `263f762c05d7` - efokschaner - Guard test viewport setup against headless commandlet runs
- `186aa1e8982b` - Anthony Rey - macOS VSCode command-line fix
- `bc0083dbdcb7` - Paul Greveson - Fix const correctness of incoming argument to `IsChildOf`
- `b51da9095493` - Kevin Masson - Add missing include for `TObjectIterator`
- `1adca44c16c0` - Markus Stephanides - Add setting for non-UPROPERTY struct fields as `NotReplicated`
- `eae1ae79bed6` - Lucas - Reduce StaticJIT binary size by refactoring static initialization of JIT references

### Author summary for listed window

- Lucas: 11
- Dean Marsinelli: 2
- Anthony Rey: 1
- efokschaner: 1
- Josh Wood: 1
- Markus Stephanides: 1
- Kevin Masson: 1
- Paul Greveson: 1

### Adopt now

- `472bb2fab5a0`: add `NeverRequiresGC()` to local `FCollisionShapeType`; local `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp` does not have it.
- `bc0083dbdcb7`: change local `UClass.IsChildOf` binding parameter from `UClass Other` to `const UClass Other`; local `Bind_UObject.cpp` still has the non-const signature.
- `b51da9095493`: add `UObject/UObjectIterator.h` include to local `AngelscriptEditorModule.cpp`; local editor module uses `TObjectIterator` and did not show that include.

### Already absorbed

- `abd98481b085`: local `Bind_WorldCollision.cpp` already has default constructors for `FTraceDatum` and `FOverlapDatum`, and local types also implement `NeverRequiresGC()`.
- `263f762c05d7`: local `UnitTest.cpp` already guards viewport setup with `FSlateApplication::IsInitialized()`.

### Needs OpenSpec

- `1adca44c16c0`: `bMarkNonUpropertyPropertiesAsNotReplicated` adds a new settings/replication behavior. Local code only has transient handling and explicit `NotReplicated` preprocessing.
- `eae1ae79bed6`: StaticJIT static initialization refactor changes generated code shape and JIT reference registration. Local StaticJIT still uses constructor-based `AS_FORCE_LINK` references.
- Editor menu extension commits in the listed window should be grouped into an editor UX/OpenSpec change rather than mixed into small runtime fixes.
- Script semantic/binding changes such as mixin constructors, binding flags, and bitfield accessor behavior should be evaluated as separate capabilities.

### Reference only

- `186aa1e8982b`: upstream `FAngelscriptEditorModule::OpenVsCode` macOS path does not map directly because this project has source navigation split into `AngelscriptSourceCodeNavigation.cpp`. Consider a separate editor navigation follow-up if macOS support matters.

### Out of scope

- `082479e2b651`: AngelscriptGAS compiler warning fix. GAS is out of default audit scope unless the project explicitly expands sync scope.

### Next audit notes

- If this audit is accepted as reviewed, record `lastReviewedHeadSha` as `472bb2fab5a0bc76d0a86a1dd80750a4118b8418`.
- Before recording the checkpoint, decide whether the three `Adopt now` items should be implemented first or merely marked as reviewed/deferred.
- For a broader upstream sweep, inspect the earlier UE-following range around `dbd4567bb144` and `ec8d139d111c` separately from plugin feature commits.

## 2026-07-14 - Complete marker-range audit and low-risk parity batch

- Repo: `Hazelight/UnrealEngine-Angelscript`
- Branch: `angelscript-master`
- Base marker: `472bb2fab5a0bc76d0a86a1dd80750a4118b8418`
- Reviewed HEAD: `138a7e186082b639375b95545e0177b18f13c4be`
- Complete range: 34 core `Engine/Plugins/Angelscript` commits; 39 deduplicated commits across the configured related paths.
- Changed-file details: fetched per commit after path-scoped pagination; repository-wide compare was not used.
- The earlier `Count 20` command was only a recent-window preview and did not represent the full marker range.
- Previous checkpoint: none. Checkpoint updated after the inventory, local comparison, focused tests, build, and SDK baseline review.
- Audit checkpoint: `.agents/skills/hazelight-update-audit/references/audit-state.json` now records `138a7e186082...` as fully reviewed.
- Local Hazelight clone: `K:\UnrealEngine\UEAS`, branch `angelscript-master`, local HEAD `fb34aaf8bf10`; GitHub API range was used for freshness.

### Author summary

- Lucas: 25
- Dean Marsinelli: 3
- 류기보: 2
- Dan Bradshaw, Filip Bergqvist, Josh Wood, KirstenWF, Nango, Paul Greveson, Szymon Zak, Tianlan Zhou, and Turhan Yağız Merpez: 1 each

### UE-following signals

- `9a366282fa72` - Additional fixes for Unreal 5.8
- `4efb6a2c01e9` - Fixes for Unreal Engine 5.8.0
- `b233a0a85ad4` - Merge remote-tracking branch `epicgames/release`

### Adopt now

- `7270607d98aa` - local `Bind_FString.cpp` now uses a lambda so `TrimQuotes` forwards `OutQuotesRemoved` safely in StaticJIT builds.
- `83a3e539d43a` - local `UObjectTickable::DestroyObject` stops ticking before `MarkAsGarbage`; a generated script subclass regression exercises the actual UE tick path.
- `5022c3a07a1f` - local `CreateWidget` metadata now declares `DeterminesOutputType = "WidgetType"`.
- `b448dd3defca` - local `FLatentActionInfo` keeps the explicit constructor without the incorrect trivial native form; EnhancedInput `GetHandle` uses the fork's equivalent lambda path with no StaticJIT native form.

### Already absorbed

- `ff265bb18dbb` - `FCollisionResponseContainer` constructor behavior is already present locally.
- `abd98481b085`, `263f762c05d7`, and other previously reviewed fixes remain covered by existing local implementations or guards as recorded in `upstream-inventory.md`.

### Needs OpenSpec

- `98626b3dd747` - floating `Pow` overflow semantics; local `AngelscriptSDK` keeps the `Overflow in exponent operation` contract.
- `f0f383f5cb22`, `767ec06038f0`, and related StaticJIT generation changes.
- `4065a84c1bb7`, `5aa00922b79a`, and class-generation/editor lifecycle changes.
- Bind database determinism, cooked/editor classification, preprocessor behavior, TArray API changes, and script-visible Blueprint/class metadata changes.

### Reference only

- Engine-side UHT/CoreUObject changes, fork-specific third-party changes, and sample-only script edits do not map directly to this standalone plugin fork.

### Out of scope

- `67b7a88d912f` and other GAS-only changes remain outside the core plugin parity batch.

### Verification

- Focused parity run: `41/41` passed across bindings, widget metadata, FString coverage, UObjectTickable, and StaticJIT native-form tests.
- SDK baseline: `421/421` passed; the existing `Pow` overflow expectation passed unchanged.
- Editor build: `Tools\RunBuild.ps1` passed after the production and regression-test changes.
