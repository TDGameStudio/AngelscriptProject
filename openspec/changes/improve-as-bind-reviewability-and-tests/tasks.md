## 1. Record and Freeze the Finite Inventories

- [x] 1.1 <!-- Non-TDD --> Record the Actor registrar-local lambda conversion, source-layout provider-lambda distinction, file-head table format, single documentation-owner decision, and initial verification evidence.
- [x] 1.2 <!-- Non-TDD --> Rewrite proposal/design/spec/tasks to require the finite 120-registrar documentation migration, 96-header consolidation, and all non-Blueprint concrete Type-adapter migrations; remove optional-pilot, tiny-adapter, `_Functions.h`, and separate Type-header exceptions.
- [x] 1.3 <!-- Non-TDD --> Create `bind-documentation-audit.md` with every real registrar file, registrar names/phases, surface kind, documentation status, existing test prefix, and gap status; freeze the current baseline at 120 files with 1 documented and 119 pending.
- [x] 1.4 <!-- Non-TDD --> Expand `type-ownership-audit.md` into the authoritative family matrix: 96 legacy `_Functions.h` headers, all concrete adapters and bases/templates, target canonical header, target `_Type.cpp`, export/template/cross-TU constraints, support-header disposition, risk, and owning tests.

## 2. Actor Cleanup and Canonical Family Endpoint

- [x] 2.1 <!-- TDD --> Keep `AActor.Manual` and `AActor.PostReflection` as registrar-local non-capturing `FAngelscriptBinds&` provider lambdas; keep direct AS callables on `FAngelscriptActorBinds`; update the source-layout guard to distinguish the two lambda roles. Fresh verification is already recorded in BIND-001/TEST-001.
- [x] 2.2 <!-- TDD --> Implement removal of `__Actor_GetAllByClass` and `GetAllActorsByClassUnchecked` across the registration, helper declaration/definition, file-head row, disabled preprocessor stub, and internal-only test branch while retaining all supported public query paths. Keep BIND-003 `Implementing` until build/test evidence is recorded.
- [x] 2.3 <!-- TDD --> Implement the intermediate `Bind_Actor.h` cleanup by changing its two active consumers to `Binds/Bind_AActor_Functions.h` and deleting the compatibility-only header without changing Editor CodeGen naming. Keep BIND-004 `Implementing` until build/test evidence is recorded; any current filename/include-shape assertion is not part of the accepted final test contract.
- [x] 2.4 <!-- TDD --> During the 96-header migration, move `FAngelscriptActorBinds` declarations into the canonical `Bind_AActor.h`, retarget all consumers from `Bind_AActor_Functions.h`, delete that legacy header, preserve the existing `Bind_AActor_Functions.cpp` callable implementations/native-form spelling, and remove or avoid long-term tests that assert only the header/include shape.
- [x] 2.5 <!-- TDD --> Map the final Actor surface to Bindings/Functional/Coverage/StaticJIT tests and add only the smallest missing declaration, wildcard, overload, spawn, or failure contract coverage. The retained `PropertyInterface` matrix already covers typed/static spawn, ordinary/deferred/persistent spawn, both finish overloads, and inferred/explicit/tag queries; no filename/include-shape test or redundant contract case was added.
- [x] 2.6 <!-- Non-TDD --> Final exact searches report zero `__Actor_GetAllByClass`, `GetAllActorsByClassUnchecked`, `Bind_Actor.h`, `Bind_AActor_Functions.h`, or other legacy `_Functions.h` references. `git diff --check` exits `0`; the Runtime/Editor build passes; SourceLayout passes `28/28`, Actor PropertyInterface `7/7`, Engine Hooks `4/4`, and StaticJIT NativeForms `4/4`. The full Actor and Bindings surfaces also pass inside the final All/Bindings suites. BIND-003/BIND-004 are Verified in `issues.md`.

## 3. Registrar Documentation Migration — 120 Files

- [x] 3.1 <!-- Non-TDD --> Maintain an implementation-time static audit that discovers every real registrar `.cpp`, reconciles the frozen 120 rows, and reports any missing surface block before delivery. Do not add a permanent comment-marker or canonical-filename SourceLayout unittest; retain only the already-verified Actor provider-lambda regression.
- [x] 3.2 <!-- Non-TDD --> Migrate every remaining static registrar in lexical order, listing the complete stable AS types, enums, constructors, properties, constants, methods, mixins, globals, and overloads with actual script spelling and compact Purpose/`@param` notes.
- [x] 3.3 <!-- Non-TDD --> Migrate dynamic/reflection/table-driven registrars with stable script pattern rows and explicit runtime-expansion notes while still listing every static declaration exactly.
- [x] 3.4 <!-- Non-TDD --> Reconcile all 120 audit rows, confirm every real registrar is documented exactly once and no family header, `_Functions.cpp`, `_Type.cpp`, or support header duplicates the catalogue, then record exact static inspection and `git diff --check` evidence. The final audit found 2,979 logical entries and 1,052 `@param` notes with zero marker, placement, width, orphan-parenthesis, multi-declaration, generic-purpose, or duplicate-catalogue findings.

## 4. Canonical Family Headers — 96 Legacy `_Functions.h` Files

- [x] 4.1 <!-- Non-TDD --> Capture the exact 96-header baseline and maintain an implementation-time static audit that reports remaining `Bind_*_Functions.h`, unresolved canonical family includes, and unaudited support headers. Do not add a permanent canonical-header/include-shape unittest.
- [x] 4.2 <!-- TDD --> Consolidate callable-only families in lexical batches: move declarations and required visible templates from each `_Functions.h` into `Bind_<Family>.h`, update all consumers, preserve exports and callable spelling, retain out-of-line bodies in `_Functions.cpp`, and delete the legacy header.
- [x] 4.3 <!-- TDD --> Merge families that already own `Bind_<Family>.h` rather than creating competing facades; explicitly cover Actor, Console, Debugging, TArray, and any other collision discovered by the frozen inventory.
- [x] 4.4 <!-- TDD --> For `Bind_TArray_Functions.h` and any other template-heavy header without an existing `_Functions.cpp`, keep required template/inline definitions in the canonical family header and create no empty `_Functions.cpp`; move only real out-of-line callable bodies when such a responsibility exists.
- [x] 4.5 <!-- Non-TDD --> Audit every separately retained support header for distinct ownership, checked-in consumers, and export/template constraints; merge or delete redundant facades, but preserve required operation payload, generated-prep, struct-payload, and shared-helper boundaries.
- [x] 4.6 <!-- Non-TDD --> Confirm by exact static audit that all 96 `_Functions.h` paths are gone, every checked-in include uses a canonical family or audited support header, all 120 registrars remain in `Bind_<Family>.cpp`, and all native callable implementations remain in the appropriate `_Functions.cpp` or required visible template definition. Final build evidence remains in section 6.

## 5. Type Adapter Ownership — All Non-Blueprint Concrete Adapters

- [x] 5.1 <!-- TDD --> Replace the pre-move baseline checkpoint with the user-requested centralized final verification after all file edits; the exact focused Type/StaticJIT/Bindings/Coverage prefixes remain mandatory in section 6.
- [x] 5.2 <!-- TDD --> Move the template/container wave into canonical family headers plus `_Type.cpp` implementations: Primitives, TArray, TMap, TSet, TOptional, and TSoftObjectPtr. Preserve operations/support boundaries, exports, declarations, phases, traits, iterators, native forms, and TypeDB ownership.
- [x] 5.3 <!-- TDD --> Move the reflection/complex wave: Delegates, UEnum, UStruct, WorldCollision, and FCollisionQueryParams-related adapters. Preserve reflection lookup, GC/property behavior, AS_USE_BIND_DB branches, callable ownership, and registration phases.
- [x] 5.4 <!-- TDD --> Move every remaining scalar/value concrete adapter family from the matrix, including Box/Bounds, CollisionShape, FormatArgument, Int vectors, LinearColor, Name, number formatting, Quat, RandomStream, Rotator, Sphere, String, Text, Transform, and Vector families; run the centralized focused verification in section 6 after the complete edit set.
- [x] 5.5 <!-- Non-TDD --> Confirm adapter declarations live in canonical `Bind_<Family>.h`, out-of-line Type implementations live in `Bind_<Family>_Type.cpp`, shared `Helper_*Type.h` templates remain header-only, family-local Primitive templates remain fully visible in `Bind_Primitives.h`, exports are preserved, and no empty `_Type.cpp` exists.
- [x] 5.6 <!-- Non-TDD --> Confirm `FUObjectType`, `FSubclassOfType`, `FObjectPtrType`, and `FWeakObjectPtrType` remain the only deferred concrete adapters in `Bind_BlueprintType.cpp`, and keep their reflection/property/type-lookup/hot-reload checkpoint explicitly recorded.

## 6. Final Verification and Delivery

- [x] 6.1 <!-- Non-TDD --> Final `Tools\RunBuild.ps1 -Label bind-family-ownership-refactor-iwyu -TimeoutMs 1800000 -NoXGE` build passed with exit `0` in `Saved/Build/bind-family-ownership-refactor-iwyu/20260809_020255_921_7c29613e/Build.log`; metadata records a `60.008 s` run and the final log scan found zero compiler/fatal/IWYU first-header diagnostics.
- [x] 6.2 <!-- Non-TDD --> Focused behavior results: SourceLayout `28/28` (`Saved/Tests/bind-refactor-source-layout/20260809_020435_505_4fa9029f/Report/index.json`), Actor PropertyInterface `7/7`, Engine Hooks `4/4`, TypeUsage `5/5`, TypeRegistry `1/1`, TypeDatabase `3/3`, StaticJIT NativeForms `4/4`, StaticJIT AOT `12/12`, and full Bindings `275/275`, all with zero failures/skips in their `bind-refactor-*` reports. Final `Tools\RunTestSuite.ps1 -Suite All` completed 35 UE buckets at `2521/2521` with zero failures/skips (first/last summaries: `Saved/Tests/All_01_Editor/20260809_021748_076_367c4a53/Summary.json` and `Saved/Tests/All_35_WorldSubsystem/20260809_025909_932_004ff3e2/Summary.json`) plus Standalone CTest `19/19` at `Saved/StandaloneTests/All_36_Standalone/20260809_025941_333_1e4275ca/Summary.json`. The separately requested full Coverage run completed `1021/1022`; its sole failure is the unchanged, out-of-scope `Coverage.Macros.UParamModifiers` negative test expecting the old diagnostic text `Expected identifier` while the compiler still correctly rejects the syntax with `Expected ')' or ','`. An exact one-test rerun reproduced `0/1`; no bind contract failed and no canonical-header/comment-marker test was added.
- [x] 6.3 <!-- Non-TDD --> Fresh static reconciliation reports: registrars `120/120` documented, logical surface entries `2979`, `@param` notes `1052`, legacy headers/references `0/0`, `_Functions.cpp` canonical includes `95/95`, `_Type.cpp` canonical includes `41/41`, Type registrars/empty Type implementations `0/0`, matching registrar first-header includes `102/102`, obsolete Actor symbols `0`, and direct registrar Helper-Type includes `2`. `git diff --check` exits `0` (only checkout line-ending notices), the rejected `BindFamiliesUseCanonicalDeclarationHeaders`-style test is absent, and `openspec validate improve-as-bind-reviewability-and-tests --strict` passes.
- [x] 6.4 <!-- Non-TDD --> Complete diff review and independent static audits found no lost callable declaration, phase, trait, export, template body, native form, GC/property hook, `GetCppForm`, `TemplateObjectForm`, or `NeverRequiresGC` contract. Of 492 moved out-of-line Type methods, 489 are token-exact and three FName methods are behavior-equivalent early-return rewrites; 168/168 moved container/Primitive inline bodies are token-exact. Full Bindings, StaticJIT, All, and Standalone behavior suites pass.
- [x] 6.5 <!-- Non-TDD --> Plugin source was path-scoped, staged with zero unexpected paths, checked with cached `git diff --check`, and committed as `5345032` (`[Angelscript] Refactor: unify bind family ownership and documentation`). The parent commit stages only this OpenSpec directory and the `Plugins/Angelscript` gitlink; all unrelated parent/submodule workspace modifications remain untouched.

## 7. Provider-locality Record and Audit

- [x] 7.1 <!-- Non-TDD --> Preserved the completed 120-file Runtime documentation/header/Type evidence and recorded the separate three-plugin provider-locality scope without changing optional-plugin comments or headers.
- [x] 7.2 <!-- Non-TDD --> Reconciled the baseline inventory: 126 registrar files, 242 logical registrars, 245 source definitions, five already-direct provider lambdas, 240 named provider pointers, and the three duplicated `Bind_UStruct` branch identities.

## 8. Runtime Provider Migration

- [x] 8.1 <!-- TDD --> Replaced every named Runtime provider with a body-expanded direct registrar-local lambda while preserving registrar symbols, logical names, phases, and callable/native registration forms.
- [x] 8.2 <!-- TDD --> Retained named direct callable owners and pointer/native forms, rejected forwarding wrappers, and removed only anonymous namespaces emptied by provider inlining.
- [x] 8.3 <!-- TDD --> Preserved both `AS_USE_BIND_DB` UStruct bodies and retained each large BlueprintType body in its branch with a same-identity direct lambda registrar.

## 9. Optional Plugin Provider Migration and GameplayTags Audit

- [x] 9.1 <!-- TDD --> Migrated all five AngelscriptGAS providers to body-expanded direct registrar-local lambdas without modifying headers, public API, logical names, phases, or native forms.
- [x] 9.2 <!-- Non-TDD --> Audited the three existing direct AngelscriptGameplayTags providers; no source-locality correction or optional-plugin documentation/header change was needed.

## 10. Test Scope Boundary

- [x] 10.1 <!-- Non-TDD --> Do not add or alter `BindingArchitecture.SourceLayout` assertions for this presentation-only provider-locality migration. Reverted the temporary Core adaptations and removed the affected GAS lambda-shape assertion rather than replacing it with a new source-layout rule.
- [ ] 10.2 <!-- Non-TDD --> Verify script-visible behavior only through the existing narrowest Bindings, Functional, Coverage, Type, StaticJIT, GAS, or GameplayTags owner; do not add a permanent provider-layout, filename, include-shape, or comment-marker test.

## 11. Static Reconciliation

- [x] 11.1 <!-- Non-TDD --> Re-ran the provider-locality audit and exact searches: 126 files, 242 logical registrars, 248 source definitions/direct registrar-local provider lambdas, zero named provider pointers, zero standalone provider functions, and zero forwarding wrappers. The three added source definitions are the paired `Bind_BlueprintType` conditional registrars.
- [x] 11.2 <!-- Non-TDD --> Reviewed UStruct branch parity, BlueprintType identity preservation, anonymous-namespace disposition, and `git diff --check`; recorded final verification evidence for BIND-005.

## 12. Centralized Validation After Complete Edit Set

- [x] 12.1 <!-- Non-TDD --> Ran centralized `Tools/RunBuild.ps1` after the complete edit set; final build passed.
- [x] 12.2 <!-- Non-TDD --> Ran focused behavior prefixes through `Tools/RunTests.ps1`: Bindings `275/275`, GAS `252/252`, and GameplayTags `15/15`, all with zero failures/skips. No source-layout test was added or used as a migration contract.
- [x] 12.3 <!-- Non-TDD --> Ran `openspec validate improve-as-bind-reviewability-and-tests --strict`; it passed.

## 13. Submodule-first Delivery

- [x] 13.1 <!-- Non-TDD --> Inspected all three plugin submodules. Committed Runtime `3b50485` and GAS `cbff1cd` with path-scoped changes; GameplayTags was audit-only and remains uncommitted/unchanged for this task.
- [x] 13.2 <!-- Non-TDD --> Staged only this change record and the Runtime/GAS gitlinks (GameplayTags remains excluded as audit-only), ran cached diff checks, and recorded the parent delivery commit after the plugin commits.
