# Module dependencies do not schedule Lex or PP

English translation of angelscript/diagnostic-engine/findings/module-dependencies.md, 2026-09-14. This is inspected source rationale, not a separate design approval.

The reconstructed frontend has no source import ordering for lexical/preprocessor work. Three dependency layers matter:

1. Host Options.Dependencies contains already compiled immutable ModuleDefinitionSets. At DeclarationsCollected, CollectExternalSets validates immutability and AddExternalDefinitions traverses the dependency closure. DefinitionsBuilt later attaches dependencies. Lex/PP does not consume that graph.
2. Files in one Builder input form a source set. LogicalSourceKey becomes module identity in resolution. A source may refer to a type collected from a later file. CollectSource for every file and CloseDeclarationBarrier precede ResolveDeclarations; removed import syntax is rejected.
3. After declaration resolution, BuildDeclarationDependencyGraph derives source/module edges from resolved base/interface/property/signature/generic/delegate type uses. Same-module and source-less host targets do not create these edges. Cycles remain and are represented with SCCs and a condensation DAG. This is output for reflection/invalidation, not an input scheduler for Lex/PP. Body reference invalidation is a separate graph.

```text
All eligible PP products                // Per-file lexical work has joined
└─ CollectSource                        // Local declaration fragments
   └─ CloseDeclarationBarrier           // Merge deterministically
      └─ ResolveDeclarations            // Cross-file semantic lookup
         └─ Derive dependency graph     // Result for later consumers
```

The preserved old Preprocessor/AngelscriptPreprocessor.cpp ordered imports and diagnosed cycles. It is dormant reference code, not the maintained Builder policy. Module dependencies add no PP-start wait; later declarations still need the appropriate complete-source barrier.
