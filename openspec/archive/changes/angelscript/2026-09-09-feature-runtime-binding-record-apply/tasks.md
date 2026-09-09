---
task_graph:
  version: 1
  depends_on:
    "1.2": []
    "1.3": ["1.2"]
    "1.4": ["1.3"]
    "1.5": ["1.4", "3.3", "6.2"]
    "1.6": ["1.8"]
    "1.7": ["1.6"]
    "1.8": ["1.5", "2.4"]
    "2.2": ["1.3"]
    "2.3": ["2.2"]
    "2.4": ["2.3"]
    "2.5": ["2.4"]
    "3.2": ["2.5", "1.4"]
    "3.3": ["3.2"]
    "4.2": ["6.2"]
    "4.3": ["4.2"]
    "4.4": ["4.2"]
    "4.5": ["4.2", "5.2"]
    "4.6": ["4.2"]
    "4.7": ["4.2", "5.3"]
    "4.8": ["4.7", "5.5"]
    "4.9": ["4.2"]
    "5.2": ["4.2"]
    "5.3": ["5.2"]
    "5.4": ["5.2", "5.3"]
    "5.5": ["5.2", "5.3"]
    "5.6": ["5.2"]
    "6.2": ["3.2"]
    "6.3": ["6.2", "4.2"]
    "6.4": ["6.2", "2.5"]
    "6.5": ["6.3", "6.4", "5.2"]
    "6.6": ["6.5"]
    "6.7": ["6.3", "5.2"]
    "6.8": ["6.5", "6.7"]
    "7.2": ["6.5", "4.3", "4.5"]
    "7.3": ["6.6", "6.8", "7.2", "4.4"]
    "7.4": ["6.6", "6.8", "4.6"]
    "7.5": ["6.5", "6.7", "4.7"]
    "7.6": ["6.5", "4.8", "5.5"]
    "7.7": ["4.7", "5.3"]
    "7.8": ["4.7", "6.6"]
    "7.9": ["6.6", "6.8", "7.3"]
    "7.10": ["4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5.3", "5.4", "5.5", "5.6", "6.7", "6.8", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9"]
    "8.2": ["1.7", "3.3", "7.10"]
    "8.3": ["8.2"]
    "8.4": ["8.2"]
    "8.5": ["8.3", "8.4"]
---

## Execution contract

The accepted scope is full Runtime migration with independently testable outcomes. Original IDs 1.1 through 8.1 are superseded by the indexed applied replan; they are not completed work. Current execution state exists only in this DAG. All 253 inventory source declarations have a primary migration owner in data/provider-inventory.md; counts include conditional alternatives and do not imply installed coverage.

Import Harness in the current PowerShell 7 process and use `$context = New-HarnessContext`. All UE operations use Harness. Freeze source writers during builds and tests. Compatible Ready tasks may share one documented proving run with task-specific case evidence. Shared Core/Binds paths and the UE lease constrain concurrent writers, but do not create artificial data dependencies. No concurrent agent work is assumed.

The real declaration/lifetime prepass (6.2 and 4.2) and template-instance foundation (5.2) precede complete family member surfaces. This breaks the observed FString/TArray and FText/container signature cycles. Family tests compose real owning-provider dependency declarations and migrated members into a fresh complete image before Freeze; no fabricated replacement types or edits to frozen dependencies are permitted. Full default CreateForBindings is gated by 8.2.

Each implementation task prepares concrete cases before code, observes behavioral RED, implements its outcome and proves GREEN. A missing C++ interface may receive only a compilable skeleton before RED. Compilation failures, undiscovered cases and crashes are setup failures. Existing passing controls are labeled separately. Expected values come from independent fixture semantics. Provider coverage compares the inventory with actual declarations/effects, not raw counts alone.

All product globs exclude Legacy and separate GAS/GameplayTags plugins. ThirdParty is owned only when explicitly named. Common infrastructure paths permit the bounded consumer wiring described by the task. Preserve the reference workspace and unrelated host-generated sources.

## 1. Recording

Task 1.4 proof: [Provider verification](attachments/data/verification-providers.md), seven observed RED failures plus one existing control; 23 shared GREEN successes refresh all Recording tasks.

Task 1.3 proof: [Facade verification](attachments/data/verification-facade.md), eight observed RED failures and 15 shared GREEN successes including refreshed Store proof.

Task 1.2 proof: [Store verification](attachments/data/verification-store.md), RED 7 failures and GREEN 7 successes on the recorded source/binary identities.

- [x] 1.2 Own immutable type/member records and reject invalid store transitions — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Store.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingStoreTests.cpp`

  Define the Store's native type/member/provenance records, stable record handles and Seal contract. Copy input strings and records into store ownership. Public views remain const; rejected sealed mutation preserves existing content. Record kind/size/alignment conflicts with both provider sources. This node provides the storage API, not provider execution or the FAngelscriptBinds facade.

  Cases: StoreOwnsInputLifetime: mutate original Pair/name buffers and retain original values; EmptyStoreSeals; RepeatedSealPreservesIdentity; SealedMutationRejected with original count/content unchanged; ConflictingNativeDefinition names both sources; compatible same-name declarations coalesce.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 1.3 Route value, enum, property and callable authoring into detached records — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Facade.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFacadeTests.cpp`

  Add FAngelscriptBinds(Store), recording handles for BoundFunction/BoundProperty, scoped namespaces and recording-safe queries. Cover every facade operation and modifier currently used by Runtime, including lifecycle behaviours, native/JIT recipe descriptors, generic caller, property exposure, defaults and first-parameter metadata. Preserve existing provider authoring forms; actual engine queries return no engine object rather than invoking legacy registration.

  Cases: Pair value record has native size/alignment, X offset, construct/destruct, Sum method; global Add retains caller and auxiliary; Mode Off=0/On=1 lives in Test namespace and scope restores namespace; modifiers survive subsequent record reallocations; sealed handle edits are rejected; same short type name in two namespaces is distinct.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 1.4 Execute a deterministic provider snapshot once with provenance and conditions — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Providers.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindsInternal.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingProvidersTests.cpp`

  Implement Recorder against the existing collection. Serial execution consumes a sealed provider list with current phase/owner/source, records outputs and effective policy, and produces a sealed Store. Reusing the Store never executes callbacks. Reject duplicate provider identity/conflicting sources and recording failures with source context; modules and reflected objects must outlive the snapshot. Full default provider installation is still a later gate.

  Cases: Out-of-order local providers execute in declared phase/name order; one provider failure identifies its source and prevents published snapshot; reuse leaves invocation count one; two eligible providers extending one type preserve both contributions; target condition excludes only its intended provider; unsealed collection is rejected.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 1.5 Prove global scope storage and sealed snapshot ownership — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Ownership.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingOwnershipTests.cpp`

  Follow up completed 1.2-1.4 with typed lifetime inspection of copied constants, borrowed native/auxiliary/global addresses and retained reflection. Consume explicit two-owner creation and 6.2 retained reflection. Preserve one Store per Capture, store-bound handles, shared const records and separate engine state; no global mutable Store cache or automatic module-unload support.

  Cases: Root and Test scopes have independent Add overloads/Value globals; nominal Test does not collide with namespace Test. Copied constant 7 survives source mutation; borrowed host value changes to 9 without altering its declaration. Different-policy captures have separate records. Two Engines retain one snapshot after creator release; releasing A leaves B usable, releasing B allows snapshot/reflection weak references to expire. All exposed record mutation after Seal preserves content, policy, provenance and attachment; foreign handles fail. Reflection policy mismatch rejects before attachment/record mutation (6.2 control). Lifetime categories truthfully distinguish borrowed versus retained objects.

  1. Prepare literal fixtures, counters and weak references; observe missing inspection/category or mutation behavior as RED and label passing existing controls.
  2. Implement bounded storage/lifetime descriptors and consumer wiring without changing intentional shared host globals.
  3. Prove GREEN with the exact selector and retain case/source/binary evidence; refresh impacted Recording/Isolation proof when shared behavior changes.

  > Proof: `attachments/data/verification-recording-ownership.md` — two behavioral RED failures/four controls, final six-case GREEN, and eight adjacent Facade cases successful without warnings or errors.

- [x] 1.6 Dump intended AS types, members and globals before Engine creation — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Manifest.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindsInternal.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptBindingDump.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingManifestTests.cpp`

  Add FAngelscriptTypeBindInfoInspection and explicit Store-based export-to-directory entry. Produce versioned JSON, types/classes/members/globals/providers/exclusions CSV tables and summary from one projection. Old StateDump columns are reference only; no global Engine lookup or script compilation. Collection-only export never executes providers; Store export rejects unsealed/failed input. Label recorded stage and selected-family/full-runtime scope; separate intended AS declarations, reflection-only identities and exclusions/effects. Include qualified identities, canonical typed references through the existing engine-free parser/resolver, inheritance/interfaces, aliases/templates, layout/property facts, signatures/modifiers/defaults, globals/constants, source/conditions and ordered native/lifecycle recipes. Describe addresses symbolically; preserve int64 reflection values as decimal strings and opaque categories explicitly. Include 1.8 seal/validation status and diagnostics, allowing sealed semantic failures to be inspected without labeling them ready. 1.7 consumes this schema; 8.2 produces the real full Runtime dump.

  Cases: Pair/X/Sum, Derived-before-Base, Test.Add overloads and constant 7 have independently asserted declarations/fields/sources. Captured-only UE identity and excluded Editor candidate are absent from intended AS classes. Equivalent captures with shuffled registration/different valid host addresses produce equal semantic output; signature/offset/policy/constant changes alter corresponding fields. Nested array-of-object, interfaces, layout/lifecycle flags and int64 -3/1234567890123 survive export. Repeated dump and rejected sealed mutation preserve output/callback counts; payloads are never dereferenced. JSON/CSV quotes, commas, newlines and Unicode round-trip; tables agree with JSON. Unsealed input or unwritable method-owned destination fails without success metadata. Actual Runtime Collection inspection accounts for all compiled descriptors without executing unmigrated callbacks and labels itself collection-only.

  1. Prepare these semantic/export cases and observe behavioral RED; only a compilable missing-interface skeleton may precede RED.
  2. Implement typed projection, condition/lifetime descriptions and deterministic JSON/CSV export.
  3. Prove GREEN with the exact selector and retain sample artifacts plus case/source/binary evidence; defer full-runtime success to 8.2.

- [x] 1.7 Validate and diff binding dumps with standalone Python tools — verify: `python -m unittest discover -s Plugins/Angelscript/Tools/BindingInspection/tests -p "test_*.py"`
  > Files: `Plugins/Angelscript/Tools/BindingInspection/**`

  Add stdlib-only validate_bindings.py, diff_bindings.py, README and unittest fixtures. CLI: `python Plugins/Angelscript/Tools/BindingInspection/validate_bindings.py MANIFEST --expect EXPECTATIONS --report REPORT` (expect/report optional); `python Plugins/Angelscript/Tools/BindingInspection/diff_bindings.py BEFORE AFTER --report REPORT` (report optional). Validator exits 0 valid, 1 validation/schema/expectation failure; diff exits 0 equal, 1 semantic changes, 2 invalid/incompatible input; usage errors exit 2. Structured diagnostics name symbol/source. Expectations independently specify required/forbidden symbols and provider dispositions, never copy actual exporter results.

  Consume the 1.6 versioned schema. Validate required fields/kinds, unique qualified type/member/global identities, provider references, alias/base/interface/by-value references, positive power-of-two alignment where applicable, nonnegative layout and property bounds, enum precision, exclusions and explicit scope. Builtins/template parameters/authorized external references use typed categories. Reject base/value cycles; allow handle cycles. Compare semantic declarations/modifiers, ignoring cosmetic ordering but preserving recipe order, qualifiers and defaults. No UE launch or duplicate AS parser.

  Cases: Hand-authored valid Pair/Derived/Test.Add/constant-7 input passes. Deleted Base, dangling member type/provider, duplicate canonical identity, illegal alignment/offset, base/value cycle, malformed enum/schema and missing expected method fail with exact symbol/source. Legal overloads/namespaces/mutual handles pass. Unsupported schema and partial/collection-only input cannot satisfy full-runtime expectations. Diff independently identifies added type, removed method and changed base/default/constant/recipe order; reorder-only input compares equal. Malformed files, Unicode and CLI exit codes use bounded Python subprocesses. Fixtures use independent literals and deliberate mutations.

  1. Prepare positive/negative validator and comparison fixtures and observe missing behavior as RED.
  2. Implement offline validation/diff and README commands against 1.6's contract.
  3. Run the exact unittest selection for GREEN; 8.2 additionally runs these tools on actual full Runtime output, preserving commands/results rather than substituting fixture proof.

- [x] 1.8 Validate sealed records before allocating an Engine — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Validation.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingValidationTests.cpp`

  Add FAngelscriptTypeBindInfoValidation::ValidateSealed producing a read-only deterministic result with stage, symbol, provider and source diagnostics. Consume existing parsing/nominal/layout/member validation rules from 2.2-2.4 and ownership/policy facts from 1.5; do not duplicate AS parsing or create a native Engine. Seal remains write closure, not a claim of installation readiness. Check source/policy consistency, required type references, base/by-value cycles, native layout/property bounds, canonical incompatible member duplicates and required native callable/recipe descriptor presence according to declaration kind. Legal overloads, template parameters, forward references and handle cycles follow existing semantics. Do not validate borrowed pointees by dereferencing them. CreateForBindings runs this gate before native Engine allocation; failed semantic validation leaves the Store inspectable. 1.6 exports result/diagnostics and distinguishes partial declaration inspection from installable/full-runtime readiness.

  Cases: A literal sealed Pair/X/Sum/Add surface validates without Engine creation or callback execution. A deliberately missing required nominal can Seal but fails ValidateSealed with its exact symbol/source. Invalid base cycle, by-value cycle, property offset/alignment, malformed member declaration, incompatible canonical duplicate, missing required native target and mismatched policy/provenance each fail their stage; existing earlier admission failures are controls, not bypassed or manufactured RED. Root/named overloads, Derived-before-Base and mutually referring handles pass. Unsealed/recording-failed input is rejected. Repeated validation before/after attempted sealed edits returns equal diagnostics/results and unchanged records, provider lists, policy, attachment and native targets. Invalid CreateForBindings returns no owner and no allocated native Engine; valid two-owner reuse does not execute providers. Failed semantic validation is dumpable with failure status rather than ready.

  1. Prepare related positive/negative fixtures and distinguish current parser/admission controls from missing preflight behavior; observe grouped behavioral RED.
  2. Implement reusable validation and pre-allocation factory wiring without mutating sealed records or running native targets.
  3. Prove GREEN with the exact selector and refresh impacted Creation and Recording proofs; retain case/source/binary identities. VM/ABI/lifecycle execution proof remains owned by the existing tasks.

## 2. Declaration parsing and metadata installation

Task 2.4 proof: [Member verification](attachments/data/verification-members.md), observed staged RED followed by 51 shared RuntimeBindings successes, 23 MetadataImage and seven GlobalDefinitions successes.

Task 2.3 proof: [Layout verification](attachments/data/verification-layouts.md), nine observed RED failures, 40 shared RuntimeBindings GREEN successes and 23 adjacent MetadataImage successes.

Task 2.2 proof: [Declaration verification](attachments/data/verification-declarations.md), eight observed RED failures, eight GREEN successes and 67 adjacent frontend declaration successes.

- [x] 2.2 Parse host declarations into canonical type uses and signatures — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Types.Declarations.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDeclarationsTests.cpp`

  Add a focused binding-declaration entry point reusing current tokens/type syntax and TypeContext. Inputs are recorded declaration text, namespace and nominal lookup; output contains canonical types, callable identity, parameter directions/default text and diagnostic ranges. No script bodies or Engine required.

  Cases: Parse 'const FVector& Get(int Index = 2) const', 'void Fill(FString&out Value)', nested TArray<TArray<int>>, namespace-qualified overloads and UObject handles; equivalent spelling resolves equal identity; value versus ref differs; unknown nominal, malformed template bracket and invalid out value give source-ranged errors; explicit void return succeeds.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 2.3 Resolve nominal dependencies and construct valid native layouts — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Types.Layouts.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_objecttype.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingLayoutsTests.cpp`

  Build the draft image's full nominal index before resolving base/interface/by-value dependencies. Output a typed draft and type lookup consumed by member installation. Use recorded native size/alignment and property-address facts; legal reference cycles are distinct from illegal layout/base cycles.

  Cases: Derived declared before Base installs correct base; Holder declared before Pair resolves member type with native offsetof; mutually referring object handles succeed; MissingType, BaseA/BaseB inheritance loop, by-value loop and invalid alignment fail with provider/declaration provenance; enum values and alias identities round-trip.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 2.4 Complete signatures, behaviours and properties before freezing images — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Types.Members.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_property.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMembersTests.cpp`

  Consume the typed draft and recorded members; define all methods, globals, properties, behaviours, defaults, traits and access facts, finalize layouts, Freeze and register into a supplied local native Engine. Add checked native metadata facts as required. Pass recorded definition modifiers through the binding parser before function identity interning, so frozen metadata authenticates against the complete producer descriptor. Never append to an installed frozen type.

  Cases: Pair.Sum and overloaded globals resolve distinct stable functions; read-only/protected/property offsets and no-discard/default/direction facts are preserved; missing parameter type and duplicate incompatible signature fail before publication; every member is visible after image install; second Engine uses a distinct image; later attempted mutation fails.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 2.5 Connect recorded callable identities to the current VM with correct ABI — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Calls.Native.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_native*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_generic.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingNativeTests.cpp`

  Bind recorded targets through BindNativeFunction and explicit per-engine sidecars. Support member/free/generic, object-first/object-last, auxiliary and first-parameter metadata, property addresses and value lifecycle callbacks. Calls are VM Context Prepare/Execute operations; no complete source compiler is required.

  Cases: Add(2,3)=5; Pair.Sum=7; value return preserves both fields; ref return aliases receiver; out becomes 7 and inout 3 becomes 8; generic callback observes its auxiliary; constructor/copy/destructor counts balance; wrong signature/owner/missing target rejects connection and leaves no usable partial install.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-native-calls.md` — initial 15-case RED, interrupted auxiliary evidence, member-auxiliary RED, final 71-case shared GREEN (20 native cases), plus 28 VM native, 23 MetadataImage and 7 GlobalDefinitions cases.

## 3. Explicit Engine ownership

Task 3.2 proof: [Creation verification](attachments/data/verification-creation.md), nine observed RED failures and all 80 shared RuntimeBindings cases GREEN; three adjacent startup cases succeeded with MetaSound discovery warnings recorded separately.

- [x] 3.2 Create an explicitly owned binding Engine and unwind failures — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Engine.Creation.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingCreationTests.cpp`

  Implement sealed-store CreateForBindings and private binding-only constructor/init/destructor. Own native engine, contexts, TypeDB and installation state; bypass cache/source/config-service/debug/coverage startup. Add the full Runtime overload with explicit failure until its provider pipeline is complete. Return TUniquePtr or a structured recording/type/member/native-stage diagnostic.

  Cases: Explicit Pair/Add snapshot creates callable Engine; ambient current Engine remains null; unsupported native target returns null plus source/stage; repeated create/destroy releases all counted sidecars and contexts; destruction after partial initialization is safe; default subsystem stays dormant.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 3.3 proof: [Isolation verification](attachments/data/verification-isolation.md), five observed RED failures/four existing controls; all 89 shared binding cases and 28 VM native cases GREEN, plus three successful startup cases with discovery warnings recorded.

- [x] 3.3 Reuse one snapshot across independently functioning Engine lifetimes — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingIsolationTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.*`

  Exercise and complete the two-owner boundary: image/type/function objects, mutable TypeDB, adapter operations and contexts belong to their exact owner. Engine-local owner resolution replaces ambient assumptions in the new call path.

  Cases: Create A/B from one Store and retain provider count one; mutate A fixture state without changing B; destroy A then call B Add(2,3)=5 and resolve Pair; reject using A function/context in B; release B and verify no counted sidecar remains.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

## 4. Native definition catalog and value families

Task 4.8 proof: [FText and formatting verification](attachments/data/verification-text.md), staged provider/parser/metadata RED, seven-case exact GREEN, 46-case shared value-family GREEN, and focused declaration/metadata regression proof.

- [x] 4.2 Extract real native declaration and lifetime dependencies before member migration — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.DefinitionCatalog.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDefinitionCatalogTests.cpp`

  Provide RecordRuntimeTypeDeclarations as an explicit serial prepass over actual provider-native definitions, plus primitive aliases/adapters/constants. Extract declarations and constructor/copy/destructor/GC recipes from their owning providers; this includes the type-only dependencies needed by value, container and UE member signatures. No fabricated test replacements and no claim that this prepass installs a full API. Selected-family tests compose this catalog with migrated member records before freezing one image; later tasks extend the same canonical provider hooks.

  File boundary: native declaration and lifecycle callbacks only; exclude unrelated full member bodies.

  Cases: Every native declaration in the inventory has a real size/alignment/kind/owner and required lifetime recipe; primitive bool/int8/int32/uint64/float32/float64 usages map correctly; string/text and value fixtures copy/destroy correctly without their full method surface; declaration-only capture makes no Engine queries; incompatible duplicate layout fails; providers embedded in ExplicitBindings still contribute their native declarations.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 4.3 Migrate integer points and float/double vector interfaces — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Vectors.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingVectorsTests.cpp`

  Record and install complete interfaces for the vector/point family using the real declaration catalog for cross-family signatures. Preserve native recipes, aliases, const/ref returns, properties and numeric width.

  Cases: Vector(1,2,3) squared length=14; vector addition has literal components (5,7,9); integer point indexing mutates only selected component; float/double variants retain width and layout; normalized zero follows existing contract; enumerate all family declarations and invoke representative constructors/operators.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 4.4 Migrate rotation, quaternion, transform and matrix interfaces — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Rotations.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMatrix*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingRotationsTests.cpp`

  Complete rotation/transform family records and native calls, consuming the catalog's vector dependencies without requiring vector member implementation. Preserve conversion and compose/inverse return types.

  Cases: Identity transform preserves (1,2,3); translation (10,20,30) yields (11,22,33); inverse returns original within explicit epsilon; identity quaternion composition unchanged; matrix identity preserves homogeneous coordinates; family full-surface inventory matches records.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 4.5 proof: [Bounds verification](attachments/data/verification-bounds.md), six execution failures plus one inventory control at RED, seven-case exact GREEN and 160-case shared RuntimeBindings GREEN.

- [x] 4.5 Migrate planes, boxes, spheres and bounds interfaces — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Bounds.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox2D*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane4f*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere3f*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingBoundsTests.cpp`

  Complete the native geometry/bounds providers and all supporting declaration/lifecycle facts. Keep invalid/empty-state and precision semantics from owning UE types.

  Consumes task 5.2's installable `TArray<T>` template declaration and native adapter because the complete `FSphere` and `FBoxSphereBounds` constructor surfaces contain `TArray<FVector>` parameters.

  Cases: Box corners (0,0,0)/(2,4,6) center=(1,2,3); inside/outside points classify correctly; union expands bounds; sphere radius 2 contains origin but not (3,0,0); plane distance uses known normal; empty box path and every family declaration are checked.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 4.6 proof: [colors and Slate layout verification](attachments/data/verification-colors-layout.md), Engine-free namespace recording, exact 101-contribution surface, six-case exact GREEN and 179-case shared RuntimeBindings GREEN.

- [x] 4.6 Migrate colors and Slate layout value interfaces — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.ColorsLayout.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAnchors*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMargin*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGeometry*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingColorsLayoutTests.cpp`

  Complete color and native Slate-layout value bindings, retaining packed versus floating representation, property offsets and precision. UObject/widget member customization remains in 7.4.

  Cases: FColor channel round-trip (1,2,3,4), known black/white linear conversion, FMargin(1,2,3,4) sums to 10, anchors min/max persist, identity FGeometry coordinate conversion preserves an input point; full records include existing constructor and property surface.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 4.7 proof: [FString and FName verification](attachments/data/verification-string-name.md), six-case grouped RED/exact GREEN, exact 100-contribution fixed surface, 173-case shared RuntimeBindings GREEN and 23-case adjacent metadata-image GREEN.

- [x] 4.7 Migrate FString and FName including array-dependent members — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.StringName.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString_*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingStringNameTests.cpp`

  Install complete FString/FName interfaces after the TArray surface and its real string element operations exist. Preserve construction, mutable indexing, namespace statics, defaults, `accept_temporary_this`/`no_discard` declaration suffixes and native formatting recipes; generic ToString contributions are finalized in 7.10.

  Cases: Copy 'ab' then append 'cd' gives 'abcd' without changing original; split 'a,b' produces two array strings; Join(['a','b'],'-')='a-b'; FName equal-name comparison and string round-trip succeed; invalid index reports current error contract; enumerate every applicable FString/FName declaration.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 4.8 Migrate FText and formatting records with container dependencies — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.Text.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_syntax*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FNumberFormattingOptions*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FStringTableRegistry*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTextTests.cpp`

  Install full text/formatting family including argument values, options and string-table accessors after real array/map definitions and string members. Preserve the existing generic `?&` parameter wildcard in recorded format overloads as a canonical type use that installs as AngelScript's wildcard type. Use deterministic culture for output assertions and restore it.

  Cases: Format ordered '{0}' with 7 yields '7'; named '{Count}' map yields '7'; text/string conversion preserves 'hello'; number formatting options survive copy; invalid argument type gives explicit diagnostic; string-table missing-entry behavior follows provider contract without global fixture leakage.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 4.9 proof: [time and identity verification](attachments/data/verification-time-identity.md), eight-case grouped RED/exact GREEN, exact 506-contribution member surface and 54-case shared Values GREEN.

- [x] 4.9 Migrate time, GUID, range, frame and deterministic random value providers — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Values.TimeIdentity.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTimespan*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGuid*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFrameTime*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRange*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Hash*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTimeIdentityTests.cpp`

  Complete independent scalar utility/value families and math/hash globals. Preserve exact integer/time representation, range inclusion and deterministic random stream ownership.

  Cases: One-second timespan has expected ticks; known date components round-trip; zero GUID is invalid and fixed parsed GUID round-trips; range includes lower/excludes upper according to declared bound; same random seed gives identical sequences across owners and reset repeats it; math Clamp(5,0,3)=3; stable equal-value hashing; all family records accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

## 5. Template instances and containers

Task 5.5 proof: [TMap and iterator verification](attachments/data/verification-map.md), provider-declaration RED, seven-case exact GREEN and 22-case shared container GREEN.

Task 5.2 proof: [Template-instance verification](attachments/data/verification-template-instances.md), eight-case behavioral RED and exact GREEN; the 160-case adjacent run retained 154 successes and only the six already observed task 4.5 Bounds RED cases.

- [x] 5.2 Materialize template identities and engine-local element operations — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Instances.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingInstancesTests.cpp`

  Extract template declaration/instance/lifetime infrastructure from container providers before their full method surfaces. Consume canonical native definition recipes, validate element operations and create cached concrete instances before freezing. Late instances are complete dependent images. This task owns template/lifetime infrastructure only; later tasks own container members.

  Cases: TArray<int>, TArray<FString> and nested arrays resolve expected canonical arguments; repeated use in one owner shares instance identity and two owners do not share mutable operations; invalid element copy/hash requirement reports element/provenance; late instance install preserves prior frozen image; counted element copy/destruction and UObject reference enumeration are correct.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 5.3 proof: [TArray and iterator verification](attachments/data/verification-array.md), seven-case behavioral RED/GREEN, exact 58-member provider surface and 167-case shared RuntimeBindings GREEN.

- [x] 5.3 Migrate complete TArray and iterator behavior — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Array.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingArrayTests.cpp`

  Use real element definitions/lifecycle recipes from 4.2/5.2; complete array constructor, assignment, indexing, mutation, iteration, comparison and native recipe surface. FString type operations are available before its full members, avoiding a String/Array dependency cycle.

  Cases: Copy [2,5], clear original, and retain copy count 2/index1=5; append/remove changes expected sequence; iteration yields 2 then 5; invalid index diagnosed; strings copy independently and counted elements destruct once; nested arrays and handle elements preserve ownership; all TArray declarations accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 5.4 proof: [TSet verification](attachments/data/verification-set.md), five-case behavioral RED plus one existing control, six-case exact GREEN, complete 33-member provider accounting, and 207-case shared RuntimeBindings GREEN.

- [x] 5.4 Migrate complete TSet hashing, iteration and lifetime behavior — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Set.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingSetTests.cpp`

  Complete set providers using canonical element hash/equality and lifetime operations; any array return types consume 5.3.

  Cases: Insert 2 twice keeps one element; adding 5 gives two; remove 2 leaves 5; iteration visits each once; independently copied string set survives source clear; unsupported hash element is rejected; handle/reference enumeration remains correct.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

- [x] 5.5 Migrate complete TMap key/value and iterator behavior — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Map.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMapTests.cpp`

  Complete map providers with separate key hash/equality and value copy/destruction operations; preserve out/ref lookup and iterator validity rules.

  Cases: Set key 'a' to 2 then 5 keeps one key with value 5; copy survives original removal; missing-key lookup uses existing explicit contract; iterator key/value matches expected pair; counted values release on replace/remove; nested array value copy is independent; all map declarations accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

Task 5.6 proof: [TOptional verification](attachments/data/verification-optional.md), six-case behavioral RED plus one provider-surface control, seven-case exact GREEN, exact 14-member accounting, and 214-case shared RuntimeBindings GREEN.

- [x] 5.6 Migrate complete TOptional engagement and contained lifetime behavior — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Optional.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingOptionalTests.cpp`

  Complete optional providers using per-engine contained-type operations; preserve unset/get/reset/assignment semantics and native recipe descriptors.

  Cases: Default is unset; assign 7 engages and reads 7; copy remains 7 after original reset; resetting counted element destroys once; unset get reports existing error; nested optional/value and handle references follow recorded operations; every declaration accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

## 6. UE reflection and callable bridges

- [x] 6.2 Capture loaded UE nominal types and native adaptation recipes — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.Definitions.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDefinitionsTests.cpp`

  Provide the GameThread reflection declaration snapshot: loaded UClass/UStruct/UEnum/interface/delegate signature identities, parent relationships, native layout, property type uses and lifecycle/GC adaptation recipes. Extract declaration hooks from owning providers; member implementation remains in 6.3–6.8. Combined with native value declarations this becomes the real dependency catalog used by family tests. No arbitrary script class compilation or late module tracking.

  Cases: Derived UClass declared before its base resolves correct identity; UStruct fixture size/alignment and property kind match reflection; enum names/values round-trip; delegate signature identity is captured without invoking it; same loaded snapshot can be reread without Engine query; editor-ineligible types have a policy exclusion; temporary fixture types remain valid for the snapshot lifetime; int64/nested property facts are copied; original providers reuse the detached snapshot; mismatched policy fails before attachment or record mutation.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-rotations.md` — five-failure/one-control RED, final six-case GREEN, 386 selected-provider contributions, native transform/quaternion/matrix execution and 145-case shared RuntimeBindings GREEN.

  > Proof: `attachments/data/verification-vectors.md` — staged behavioral RED, exact seven-case GREEN, 389 selected-provider contributions, installed native constructor execution and 139-case shared RuntimeBindings GREEN.

  > Proof: `attachments/data/verification-reflection-definitions.md` — staged 11-case feature RED, final policy-mismatch RED with 12 controls, successful build and all 13 exact selector cases GREEN without warnings or errors.

- [x] 6.3 Install UObject properties, inheritance, interface and struct access — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.Objects.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPackage*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingObjectsTests.cpp`

  Apply the reflected definition snapshot to per-engine TypeDB/adapters and complete UObject/UStruct/UEnum/UPackage interfaces. Preserve TypeFinder precedence, property offsets/access, reference qualifiers, native struct copy, UE GC and owner lookup. Generated and generic UFunction call transport are separate next tasks.

  Cases: Parent property 11/child property 13 read and write only intended object; interface lookup identifies concrete implementation; native struct copy has independent storage and balanced destruction; enum property round-trip; const/read-only property cannot mutate; wrong-owner type rejected; retained UObject survives collection while referenced and releases when owner is drained.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-objects.md` — seven-case behavioral RED/GREEN, owner-checked property/struct/interface/GC adapters, dynamic reflection isolation repair, and final 221-case shared RuntimeBindings GREEN proof.

- [x] 6.4 Install generated native maps and alternate native-module transport — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.NativeMaps.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding*`, `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionBinding/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingNativeMapsTests.cpp`

  Record immutable native function/address/caller maps, preserving manual versus generated precedence and exact module/provenance identity. Apply through new native connection APIs with engine-owned state. Retain current configured backend; alternate transport is installed explicitly by tests, not by editing generated host files or engine installations.

  Cases: Manual binding wins an equivalent generated contribution; a placeholder can be completed by a real native address under existing rules; Add(2,3)=5 through configured transport; equivalent explicit alternate table succeeds; wrong module/version/signature and missing symbol fail with provenance; destroying one engine leaves the other map usable.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.
  > Proof: `attachments/data/verification-native-maps.md` — seven-case behavioral RED/GREEN, configured and explicit alternate transport, provenance validation, owner isolation, and final 228-case shared RuntimeBindings GREEN proof.

- [x] 6.5 Execute reflected UFunctions with typed argument and lifetime handling — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.Functions.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_PropertyBind.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_AngelscriptArguments.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFunctionsTests.cpp`

  Split reflection function preparation from engine-local callable installation. Capture typed signatures, parameter layouts, defaults and eligibility serially. Connect generic fallback through current VM and explicit receiver/owner, keeping manual/generated selection intact.

  Cases: Reflected Add(2,3)=5; FString value return and native struct return retain lifetime; out=7/inout 3->8; null receiver, incompatible object argument and invalid parameter direction diagnosed; generated method is selected over fallback when available; inherited function has correct receiver and owner; all captured eligible reflected methods accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-functions.md` — five-case behavioral RED with two controls, seven-case exact GREEN, typed argument/lifetime handling, diagnostics, generated dispatch, inheritance, defaults, accounting, and source/binary identities.

- [x] 6.6 Preserve static namespaces, mixin receivers and explicit world context — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.Mixins.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FunctionLibraryMixins*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptGameThreadScopeWorldContext*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMixinsTests.cpp`

  Record and install function-library static/mixin surfaces with world-context, determines-output and hidden-argument policy. Pass receiver/context explicitly and restore bounded scope even on failure.

  Cases: Static helper writes no unrelated receiver; object-first mixin mutates only selected fixture; missing required world context gives diagnostic; supplied transient world is observed; determines-output type matches intended object parameter; exception/failure restores previous explicit call scope without publishing an ambient default.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-mixins.md` — six-case behavioral RED/GREEN, namespace and mixin callable installation, receiver isolation, explicit scoped world context, determines-output identity, failure restoration, implicit-handle generic ABI, and source/binary identities.

- [x] 6.7 Migrate UObject pointer, subclass, weak and soft reference templates — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.Pointers.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SoftObjectPath*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSubclassOf.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingPointersTests.cpp`

  Complete TObjectPtr/TSubclassOf/TWeakObjectPtr/TSoftObjectPtr and soft path providers, with template argument constraints and engine-local UE reference operations. Reuse reflected class declarations and generic instance infrastructure.

  Cases: Correct subclass assignment succeeds and unrelated class rejected; strong reference retains fixture object; weak pointer becomes invalid after collection; soft path round-trips without loading an asset; null pointer operations follow existing contract; two owners share no mutable template operations; full pointer-family declarations accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-pointers.md` — five behavioral RED failures/two structural controls, seven-case GREEN, reflected class constraints, native wrapper lifecycle, GC behavior, owner isolation, full pointer-family accounting and source/binary identities.

- [x] 6.8 Migrate native delegate, multicast and Blueprint-event binding adapters — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Reflection.Delegates.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLatentActionInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintEventSignatureRegistry.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDelegatesTests.cpp`

  Complete Runtime delegate/event provider records and native/reflected callable adapters, explicit signatures/payload lifetime and per-engine event registry. This task does not implement the separate planned delegate-language feature or full script compilation.

  Cases: Native subscriber executes once; multicast invokes two distinct subscribers and removal prevents the removed call; payload survives caller frame then releases at unbind; reflected event argument/out signature matches fixture; wrong signature/owner rejected; destroying Engine releases subscriptions and registry entries without affecting another owner.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-delegates.md` — six-case unavailable-adapter RED, final six-case GREEN and 254-case shared RuntimeBindings proof for signatures, multicast removal, payload lifetime, reflected events and isolated owner teardown.

## 7. Runtime binding families

- [x] 7.2 Migrate collision structs, query parameters and world-collision bindings — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Collision.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CollisionProfile*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UCollisionProfile*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FOverlapResult*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBodyInstance*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingCollisionTests.cpp`

  Complete collision value/helper and reflected customization providers. Consume full geometry and reflection bridges; use a method-owned transient test world and native fixture components for actual queries. Preserve target guards and default query policy.

  Cases: Sphere shape radius 2 round-trips; query ignored actor collection copies independently; hit/overlap result properties match fixture values; empty transient world query returns no hits; invalid/null context produces current explicit error; every collision-family declaration and native recipe accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-collision.md` — valid two-case query-adapter RED with four controls, six-case exact GREEN, and 260-case shared RuntimeBindings proof for detached providers, value/property surfaces, reflected template lifecycles, diagnostics and transient-world execution.

- [x] 7.3 Migrate actor, component and scene/mesh customization providers — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AVolume*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UFXSystemComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPrimitiveComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPoseableMeshComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UProjectileMovementComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkeletalMeshComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkinnedMeshComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_LandscapeProxy*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingActorsTests.cpp`

  Complete manual/post-reflection actor/component/world and mesh customization records. Use transient worlds/objects, preserve static/generated precedence and no-default-startup behavior. Do not load gameplay maps or external assets.

  Cases: Spawn parameter fields round-trip; transient actor/component creation and transform setter/getter give known translation; world lookup returns fixture world; null/unregistered component follows existing contract; local destruction drains fixture objects; metadata/accounting verifies mesh/landscape/volume surfaces even where representative calls require no assets.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-actors.md` — staged setup, five-control/one-failure behavioral RED, final six-case exact GREEN, 20-case native-call regression proof, and 266-case shared RuntimeBindings GREEN without warnings or errors.

- [x] 7.4 Migrate input and widget customization surfaces — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.InputUI.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionKeyMapping*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionValue*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnhancedInputComponent*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingInputUITests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`

  Complete input event/value/mapping and widget providers. Use transient input objects and non-rendering fixture widgets; retain UE delegate ownership and target eligibility.

  Cases: Input value (1,2) preserves axes/type; action mapping copy preserves key/modifiers; bind/unbind handle affects exactly one callback; input event modifier flags round-trip; transient widget lookup/visibility property behaves as bound; callback resources release on teardown; no viewport/render profile required.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-input-ui.md` — staged detached-recording setup, six-case exact GREEN, exact 427-contribution/63-recipe surface, and 272-case shared RuntimeBindings GREEN.

- [x] 7.5 Migrate asset, registry and data-table binding surfaces — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Assets.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetBundleData*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetManagerScriptMixins*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetRegistry*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UAssetManager*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UDataTable*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingAssetsTests.cpp`

  Complete asset bundle/registry/manager/data-table providers and generated overrides. Tests use transient objects and in-memory rows, preserving global registry ownership and avoiding asset publication.

  Cases: Bundle data name/path copy survives original reset; valid transient table row round-trips known int/string values; missing row returns existing contract; soft/top-level asset paths round-trip; manager/registry surface and override precedence accounted without requiring disk assets; fixture modifications are cleaned up.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-assets.md` — staged setup, typed path hash/lifecycle repair, six-case exact GREEN, exact provider surface, and 278-case shared RuntimeBindings GREEN.

- [x] 7.6 Migrate JSON, native struct containers and memory-reader bindings — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Serialization.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_JsonObjectConverter*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInstancedStruct*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMemoryReader*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingSerializationTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`

  Complete JSON, JSON-to-struct, instanced native struct and memory-reader provider surfaces using real map/array/text dependencies and reflected native layouts. No cache/file service activation.

  Cases: Parse {"Count":7,"Name":"a"} and inspect literal fields; malformed JSON reports failure; round-trip a reflected fixture preserves Count=7; instanced struct copy is independent and destroys its value once; memory reader reads known byte/int sequence and rejects overrun; every provider declaration accounted.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-serialization.md` — detached namespace RED/repair, five behavior controls, exact 84-contribution/12-recipe surface, six-case exact GREEN, and 284-case shared proof.

- [x] 7.7 Migrate platform, path, file and parsing utility providers — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Platform.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FApp*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCommandLine*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGenericPlatformMisc*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformApplicationMisc*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformMisc*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformProcess*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFileHelper*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FParse*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingPlatformTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CoreGlobals.cpp`

  Complete platform/application/path/file/parser surfaces with recorded side effects and target policies. Test only read-only platform queries and method-owned temporary files, restoring any mutable process settings.

  Cases: Parse Count=7; normalize/join known path components using platform contract; temporary UTF text write/read returns same contents and cleanup removes only that file; missing file returns failure; command-line read is nonempty or matches captured host string; process-launch API metadata accounted without launching external processes.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-platform.md` — detached recording and exact-ABI repairs, six-case exact GREEN, exact 74-contribution/7-recipe surface, and 290-case shared proof.

- [x] 7.8 Migrate console, logging, profiling and debug utility providers — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Diagnostics.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Logging*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Stats*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCpuProfilerTraceScoped*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMessageDialog*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDiagnosticsTests.cpp`

  Complete diagnostic utility records and target/compile-out/native recipes. Keep invocation tests bounded: scoped console variables and temporary log sink; no visible dialog or debugger service startup.

  Cases: Scoped console int reads/writes 7 then restores/removes fixture variable; formatted log reaches test sink; compile-out policies distinguish Development/Shipping inputs; profiler scope balances entry/exit; unavailable Development-only console commands are excluded from Shipping with reason; dialog metadata preserves declaration without showing UI.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-diagnostics.md` — conditioned provider accounting, detached namespace/StaticJIT repairs, six-case exact GREEN, exact 62-contribution/1-recipe surface, and 296-case shared proof.

- [x] 7.9 Migrate subsystem, timer and explicitly contextual test-helper bindings — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Services.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest*.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingServicesTests.cpp`

  Complete service-facing binding declarations, including the existing `allow_discard` callable suffix used by test-helper builders, without starting default script services or legacy test pools. Timer and subsystem tests use a transient owned world/game-instance where required. Existing Runtime script-test helper functions remain explicit-context calls, not legacy Automation activation.

  Cases: Fixture timer fires once then cancellation prevents further calls; subsystem lookup uses fixture world and wrong/null context follows current error; game-instance/local-player records are complete; Runtime test-helper call without active script-test context returns its explicit diagnostic; all timer/context resources are released.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-services.md` — detached service recording, callable `allow_discard` parsing, exact 226-contribution/12-recipe accounting, five-case exact GREEN, and 301-case shared proof.

- [x] 7.10 Apply ToString, skip policy and finalization contributions explicitly — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Finalization.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ConfigEnums*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Deprecations*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_ToString.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFinalizationTests.cpp`

  Translate all ToString, skip/exclusion, deprecation and finalization contributions to detached recipes or explicit engine-owned installation actions. Account for DirectBindArchitectureProbe and Runtime test helpers under actual active conditions. No ReplayOnly fallback to legacy Register*; no dynamic module-load update.

  Cases: Each contributed ToString formatter produces known fixture text and is isolated across owners; skip rules preserve manual/generated/reflection precedence; config enums/deprecations reflect target policy; no eligible finalizer is left unclassified; finalization failure identifies provider and aborts fresh Engine publication.

  1. Prepare these cases and run the exact selection together; record the missing behavior demonstrated by RED and distinguish existing regression controls.
  2. Implement the outcome and required consumer wiring, preserving dormant startup and ownership.
  3. Build through Harness and rerun for GREEN. Record complete case paths, source/binary identity and report; shared proof maps every case to this task.

  > Proof: `attachments/data/verification-finalization.md` — typed effect installation, exact 45/5/4/12/1 accounting, five-case exact GREEN, and 306-case shared RuntimeBindings proof.

## 8. Whole-surface verification and closure

- [x] 8.2 Prove complete provider accounting and publish fresh full Runtime Engines — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Coverage.FullRuntime.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFullRuntimeTests.cpp`, `openspec/changes/angelscript/feature-runtime-binding-record-apply/attachments/data/provider-inventory.md`

  Finish the fresh-snapshot CreateForBindings overload and make coverage compare static inventory, runtime provider collection and installed declaration/effect accounting. Every eligible provider is installed; exclusions name actual target/module conditions. Source inventory contains 253 declarations/247 distinct names, including mutually exclusive branches, so raw counts are not the oracle. Later module loads require a new snapshot. Emit 1.6 JSON/CSV manifests and join source inventory, Collection, recorded expected members/effects and installed results. Classify compiled-out, policy-excluded, intentional no-output and unsupported/unaccounted entries with evidence. Run 1.7 Python validation against the actual full-runtime manifest and independent family expectations, and diff same-input captures for semantic equality. Retain complete artifacts, commands, exit codes and build/policy/source provenance under the Harness run, plus a bounded durable summary/hash. This node is integration only; it cannot become a bucket for unmigrated families.

  Cases: Full selected Runtime snapshot creates a usable owner; every eligible provider and expected output accounted; missing expected member/unknown provider fails even when counts match; intended AS types match installed definitions and captured-only UE identities stay separate; partial/collection-only output cannot satisfy full-runtime acceptance; target policy fixtures distinguish Editor/Game and Development/Shipping; no unsupported Register* replay; fresh full Engine executes vector/string/container/reflected representative calls; induced finalization/native-binding failure returns no owner with source diagnostic.

  1. Prepare full-snapshot coverage cases before enabling the full factory and observe missing-surface RED.
  2. Complete only full-factory wiring/accounting; return missing family behavior to its owning task, adding a follow-up ID if that task is completed.
  3. Run this selector and full `Angelscript.UnitTest.RuntimeBindings.` on the final binary and retain every result.

  > Proof: `attachments/data/verification-full-runtime.md` — exact 267-provider reconciliation, two independent full owners, representative installed execution, repeated deterministic 52.6 MB manifest capture/validation, two six-case exact GREEN runs, and 312-case final-content RuntimeBindings GREEN.

- [x] 8.3 Preserve dormant startup and replacement test ownership — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp`, `.agents/skills/angelscript-test-guide/SKILL.md`, `openspec/changes/angelscript/feature-runtime-binding-record-apply/attachments/data/final-verification.md`

  Run the existing dormant baseline after complete binding installation tests and document explicit-owner RuntimeBindings fixture guidance. Preserve default subsystem inactivity, legacy gates and absent old test namespaces. Record full RuntimeBindings final-content proof alongside baseline, reusing only matching source/binary evidence.

  Cases: Default subsystem remains engine-free and non-ticking; explicit binding creation does not publish ambient owner; old test namespaces remain undiscovered; JIT/debug/cache services remain unregistered as defined by baseline; replacement test public paths exclude physical NewVersion.

  1. Inspect required final-content evidence and run the exact proving selection. Existing baseline/native behavior is regression proof, not newly claimed RED.
  2. Resolve ordinary failures in the owning implementation outcome and refresh proof. Complete only when every named condition is proven.

  > Proof: `attachments/data/final-verification.md` — final-binary three-case baseline GREEN with documented unrelated UE MetaSound registry warnings and explicit dormant-runtime/legacy-namespace ownership.

- [x] 8.4 Verify shared frontend, metadata and VM contracts after full migration — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `openspec/changes/angelscript/feature-runtime-binding-record-apply/attachments/data/final-verification.md`

  Run current NativeEngine regression on the final binary. A complete NativeEngine selection is justified here by modifications to shared declaration type identities, metadata layouts/freeze/installation, template instances and native calls consumed throughout that suite; this is not a daily unconditional gate. Fix an ordinary regression in its owning implementation task with focused RED/GREEN and refresh affected proof before this node completes.

  Cases: All discovered NativeEngine cases execute with a complete validated report; no new failure in declaration identity, frozen images, template layouts, native ABI or callable lifetime; missing/not-run cases and crashes fail acceptance. Prior historical reports cannot supply final-content proof.

  1. Inspect required final-content evidence and run the exact proving selection. Existing baseline/native behavior is regression proof, not newly claimed RED.
  2. Resolve ordinary failures in the owning implementation outcome and refresh proof. Complete only when every named condition is proven.

  > Proof: `attachments/data/final-verification.md` — complete final-binary NativeEngine report with 1,080/1,080 GREEN, zero warnings/errors/skips/not-run, alongside 312/312 RuntimeBindings GREEN.

- [x] 8.5 Synchronize durable behavior and close the completed Change — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-runtime-binding-record-apply','--strict')`
  > Files: `openspec/changes/angelscript/feature-runtime-binding-record-apply/**`, `openspec/specs/angelscript/bindings/runtime/**`, `openspec/specs/angelscript/runtime/binding-engine/**`, `openspec/specs/angelscript/testing/baseline/**`, `openspec/changes/angelscript/archive/*feature-runtime-binding-record-apply/**`

  Verify the full RuntimeBindings final source/binary proof, all task-specific evidence and complete inventory. Synchronize the three deltas while preserving unspecified baseline cards, record terminal evolution evidence, then close and archive with lifecycle Skills. Strict archived validation follows the deterministic move. No review, commit, push or reference-workspace integration is implicitly requested.

  Cases: Every current DAG node has exact passing evidence; full RuntimeBindings and native/baseline reports are complete; synchronized specs validate; INDEX has exactly one entry per attachment; no active issue/review remains; terminal evolution and archived structural checks pass. Performance, legacy suites, packaging and JIT execution remain omitted with scope reasons.

  1. Inspect required final-content evidence and run the exact proving selection. Existing baseline/native behavior is regression proof, not newly claimed RED.
  2. Resolve ordinary failures in the owning implementation outcome and refresh proof. Complete only when every named condition is proven.

  > Proof: all three delta capabilities were synchronized into current specs; strict current-spec validation passed 22/22 and strict active-change validation passed 1/1 before the required terminal evolution gate and deterministic archive move.
