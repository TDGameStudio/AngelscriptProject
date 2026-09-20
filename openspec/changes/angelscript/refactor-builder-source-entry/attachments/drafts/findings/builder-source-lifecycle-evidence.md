# Builder Descriptor and Lifecycle Evidence

Local source inspection on 2026-09-13; no product tests executed. Paths below are relative to Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/.

## Declaration source

frontend/Compile/as_compilation_session.cpp:199-209 establishes module stable identity from each fragment's logical path. frontend/Compile/as_descriptor_consumer.cpp:299-343 projects per-fragment ModuleDesc with module identity, source anchor, and typed declarations. Record/function projection supplies metadata, properties, methods, and stable declaration identities.

## Late replacement loses output information

as_builder.cpp:192-231 RefreshCompileOutput prefers a simplified branch once ModuleDefinitions exists. It constructs one ModuleDesc named after sorted Inputs[0].LogicalSourceKey and adds class and matching method names to it before ReplaceModules. It skips namespaced types and omits properties, metadata, and semantic anchors present in the typed projection.

Record refreshes output after each stage at approximately line 188. DefinitionsBuilt at lines 395-412 installs definitions, activating this branch. Separate diagnostic refresh from one-time declaration publication. This demonstrates loss in outward descriptions, not loss of every internal AST/type identity.

## Stable association already exists

frontend/Compile/as_definition_consumer.cpp:163,170,192 uses GetStableIdentity when constructing enum, object, and function definitions. as_module_definition_set.h:130-133 provides asSStableKey lookup for types, functions, and global properties. Description StableDeclarationKey can associate later definitions without display-name guessing. Returned pointers remain borrowed.

## Transfer and failure

as_compile_output.h explicitly excludes ownership of TypeInfo/bytecode. as_builder.cpp:286,301 moves owned pointers directly from Take methods. frontend/Compile/as_compilation_session.h:101 retains a raw FrozenDefinitionSet borrow, requiring transfer gating and borrow invalidation.

RunThrough already advances by stages; construction currently records validation. as_diagnostics.cpp rejects invalid PrimaryRange for Report. Non-located input errors therefore need an explicit stage/final Error rather than fabricated locations; this does not require absorbing the separate full diagnostics tooling plan.

## Text materialization

as_builder.cpp:50 TokenText converts complete token spelling ranges into concatenated FString output. Lexed/Preprocessed at lines 343,351 call it, and Record serializes observations. Eliminating AddFile copying alone is insufficient: ordinary compilation must avoid these full text dumps while explicit deterministic observations remain testable.
