# Bind Reviewability and Test Issue Ledger

This is the resumable evidence record for `improve-as-bind-reviewability-and-tests`. Add later project-owned Bind findings here before or alongside their code/test changes. Keep `tasks.md` as the clean execution checklist.

## Status Model

- `Observed`: A concrete symptom or gap has been reported but not yet confirmed against implementation.
- `Confirmed`: Source/test evidence confirms the issue and its scope.
- `Designing`: The issue is understood but its presentation or implementation decision is still under review.
- `Implementing`: Source or test changes exist but required verification or review is incomplete.
- `Verified`: The implemented result has fresh, recorded verification appropriate to its risk.
- `Deferred`: The issue is valid but intentionally postponed, with a stated reason and resumption trigger.

## Scope Routing

Keep an issue here when it concerns a project-owned `Bind_*.cpp` family, its registrar-local documentation or helper ownership, an implementation-time ownership audit, the existing Actor provider-lambda regression, or a focused AS-visible binding contract test. Split a focused follow-up OpenSpec when it requires a public behavior contract, shared binding architecture, UHT/generated-binding format, StaticJIT architecture, native-module transport, or broad test-harness redesign.

## Issue Template

```markdown
## <ID>: <Outcome-oriented title>

- Status: Observed | Confirmed | Designing | Implementing | Verified | Deferred
- Scope: <paths or Bind family>
- Evidence: <source/test/runtime observation>
- Decision: <accepted direction or explicit open decision>
- Implementation: <changed paths or "not started">
- Test layer: Source layout | Bindings CQTest | Coverage | Functional | StaticJIT/AOT | Documentation only
- Verification: <fresh command/report, or "not run">
- Next: <one resumable action>
```

## BIND-001: Keep Actor registrar phase and provider body locally visible

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`
- Evidence: Named provider functions separated the `FAngelscriptBind` logical name and phase from the binding body, making `ManualBindings` versus `PostReflectionBindings` harder to review in one location. Anonymous namespace linkage did not prevent UE Automation discovery; the reviewability concern was source locality rather than test registration.
- Decision: Use non-capturing outer lambdas taking `FAngelscriptBinds&` directly at the two Actor registrars. Keep actual AS-callable bodies in `FAngelscriptActorBinds` or existing pointer/native forms.
- Implementation: `Bind_AActor` now carries `AActor.Manual` and `ManualBindings` beside its provider body; `Bind_Actors` carries `AActor.PostReflection` and `PostReflectionBindings` beside its reflected-type loop.
- Test layer: Source layout.
- Verification: Plugin builds passed in `Saved/Build/actor-outer-bind-lambda/20260808_201204_437_fdc0fbe3/Build.log` and `Saved/Build/actor-outer-bind-lambda-test-guard/20260808_201451_048_f512bf6e/Build.log`. The focused source-layout report passed `28/28` at `Saved/Tests/actor-outer-bind-lambda-green/20260808_201515_107_c93d4028/Report/index.json`.
- Next: Preserve the verified Actor provider form while the finite 120-registrar documentation and 96-header migrations proceed.

## TEST-001: Distinguish provider lambdas from direct AS-callable lambdas

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindSourceLayoutTests.cpp`
- Evidence: The direct-callable-lambda regex initially treated the new outer Actor provider lambda as a forbidden inline AS callable, producing `27/28` instead of `28/28` source-layout passes.
- Decision: Exclude a non-capturing lambda whose parameter begins with `FAngelscriptBinds&` from the direct-callable detector while retaining the guard for lambdas supplied to production callable registration APIs.
- Implementation: The detector uses a negative lookahead for `FAngelscriptBinds&`; Actor sections are extracted by the `AActor.Manual` and `AActor.PostReflection` registrar tokens and checked for phase/callback locality.
- Test layer: Source layout.
- Verification: Focused source-layout result `28/28 PASS` at `Saved/Tests/actor-outer-bind-lambda-green/20260808_201515_107_c93d4028/Report/index.json`.
- Next: When a new provider form appears, classify it by semantic role before widening or tightening the regex.

## DOC-001: Provide a script-facing Actor API surface summary

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`
- Evidence: Registration strings are authoritative but scanning them does not quickly reveal the complete member/global/generated factory surface or the purpose of internal and overloaded helpers.
- Decision: Keep one file-head two-column table containing the AngelScript usage signature and purpose. Use `Actor.` for instance calls, `Actor::` for namespace functions, `<ActorType>::` for generated factories, `;` terminators, parameter wrapping for long signatures, and a separator after each logical entry.
- Implementation: The current Actor table contains the manual and post-reflection surfaces, wraps long declarations by parameter, terminates declarations with `;`, uses one separator per logical function, and keeps a 96-character signature column beside a wider documentation column.
- Test layer: Documentation only.
- Verification: Repeated `git diff --check` and deterministic table-alignment checks passed during the formatting iterations; no UE build was run for comment-only changes.
- Next: Use the table as the semantic reference for all 120 registrar files while allowing each family to document its actual static or dynamic surface rather than copying Actor-specific rows or geometry.

## DOC-002: Explain non-obvious script parameters without restating obvious ones

- Status: Verified
- Scope: `Bind_AActor.cpp` file-head table as the single binding-documentation owner.
- Evidence: Function-level Purpose text does not explain wildcard output type inference, class/output compatibility, append semantics, deferred-spawn obligations, `ULevel` resolution, explicit spawn transforms, or the difference between `AActor::Tags` and GameplayTags.
- Decision: Use Doxygen-style `@param ParameterName Description` notes for complex parameters in the script-facing file-head table. Keep each note on one physical row when it fits and wrap only when necessary. Pack Purpose and `@param` lines continuously from the top of the right column instead of inserting gaps to align with left-column parameters. Skip redundant notes for self-evident values unless a boolean changes a lifecycle protocol; `bDeferredSpawn` therefore still needs documentation. Do not duplicate this binding-facing documentation in `Bind_AActor_Functions.h`.
- Implementation: The `Bind_AActor.cpp` table now carries the sole compact right-column Doxygen-style block for wildcard outputs, explicit class constraints, Actor Tags, spawn class/name/defer/level behavior, and deferred-spawn completion. Notes that fit stay on one physical row; only descriptions wider than the documentation column continue onto the next row. `Bind_AActor_Functions.h` has been reverted to declarations only.
- Test layer: Documentation only.
- Verification: Native semantics were confirmed against `Bind_AActor_Functions.cpp`, including `ResolveWildcardArrayElementClass`, `ResolveSpawnLevel`, deferred construction, append behavior, and error paths. A fresh table check reported `26` entries, `28` separators, `20` `@param` rows, compact right-column documentation blocks, the expected `<ActorType>::Spawn` layout, uniform `198`-character table rows, and clean `git diff --check`.
- Next: Apply this single-owner presentation rule to the remaining 119 registrar files and reconcile each row in `bind-documentation-audit.md`.

## STYLE-001: Preserve readable fluent registration chains

- Status: Verified
- Scope: `Bind_AActor.cpp` and later touched Bind families.
- Evidence: Fluent traits such as `DeterminesOutputType` and `PassScriptFunctionAsFirstParam` carry binding semantics and are easier to review when visually chained to the registration result.
- Decision: Keep the registration call and its fluent traits as one chain with each continuation on its own indented line. Do not detach a trait from the binding that produced its `FAngelscriptBoundFunction`.
- Implementation: Actor spawn registrations chain `.DeterminesOutputType(0)`; reflected factories chain `.PassScriptFunctionAsFirstParam()`.
- Test layer: Source layout when an objective ownership/association invariant needs protection; otherwise code review.
- Verification: The final plugin build passes at `Saved/Build/bind-family-ownership-refactor-iwyu/20260809_020255_921_7c29613e/Build.log`; Actor PropertyInterface passes `7/7`, full Bindings `275/275`, and the final All suite `2521/2521`. Final diff review found no detached fluent trait or broken chain association.
- Next: Preserve this review rule in future Bind changes; do not turn visual formatting into a permanent unit test.

## DOC-003: Keep Actor binding documentation at the `FAngelscriptBind` definition site

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, canonical `Bind_AActor.h`, and `Bind_AActor_Functions.cpp`.
- Evidence: Adding a purpose comment to every native helper created a second binding-documentation catalogue separated from the `FAngelscriptBind` registrations and script-facing declarations. Review selected one source of truth at the actual registrar definition site, and the helper comments were reverted from `Bind_AActor_Functions.h`.
- Decision: Keep all Actor binding-facing purpose and parameter documentation in the file-head block of `Bind_AActor.cpp`, where the actual `FAngelscriptBind` definitions live. The verified comment rollback remains valid, but the declarations-only endpoint is superseded by the final family topology: move declarations into `Bind_AActor.h`, delete `Bind_AActor_Functions.h`, and keep native bodies in `Bind_AActor_Functions.cpp`. Neither the canonical family header nor implementation file may duplicate the script API catalogue.
- Implementation: `Bind_AActor.cpp` owns the two-column script-facing table and Doxygen-style parameter notes; declarations live in canonical `Bind_AActor.h`; native bodies remain in `Bind_AActor_Functions.cpp`; the legacy header is deleted and neither remaining file duplicates the catalogue.
- Test layer: Documentation only.
- Verification: Final static audit reports one registrar-owned table, zero duplicate catalogues, zero legacy header/reference matches, and 102/102 matching registrar first-header includes. The final build, Actor `7/7`, Engine Hooks `4/4`, StaticJIT NativeForms/AOT `16/16`, Bindings `275/275`, and All `2521/2521` pass.
- Next: Keep future binding-facing comments at the registrar definition site and implementation-only comments beside native algorithms.

## TEST-002: Inventory missing AS-visible contract smoke for reviewed Bind families

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptTest/Bindings/`, relevant Coverage/Actor tests, and later reviewed Bind families.
- Evidence: Source-layout coverage proves authoring structure but does not by itself prove that every reviewed declaration compiles in AS, resolves the intended overload/wildcard behavior, invokes the native path, or reports focused invalid-input failures.
- Decision: Before adding tests, inventory the reviewed Bind surface against existing Bindings, Coverage, functional, and StaticJIT/AOT coverage. Add only the smallest missing Bindings contract smoke; route semantic matrices to their owning layer.
- Implementation: The Actor table was mapped to the existing PropertyInterface matrix, which already covers typed/static spawn, ordinary/deferred/persistent spawn, both finish overloads, inferred/explicit/tag queries, properties, UFUNCTIONs, and UPROPERTYs. The 120-row registrar inventory maps every family to its owning Bindings/Coverage/Functional/StaticJIT layer. No redundant contract case or filename/include-shape test was added.
- Test layer: Bindings CQTest first, with Coverage/Functional/StaticJIT routing based on the discovered gap.
- Verification: Actor PropertyInterface passes `7/7`, full Bindings `275/275`, StaticJIT NativeForms/AOT `16/16`, and final All `2521/2521`, all with zero failures/skips. The separately run Coverage suite completed `1021/1022`; its sole failure is an unrelated unchanged UPARAM negative-test diagnostic-text expectation, not a bind contract gap.
- Next: Add future tests only when a reviewed AS-visible behavior lacks owning coverage; keep source naming/comment layout out of the permanent test contract.

## BIND-002: Apply the registrar documentation rule to the finite 120-file inventory

- Status: Verified
- Scope: Later project-owned `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.cpp` families and their focused tests.
- Evidence: The Actor iterations established a reviewable combination of local phase/provider visibility, explicit fluent chains, a registrar-owned two-column script surface, compact Doxygen-style parameter notes, single-owner declarations, and provider-lambda classification. Additional Bind families are expected to reveal similar and new issues.
- Decision: Migrate every real registrar recorded in `bind-documentation-audit.md`. Actor supplies the semantic layout and documentation-ownership rule, but families list their actual static declarations or stable dynamic patterns rather than mechanically copying Actor rows, prose, width, or wrapping. Keep binding-facing documentation at the actual `FAngelscriptBind` definition site and route real test gaps to the owning layer.
- Implementation: All 120 real registrar files now own exactly one file-head two-column AngelScript surface catalogue; the final audit records 2,979 logical entries and 1,052 non-obvious `@param` notes.
- Test layer: Selected per issue before implementation.
- Verification: Final static audit reports 120/120 documented, zero missing/duplicate/late markers, zero width/lone-parenthesis/multi-declaration/generic-purpose/duplicate-catalogue findings, and clean `git diff --check`. The final build and All/Bindings suites pass.
- Next: Use the same registrar-owned documentation rule when later Bind files change, updating the actual surface rather than adding structural comment tests.

## BIND-003: Remove the obsolete `__Actor_GetAllByClass` internal entry point

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`, `Bind_AActor_Functions.h`, `Bind_AActor_Functions.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`, and `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorPropertyInterfaceTests.cpp`.
- Evidence: A repository-wide exact-symbol search found no project script or active generated-code consumer. The only preprocessor occurrence is inside the disabled `/* ... */` generated `GetAll` block at `AngelscriptPreprocessor.cpp:1306-1312`. The only executable AS call is the `InternalClassActors` branch at `AngelscriptActorPropertyInterfaceTests.cpp:540-543`, which directly tests this internal symbol. Runtime ownership consists only of the table row and global registration in `Bind_AActor.cpp`, the `GetAllActorsByClassUnchecked` declaration/definition, and that helper's direct `UGameplayStatics::GetAllActorsOfClass` call; its injected `TypeId` is unused. `git log -S"__Actor_GetAllByClass"` found only the initial plugin snapshot import, with no later consumer or compatibility work.
- Decision: Remove the AS global registration, the `GetAllActorsByClassUnchecked` native declaration and definition, the file-head table row, the disabled preprocessor `GetAll` stub containing the internal call, and only the direct `InternalClassActors` assertion branch. Preserve the containing `InterfaceSpawnAndQuery` test and its supported public calls to inferred `GetAllActorsOfClass`, explicit-class `GetAllActorsOfClass`, and `GetAllActorsOfClassWithTag`. This evidence-gated decision applies to the internal `__` implementation detail and is not a precedent for removing supported public bindings merely because the repository has no call site.
- Implementation: The registration/table row, native declaration/definition, disabled preprocessor stub, and internal-only test branch are removed while the containing public-query fixture and all three supported GetAll paths remain.
- Test layer: Functional Actor plus source inspection; no replacement test is needed for the removed internal symbol because the supported public query paths remain exercised in the same fixture.
- Verification: Exact final search finds zero `__Actor_GetAllByClass` / `GetAllActorsByClassUnchecked` matches. The final build passes; Actor PropertyInterface passes `7/7`, SourceLayout `28/28`, Bindings `275/275`, and All `2521/2521`.
- Next: None for this obsolete internal entry point; retain and test the supported public query paths.

## BIND-004: Delete the compatibility-only `Bind_Actor.h` include shim

- Status: Verified
- Scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Actor.h`, `StaticJIT/StaticJITHelperFunctions.h`, `Source/AngelscriptTest/Core/AngelscriptEngineHooksTests.cpp`, and active documentation that still recommends `Bind_Actor.h`.
- Evidence: `Bind_Actor.h` contains no binding, registrar, helper implementation, or `FAngelscriptType`; it only forwards to `Bind_AActor_Functions.h`. Exact repository search found two active include consumers: `StaticJITHelperFunctions.h` and `AngelscriptEngineHooksTests.cpp`. Both use the exported `FAngelscriptActorBinds` owner defined by `Bind_AActor_Functions.h`. Editor CodeGen tests mentioning generated `Bind_Actor.cpp`/`Bind_Actor(...)` do not include or depend on this header. Git history shows the shim was retained by the 2026-08-08 direct-callback migration rather than required by a later compatibility fix.
- Decision: Delete `Bind_Actor.h`. The intermediate cleanup replaces both active includes with `Binds/Bind_AActor_Functions.h`; the final 96-header migration moves declarations to canonical `Bind_AActor.h`, retargets consumers, and deletes `Bind_AActor_Functions.h`. Preserve the `FAngelscriptActorBinds` name, export, functions, native/trivial classification, generated C++ callable spelling, and generated CodeGen `Bind_Actor.cpp` contract. Update current guidance, but do not rewrite historical migration records that accurately describe why the shim once existed.
- Implementation: `Bind_Actor.h` and `Bind_AActor_Functions.h` are deleted; both active consumers include canonical `Binds/Bind_AActor.h`; the exported owner name and native bodies are preserved. No filename/include-only assertion was added or retained as a new contract.
- Test layer: Implementation-time exact include/symbol audit, Runtime build, C++ Engine Hooks behavior, the existing Actor provider-lambda regression, and StaticJIT NativeForms callability.
- Verification: Exact final search finds zero old-header paths/references; the final build passes; Engine Hooks `4/4`, SourceLayout `28/28`, StaticJIT NativeForms/AOT `16/16`, Bindings `275/275`, and All `2521/2521` pass.
- Next: Preserve `Bind_AActor.h` as the single Actor declaration entry point.

## ARCH-001: Give every non-Blueprint concrete Type adapter canonical family ownership

- Status: Verified
- Scope: Every concrete registered adapter in `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/`, except the four explicitly deferred Blueprint object adapters.
- Evidence: The complete scan records 82 Type-like declarations across 46 files: 71 concrete registered adapters, four family-private bases/templates, and seven shared helper templates. Four concrete adapters remain deferred in `Bind_BlueprintType.cpp`, leaving 67 mandatory concrete migrations. Ownership is inconsistent: `FAngelscriptArrayType` is declared in `Bind_TArray.h`, Map/Set primary and iterator adapters live inside registrar `.cpp` files, reusable templates correctly live in `Helper_*Type.h`, and scalar adapters remain local.
- Decision: Move every mandatory concrete adapter declaration into canonical `Bind_<Family>.h` and every out-of-line Type implementation into `Bind_<Family>_Type.cpp`, including scalar families. Group tightly related primary/iterator/base adapters by family. Preserve registrars, phases, callable registration, documentation, native forms, TypeDB ownership, GC/property semantics, and existing export visibility. Keep shared `Helper_*Type.h` templates header-only; move family-local Primitive templates into `Bind_Primitives.h`. Do not misclassify `FAngelscriptActorBinds` as a Type.
- Implementation: All mandatory adapters are extracted into 41 family `_Type.cpp` files with declarations in canonical headers; only the four explicitly deferred Blueprint object adapters remain in `Bind_BlueprintType.cpp`.
- Test layer: Implementation-time declaration/definition ownership audit, independent Runtime build/TU coverage, Engine TypeUsage/TypeRegistry/TypeDatabase, family-specific Bindings and Coverage suites, and StaticJIT NativeForms.
- Verification: Static reconciliation reports 41/41 canonical Type includes, zero Type registrars, zero empty Type implementations, 489/492 token-exact moved out-of-line methods plus three behavior-equivalent FName rewrites, and 168/168 token-exact inline/template bodies. The final build, TypeUsage `5/5`, TypeRegistry `1/1`, TypeDatabase `3/3`, StaticJIT `16/16`, Bindings `275/275`, and All `2521/2521` pass.
- Next: Move the four deferred Blueprint adapters only in a separate high-risk change with reflection/property/type-lookup/hot-reload coverage.

## ARCH-002: Collapse 96 callable headers into canonical family headers

- Status: Verified
- Scope: All 96 `Bind_*_Functions.h` files in `AngelscriptRuntime/Binds`, their 95 matching `_Functions.cpp` files, existing `Bind_<Family>.h` collisions, and audited support headers.
- Evidence: Callable declarations currently live behind a `_Functions.h` suffix while registrars live in `Bind_<Family>.cpp`, and Type declarations are planned for yet another header family. The snapshot contains 96 legacy callable headers, 95 callable implementation files, 120 registrar files, and 11 existing non-`_Functions.h` Bind headers.
- Decision: Use one `Bind_<Family>.h` as the declaration entry point. Delete every `_Functions.h` rather than keeping forwarding shims; keep registrar definitions/documentation in `Bind_<Family>.cpp`, out-of-line native bodies in `_Functions.cpp`, and out-of-line Type bodies in `_Type.cpp`. Merge with an existing family header instead of creating a competing facade. Create no empty implementation file. Retain support headers only with audited distinct responsibility and consumers.
- Implementation: All 96 legacy callable headers are consolidated into canonical family headers and deleted; 95 existing `_Functions.cpp` files keep their native bodies, while TArray keeps required visible templates in `Bind_TArray.h` without an empty implementation file.
- Test layer: Implementation-time 96-header/include audit and diff review, Runtime non-unity build, family Bindings/Coverage behavior, Engine Hooks, and StaticJIT for exported/native callable consumers.
- Verification: Final static audit reports legacy headers/references `0/0`, canonical `_Functions.cpp` includes `95/95`, canonical family headers `96/96`, and matching registrar first-header includes `102/102`. The final build, Bindings `275/275`, All `2521/2521`, and Standalone `19/19` pass; the rejected canonical-filename test is absent.
- Next: Keep canonical family headers as declaration owners and verify future changes through build and behavior tests, not filename-shape automation.

## BIND-005: Make every production Bind provider registrar-local

- Status: Verified
- Scope: Only production `Bind_*.cpp` registrars under Runtime, AngelscriptGameplayTags, and AngelscriptGAS, as exhaustively listed in `bind-provider-lambda-audit.md`. The scope is 126 registrar files, 242 logical registrars, and 245 source definitions; `Bind_UStruct.cpp` accounts for the three definition-only duplicates across `AS_USE_BIND_DB` branches.
- Evidence: Fresh source inspection finds five direct non-capturing provider lambdas (two Actor and three GameplayTags) and 240 named provider callback pointers. The optional plugins are explicitly included; no optional-plugin documentation/header/Type migration is implied.
- Decision: Expand only the provider body at the existing `FAngelscriptBind` definition. Preserve registrar symbols, logical names, phases, direct AngelScript callable owners, pointer/native forms, and behavior. A wrapper lambda that only calls the prior `BindXxx(Binds)` function is not acceptable. Retain anonymous namespaces that still own private constants/helper types/reusable algorithms and remove them only when empty.
- Conditional rules: Keep both existing `Bind_UStruct` branch-specific definitions for each of its three registrar identities. For `Bind_BlueprintType`, keep each large DB/non-DB body in its current branch and place a same-identity direct lambda registrar in each branch; each build configuration compiles only one branch.
- Test layer: No Core `BindingArchitecture.SourceLayout` assertion was added or adapted. The affected GAS source-shape assertion that incorrectly treated a provider lambda as a direct callable lambda was removed. Verification uses source audit/static reconciliation and behavior-owning suites.
- Verification: Static audit reports `126/242/248/248/0` (files/logical/source definitions/direct lambdas/named-or-forwarding providers). `Tools/RunBuild.ps1 -Label bind-provider-lambdas-final -TimeoutMs 1800000 -NoXGE` passed at `Saved/Build/bind-provider-lambdas-final/20260809_102713_149_b82dee28/Build.log`. Focused behavior tests passed with zero failures/skips: Bindings `275/275` at `Saved/Tests/bind-provider-lambdas-bindings/20260809_102143_572_36adaf4a/Summary.json`, GAS `252/252` at `Saved/Tests/bind-provider-lambdas-gas-final/20260809_102731_540_91bee472/Summary.json`, and GameplayTags `15/15` at `Saved/Tests/bind-provider-lambdas-gameplaytags/20260809_102533_350_0d076c73/Summary.json`. `openspec validate improve-as-bind-reviewability-and-tests --strict` passes. The three BlueprintType branch-local additions are recorded in the audit.
- Next: Deliver changed submodules first, then update the parent gitlinks and this OpenSpec record.
