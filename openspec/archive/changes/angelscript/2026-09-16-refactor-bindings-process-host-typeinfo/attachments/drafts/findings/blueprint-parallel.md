# Blueprint inheritance and safe parallel writes

English export of the accepted Blueprint investigation: Q51 selected genuine class fan-out and Q52 selected ExcludeSuper properties.

Current Blueprint UFunction collection already uses ExcludeSuper and relies on shadowType for inherited lookup. Property collection must adopt the same own-member model after base relations are established. Do not silently change UStruct's inherited field policy.

Take the reflection snapshot and prewarm lazy UClass FuncMap/NameArray state on GameThread. Build all required shells, join, establish canonical base/shadow relations, then populate each class's own methods/properties in a worker wave. Class ownership prevents concurrent mutation of the same member table. Shared identity publication needs short synchronization; retaining an entire-graph mutex around callbacks would not satisfy genuine fan-out.

Preserve static-global and other UE-thread-affine work on GameThread. Verify parent/child property lookup without duplicate inherited entries, deterministic 0/1/2/4-worker results and failure containment. This is a design obligation; no performance measurement was produced by the draft.
