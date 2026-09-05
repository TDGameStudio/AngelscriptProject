## Context and ownership

The accepted handoff replaces the active language frontend, not the dormant product runtime. The plugin submodule owns source/tests; the parent owns OpenSpec. Existing dirty/untracked frontend files are the input baseline. The reference architecture is local Clang 22.1.8 at `D:/LLVM/llvm-project-22.1.8.src`, not an added build dependency.

Clang reference points are ParseAST orchestration, Lexer/Preprocessor separation, ParseExpr precedence climbing, cached inline-method tokens, SourceManager/TypeLoc, separate Decl/DeclContext, canonical types and ASTContext allocation. Clang ASTContext itself is not a thread-safe mutable shared graph; parallel construction here uses explicit fragments, synchronization and freeze barriers.

## Frontend and phase results

Builder accepts a source snapshot, immutable language options, an explicit type context and diagnostics. Its stages are Tokenize, Preprocess, CollectDeclarations, ResolveDeclarations, AnalyzeBodies, VerifyAST, FinalizeDefinitions/Layout, FreezeDefinitions and optional RegisterDefinitions. Each exposes typed results and deterministic text/JSON observation. Dump text is never compiler input. Illegal stage order fails without publishing partial results.

SourceManager owns stable source identity and coordinates. Lexer/Tokenizer is independently public. Identifier and token storage survives deferred parsing. Preprocessing selects tokens and records conditional provenance; cached body tokens retain the original configuration and identifier lifetime. Declaration results do not seal the whole AST before bodies. Syntax/type/signature failures propagate to the stage result and publication state.

The newest frontend is the only AST. Decl, Stmt, Expr, TypeLoc and Attr model syntax; DeclContext is an independent context abstraction. Canonical types model normalized type uses. TypeInfo and ScriptFunction hold actual semantic definitions, not another AST. Context allocation runs necessary destructors for UE containers. Parser/Sema cover the maintained AS syntax inventory except explicitly removed constructs; existing simplistic expression/parameter parsing is not the acceptance baseline.

## Canonical C++ naming and cutover

The user-selected final surface has no nested frontend C++ namespace. Reconstructed lexer, preprocessor, Parser/Sema, AST, source/diagnostic, compilation and identity declarations live directly inside BEGIN_AS_NAMESPACE alongside actual TypeInfo, ScriptFunction and MetadataImage. Keep BEGIN_AS_NAMESPACE, END_AS_NAMESPACE, AS_NAMESPACE_QUALIFIER and AS_USE_NAMESPACE unchanged; the latter still selects AngelScript scope or the global scope. Do not add a new switch, Frontend/V2 namespace, namespace alias or using-declaration compatibility surface.

The source/frontend directory and ordinary frontend terminology remain useful organization, not a second API. Do not rename AS language namespace syntax, serialized source names or diagnostic prose. Stable key bytes, codec versions and semantic ownership do not change merely because C++ qualifications do. Existing exported C++ symbols do change; rebuild every affected Runtime/test consumer rather than claiming binary compatibility.

Task 6.1 removes competing ASTs and eliminates compiled/transitively included old Parser, Tokenizer, Sema and SourceManager name conflicts while preserving unrelated dormant reference source. Task 6.2 then owns the mechanical declaration/consumer cutover, including forward declarations, friends, traits, Core descriptors/artifact identities and replacement test support. The ordering is a genuine duplicate-definition prerequisite, not writer convenience. Shared AST/identity/metadata headers justify a rebuilt complete NativeEngine regression selection before 7.1.

Namespace acceptance starts with executable structural RED for actual nested declarations, qualification and aliases; compile failures are not behavioral RED. Positive canonical-header compile/link fixtures and existing runtime semantic controls prove GREEN after migration. Retaining the outer macro contract does not claim a newly certified whole-fork AS_USE_NAMESPACE build variant. No UE operation or source modification occurs in this planning-only replan.

The declaration delta also preserves the already completed Parser-only-Sema constructor boundary. The reflection delta explicitly renames the old preprocessor-facade requirement to the compilation facade and retains its result/diagnostic/branch-selection scenarios, aligning the naming clause with the already accepted directive-only preprocessor. No new duplicate descriptor result or semantic preprocessing pass is introduced.

## Directives and language constructs

Preprocessor owns conditional flags, 0/1, defined, !, &&, ||, parentheses and nested if/elif/else/endif. It does not expand include files or textual macros. It retains skipped branches and source locations. Its existing ProcessSemantic orchestration moves to CompilationSession/Builder.

UCLASS, USTRUCT, UENUM, UFUNCTION, UPROPERTY and UMETA become dedicated outer keywords. Arguments remain structured payloads with source ranges, not more keywords. AST records the marks; the optional descriptor consumer projects them without creating UObject or implementing UE reflection business rules. UDELEGATE is not adopted merely because the replacement tests previously invented it.

delegate and event become typed declarations with single/multicast classification and signature type uses. Collected output identifies declarations before body analysis; resolved output supplies canonical signatures/dependencies. Host reflection-shell creation, signature completion and publication remain separate operations and are not activated in this Change. No generated AS wrapper text or reparse is permitted.

The Parser rejects the old asset Name of Type declaration with a dedicated source diagnostic and balanced recovery. Ordinary asset/of identifiers, strings, comments and inactive branches remain valid. No generated getter, initializer or postinit record is emitted. import syntax is not restored; dependencies come from resolved references. Language sugars such as defaults and range loops belong to structured parsing/semantic construction rather than preprocessor string replacement.

## Definitions and lifetime

An explicit TypeContext holds frozen language configuration and canonicalization services. Multiple Builders can share it; it is not a mandatory process singleton. Real asCTypeInfo/asCObjectType/asCScriptFunction objects belong to a definition image. Declare identity shells, resolve relationships and bodies, validate layout, then freeze. Methods, factories and behaviours refer to actual semantic objects rather than mandatory Engine numeric IDs.

Image-internal edges are non-owning and can be recursive. External type/function handles retain the image through atomic leases. Dependencies on other frozen images retain explicit leases and form a DAG; mutually recursive declarations belong to one image. Frozen objects cannot acquire new semantic edges. Builder destruction and Engine destruction do not destroy externally retained definitions. Resource cleanup does not treat a null Engine as proof that local resources were already freed.

Mutable per-engine language defaults, including asCDataType::floatIsFloat64, move into immutable compilation options. Canonicalization is synchronized or fragment-local; frozen data is concurrent-read safe, but concurrent arbitrary mutation of one draft object is unsupported.

## Engine registration

Register complete frozen images and any unattached required dependencies transactionally, never individual fragments of a type/function closure. States are Building -> Frozen -> Attaching -> Attached -> Retired. A failed preparation returns to Frozen without visible publication. Successful registration preserves every object address and pins each image to one Engine. Repeated registration returns AlreadyRegistered; another Engine and retirement reuse are rejected.

Validate identities, complete definitions, host dependencies and target layouts before allocating/publishing Engine-local TypeId/FunctionId, namespace and configuration state. On retirement remove visible bindings, finish existing binding operations and release Engine leases; surviving metadata queries remain valid, engine-only queries explicitly fail/unbind. Numeric queries never implicitly register detached objects.

All active declaration parsing and registration paths use the new frontend and common validation. Native incremental construction uses an explicit draft batch and freezes only after its members are complete. Engine constructor builtins must migrate too: RegisterScriptObject/RegisterScriptFunction currently reenter the old parser. Isolated unsupported execution/legacy registration paths fail explicitly rather than mutate frozen metadata or use old AST fallbacks. Metadata registration does not claim VM execution readiness.

## Stable identity

The only public key value is asSStableKey: 32 bytes of BLAKE3-256 with typed getters. Domain/version framing remains inside canonical encoding. Hash values identify entities/type uses, not body content or layout versions. Nominal type identity includes stable scope/module, owner, kind, name and generic arity. Ordinary function identity uses parsed owner/name/canonical parameters and overload-relevant modifiers, never printed declaration text, parameter names, defaults or body text. Ordinary return-only overload conflicts remain errors.

Maintained conversion methods (opConv, opImplConv, opCast, opImplCast) use a distinct Function declaration kind. Their canonical destination TypeUse is an explicit identity edge, taken from their actual resolved return signature; no duplicate public key family, fabricated parameter or rewritten function name is needed. This matches the retained Builder's target-distinct conversion exception and Clang's distinction between a conversion declaration and an ordinary method. Sema selects actual conversion declarations by destination, receiver and explicit/implicit context, diagnoses ambiguity, and preserves the selected function reference in the typed expression. Identity admission does not imply executable conversion support.

Definition/layout compatibility stays internal. Canonical descriptors are owned once by the identity registry; references do not recursively copy witnesses. The fixed hash is the map key, not a hex FString. Equal hashes with different identity descriptors fail closed. Same identity does not merge distinct mutable objects or bypass Engine conflicts. Recursive nominal identities are assigned before edges; illegal by-value cycles are semantic errors. Anonymous/recovery definitions without a stable declared origin do not silently gain persistent identity. Active Core consumers use this same identity producer.

## Migration, verification and replan

The fixed-key registry is verified before detached metadata construction. Old AST/descriptor/identity consumers migrate in a separate handoff after declaration syntax work, so their shared files have one writer. The accepted boolean-expression preprocessing grammar has its own focused verification node; it is not inferred from body-replay tests.

The old AST implementations are removed only with all active consumers migrated. Bytecode/compiler execution, VM, cache and JIT consumers that cannot consume the new definitions remain hard-isolated without adapters back to old AST. Existing unrelated legacy source and generated artifacts are retained unchanged. No old runtime/test gate is enabled.

The user's latest 2026-09-05 instruction uses feature-group TDD to amortize UE startup: plan concrete related cases, observe the group's expected behavioral RED together, implement its bounded outcome, then run grouped GREEN. The earlier co-development exception remains historical evidence, not the default for new behavior. Preserve existing unverified WIP without deleting it or inventing retroactive RED. Compilation errors, crashes and missing reports do not prove expected behavioral failure.

Tasks 4.2–4.5 own the remaining access, conversion, frozen-host callable and execution-context products; 4.1 retains final Builder integration acceptance. Respect their semantic dependencies rather than implementing blocked features for batching convenience. Only the coordinator schedules build/test leases and all writers remain frozen throughout both. A complete shared report can prove covered tasks only through exact case identities and an applicable source/binary snapshot; an unrelated failing case does not erase independent proof or make the whole run green. Focused area selections diagnose failures, not obligatory extra process launches. The NativeEngine superset is justified here by shared AST/type/definition contracts, not a universal full-suite gate.

Source-discovery topology changes still require a transition build with -NoUBTMakefiles followed by an ordinary incremental build. Standalone, legacy tests and full UE suites are not acceptance substitutes. The historical Harness guidance correction and this namespace replan run no UE operation and do not establish correctness of the current product WIP.

Ordinary failures stay in their task. Replan only for evidence invalidating requirements, design, DAG boundaries or verification; preserve completed nodes and add followups. Record material Harness issues promptly. Strict spec/change validation, current spec synchronization and terminal closure precede archive; no success counts or completed tasks are inferred from old runs.

The 2026-09-05 user-requested Reviews remain implementation defects in already accepted contracts. Follow-up 8.1 authenticates frozen field datatypes and the actual exposed method/conversion owner at admission. Follow-up 8.2 includes every maintained expression kind in projection classification and authenticates decoded ConversionFunction keys against the selected conversion contract. Follow-up 8.3 applies mutable-receiver const preference, preserves conditional handle qualifiers, and makes foreach handle-const admission agree with verification. 6.2 still owns only the mechanical canonical-name cutover and waits on 8.1–8.3. Durable requirement text is unchanged; these nodes close the omitted consumer checks. Existing Reviews stay open until those nodes produce mapped evidence.
