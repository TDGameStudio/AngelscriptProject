## Context

`AngelScriptCodeGeneratorResearch.md` recommends a Fuzzilli-style typed builder rather than random source concatenation. The native SDK comprehensive-coverage change independently requires stable coverage IDs, deterministic generated sources, independently recorded expectations, and printed source evidence. `AngelscriptTest/Coverage` supplies reviewed UE source shapes, but its CQTest helpers deliberately do not expose a generator profile abstraction.

The new tool must therefore live outside the plugin and use machine-readable profiles as its only capability source. It is a source producer in this change: it neither starts Unreal nor claims a generated UE source compiled or executed.

## Goals / Non-Goals

**Goals:**

- Generate deterministic `.as` source and a reproducible catalog from a seed, profile, kind, and bounds.
- Keep positive and negative generation paths separate.
- Preserve types, scopes, lvalue status, handle nullability, control-flow legality, and profile context requirements in an internal typed model.
- Support layered native-core, UE-value, UE-annotation, and UE-World source profiles without importing plugin code.
- Give future runner, reducer, corpus, and CQTest-rendering changes stable case metadata to consume.

**Non-Goals:**

- Building, executing, fuzzing, reducing, or coverage-guiding generated source.
- Automatically inventorying all registered UE APIs or emitting arbitrary engine calls.
- Generating C++ automation/CQTest code or altering existing Coverage test files.
- Treating profile acceptance as runtime proof for an unexecuted UE sample.

## Decisions

### 1. Use a private typed program model and a source lifter

The model records program structure and semantic constraints; the lifter is the only component that formats AngelScript. This keeps valid generation from depending on string repair and allows a future reducer to operate on nodes. A template-only approach would duplicate constraints across source snippets, while grammar-first generation would primarily reach parser/error-recovery paths.

### 2. Store reviewed capabilities in inherited JSON profiles

JSON is available in Python 3.10's standard library. Each profile declares its parent, allowed types/callables/fragments, invalid rules, limits, harness requirement, and source evidence. `native-core` is the root; `ue-values`, `ue-annotated`, and `ue-world` add capabilities in order. Broad automatic reflection/state-dump ingestion is deferred because it cannot classify side effects, WorldContext, or cleanup requirements safely.

### 3. Generate positive and negative cases through distinct contracts

The positive builder creates only nodes valid in the current context. The negative builder begins with a positive baseline and applies exactly one named rule violation, producing an explicit expected category. Allowing both outcomes in one random source stream would make diagnosis and later CQTest expectations ambiguous.

### 4. Make reproducibility an output contract

`random.Random` is instantiated from an unsigned 64-bit seed; each case derives a deterministic sub-seed from the requested seed and ordinal. Source files use stable IDs/names and include leading `@as_codegen` comments. `index.json` records the same identity plus source SHA-256, so future tools never infer case metadata from source text.

### 5. Keep World/Actor material declarative and unexecuted

The `ue-world` profile can emit only audited fragments with an explicit `harness` requirement and cleanup contract. It does not own a `UWorld`, spawn objects, or call the editor. A future UE runner must interpret the harness requirement through the established test helpers.

## Risks / Trade-offs

- **[Profile drift from the actual binding surface]** → Every UE capability records a Coverage/matrix evidence reference and remains manually reviewed; future state-dump import is a separate change.
- **[Valid source has not been compiled]** → Metadata distinguishes `generation-valid` from runtime-verified; runner integration is explicitly deferred.
- **[Combinatorial growth]** → CLI depth and statement limits are mandatory, and profiles expose finite fragment sets.
- **[Generator bugs mask expectations]** → Positive/negative builders and catalog expectation construction remain separate modules with test coverage for each contract.
- **[Generated files pollute Git state]** → Default output is the ignored `Saved/AngelscriptCodeGen/` directory; writing under plugin tests is not supported.

## Migration Plan

1. Add the tool and profiles without changing the plugin or existing test suites.
2. Verify all Python tests and deterministic output comparisons.
3. Consumers may invoke the CLI manually and inspect `Saved/AngelscriptCodeGen/`.
4. A future runner/reducer/CQTest change consumes the stable catalog schema; rollback is removal of the self-contained tool directory and this change record.

## Open Questions

- None for the foundation. Exact UE callable coverage expands through reviewed profile updates, and runner semantics remain intentionally deferred.
