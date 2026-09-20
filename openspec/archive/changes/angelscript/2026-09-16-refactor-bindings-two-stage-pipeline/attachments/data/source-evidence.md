# Source and capability evidence

## Provenance

This is read-only source inspection recorded during Change creation. No new product build, Automation, benchmark or trace was executed. The source inventory is a lexical census, not an assertion that every site is compiled or eligible.

- Parent HEAD: `0f0cf23ee78e563bf93dcf20b43a55381948273d`.
- Plugin HEAD: `7f26e86451a5857fb7096fb4321743f51ac22dd0`.
- Pre-existing plugin working edit: `Source/AngelscriptRuntime/Binds/Bind_FName.cpp`; preserve it.
- Source census: 254 registration sites in 130 C++ files. Pattern matches const FAngelscriptBind declarations, with optional static/AS_FORCE_LINK. Conditional branches and test-only sites are retained.
- The first implementation task reconciles this inventory with captured provider dispositions and independently expected members; do not equate the lexical total with an Automation or runtime total.

| Family | Source sites | Migration task |
| --- | ---: | --- |
| Core | 28 | 5.1 |
| Math | 82 | 5.2 |
| Containers | 12 | 5.3 |
| ObjectsReflection | 40 | 5.4 |
| EngineGameplay | 52 | 5.5 |
| EngineServices | 40 | 5.6 |

The source file is the move unit: companion `_Type.cpp`, `_Functions.cpp` and headers follow their owning registration file. Mechanism helpers move with the framework. Core reflection generators finish in Registry/Core even though their migration acceptance is grouped with ObjectsReflection. Core/AngelscriptBinds.cpp and Testing registration sites are service/probe contributions; that assignment does not authorize moving the whole containing implementation into Registry.

## Current findings and proposed ownership

| Observation | Source and verification boundary | Future task |
| --- | --- | --- |
| Capture requires GameThread and performs declaration callbacks before remaining phase-ordered callbacks | Core/AngelscriptTypeBindInfoRecorder.cpp and Catalog.cpp; no parallel capture in the inspected current path | 2.2, 4.1, 6.1 |
| SDK metadata creation is detached but MutationMutex serializes a shared image | ThirdParty/angelscript/source/as_metadata_image.h and .cpp; MetadataImageTests.ConcurrentFactoriesSerializeOwnershipWithoutAnEngine proves concurrent admission, not speedup | 2.4, 4.2 |
| Engine attachment has engine/image locking and rejects foreign-engine images | ThirdParty/angelscript/source/as_scriptengine_metadata.cpp; EngineRegistrationTests | 2.4, 6.2 |
| Template definitions are skipped in member construction; later MaterializeTemplateInstance does not complete their callable member graph | Core/AngelscriptTypeBindInfoApply.cpp Prepare and MaterializeTemplateInstance; operations-only tests are insufficient | 3.2, 3.3 |
| Delegate subscriptions retain raw Single/Multicast pointers and dereference them during installation destruction | Core/AngelscriptTypeBindInfoApply.cpp FDelegateSubscription/destructor | 3.4 |
| ExecuteDelegatePayload holds a reference to a shared pointer inside a mutable array across ProcessEvent; Unbind also resets Payload | Core/AngelscriptTypeBindInfoApply.cpp ExecuteDelegatePayload/UnbindDelegatePayload; fixing only the array reference does not define active payload lifetime | 3.5 |
| ValidateSealed admits recipes while ConnectNative forwards native pointer fields | Core/AngelscriptTypeBindInfoValidation.cpp and Apply.cpp; target admission can disagree before allocation | 2.4 |
| Adapter registration records a name and recording-mode TypeFinder returns without retaining it | Core/AngelscriptBinds.cpp RegisterTypeForTarget/RegisterTypeFinderForTarget; Isolation test manually adds adapters after engine creation | 3.1 |
| Validation prepares and discards an installation, then Install prepares again | Core/AngelscriptTypeBindInfoValidation.cpp and Apply.cpp/Engine.cpp; carry one prepared result forward | 2.4 |
| Existing native module maps already include thunk, signature/layout and origin | Core/AngelscriptTypeBindInfo.h and native map paths in Apply.cpp; extend this transport rather than replacing it with raw void pointers | 2.3 |

## Inspected source hashes

Paths below are relative to Plugins/Angelscript/Source/AngelscriptRuntime unless stated otherwise. These hashes pin inspection facts, not an immutable formal Review.

| File | SHA-256 |
| --- | --- |
| `Core/AngelscriptTypeBindInfoRecorder.cpp` | `8322aab5c57f84d7d2f08b85355368461333049dbb86c2b4f16f793904389d53` |
| `Core/AngelscriptTypeBindInfoCatalog.cpp` | `7454ff0798386cabd9a087ec2498eb043dfce60515f0cf3e267f6df2474e9c57` |
| `Core/AngelscriptTypeBindInfoApply.cpp` | `4cf6c9078150c5e0c9f1b601075b0b0915eac70a0cf4de4d9ad7c971c483bcc2` |
| `Core/AngelscriptTypeBindInfoValidation.cpp` | `f68e89c75c1f6b6c696a5cdad7865c3a109b18d730091665bc235dd5cf374182` |
| `Core/AngelscriptBinds.cpp` | `3802a9abf9c41b428420e1858ea2e4aaf22624438dc559dd79ff31fc4391c527` |
| `Core/AngelscriptEngine.cpp` | `2e9fcc2b141b9d71f253ded63a8350df9332c5eeedf97a1afe7643e147f70519` |
| `ThirdParty/angelscript/source/as_metadata_image.h` | `abb48ad9a419f471f9fa0dd168abebe47d1fc346ed4d7136e433cba7e335dfa0` |
| `ThirdParty/angelscript/source/as_metadata_image.cpp` | `12ab9c4674ada3fd181fadf0ace2e211903441db481e602f29c6bd30f551cd4a` |
| `ThirdParty/angelscript/source/as_scriptengine_metadata.cpp` | `95819711a61a8ab84e1696681d006c7baeb7ca449177bbc0479df70530ca9e92` |
| `ThirdParty/angelscript/source/as_memory.cpp` | `24163de7a2a1aa20b131ca4df518ac7e2d238e7bc7fcb07240f0dfc8ef33a351` |

## Earlier evidence and neighboring ownership

- The archived feature-runtime-binding-record-apply Change documents 312 RuntimeBindings and 1,080 NativeEngine cases plus dormant controls on its final binary. These historical results do not prove the new design or the listed untested cases. Its attachments/INDEX.md is the entry to historical evidence.
- Earlier whole-test timings in ignored Saved/Research are not phase baselines or current performance measurements. Reproduce measurements under tasks 1.1, 1.2 and 6.3.
- The reference worktree implemented an allowlisted parallel-record experiment but used a serial product path because of shared-state races. It is evidence for isolation boundaries, not an implementation to merge wholesale.
- Active angelscript/feature-delegates-ue-interop owns additional delegate language and Blueprint/cooked integration. This Change fixes the current binding bridge without marking those tasks complete.
- Active angelscript/feature-memory-gc-observability owns general allocator/GC observability. Reuse existing allocators/tracing and limit changes to binding-owned statistics and scopes.

## Profiling references

- [UE Trace Developer Guide](https://dev.epicgames.com/documentation/unreal-engine/developer-guide-to-tracing-in-unreal-engine?lang=en-US): fixed CPU scopes and counter APIs; dynamic per-provider detail is optional.
- [UE Memory Insights](https://dev.epicgames.com/documentation/unreal-engine/memory-insights-in-unreal-engine?lang=en-US): native allocation lifetimes, tags and callstacks.
- [UE Low-Level Memory Tracker](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-the-low-level-memory-tracker-in-unreal-engine): scoped allocation categories.
- Harness ue.test supports ExtraArguments. The future trace task uses that route, a unique Saved path and bounded timeout; no root Tools wrapper or direct Unreal executable is required.

## Inventory maintenance

Refresh this inventory only when source evidence changes. Preserve each registration disposition and its owning migration task; explicitly account for compiled-out, policy-excluded, test-only and no-output sites. Do not redefine expected script members by copying the final implementation dump.
