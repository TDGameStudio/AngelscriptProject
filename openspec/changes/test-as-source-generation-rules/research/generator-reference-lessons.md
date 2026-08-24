# External Generator Reference Lessons

These repositories are local offline research inputs listed in `AGENTS.md`; they are not dependencies and do not define AngelScript/UE semantics.

## Fuzzilli — typed builder and context discipline

Evidence: `Reference/fuzzilli/Sources/Fuzzilli/Base/ProgramBuilder.swift`, `CodeGen/ProgramTemplate.swift`, built-in CodeGenerators, context graph, contributor tracking.

Useful lesson: generation should operate over a structured program/builder state that knows available values, types, scopes, and legal contexts; contributor/recipe identity should remain visible in output. Applied here as versioned recipe IDs, structured cells, typed oracle data, named random slots, and provenance. Not adopted: JavaScript-specific IR, coverage-guided mutation loop, engine profiles, or Swift implementation.

## Grammarinator — grammar generation is a frontend tool, not a semantic oracle

Evidence: `Reference/grammarinator/grammarinator`, `grammarinator-cxx`, ANTLR processing/generation tests.

Useful lesson: grammar-derived production and parse-tree mutation can cover syntax shapes and has both Python/C++ implementation examples. Applied here only to frontend/token/parser/preprocessor recipe thinking. A grammar alone cannot guarantee UE-valid declarations, runtime behavior, ownership, or expected values, so it is not the core architecture.

## Csmith — valid program construction and observable behavior

Evidence: `Reference/csmith/src`, runtime and driver structure.

Useful lesson: constrain generation to well-defined valid programs and emit an observable checksum/result rather than assuming compilation proves correctness. Applied here as valid-by-construction recipes, explicit semantic constraints, complete typed oracles, and deterministic source/results. C language undefined-behavior policy is not imported; AngelScript/current-fork and UE semantics remain authoritative.

## YARPGen — controlled seeds, types, mutations, and differential evidence

Evidence: `Reference/yarpgen/src/utils.{h,cpp}`, type tests, options for generation/mutation seeds.

Useful lesson: keep generation and mutation decisions explicit, reproducible, and type-aware; compare independently produced/executed evidence. Applied here as explicit seed, named substreams, typed axes, one named negative mutation, and independent Python/C++ output comparison. Its native random-engine details are not adopted because this change specifies its own portable vectors.

## C-Reduce — preserve an interestingness predicate during later minimization

Evidence: `Reference/creduce/creduce`, `delta`, and `clang_delta` transformation/pass structure.

Useful lesson: if failure reduction is added later, each transformation must preserve an explicit interestingness predicate and should be staged from coarse to fine. This change records enough CaseKey/seed/axes/oracle/diagnostic data to make a future reducer possible, but implements no reducer and never conflates reduction with initial generation.

## Combined design consequence

The primary architecture is reviewed declarative products over a typed source/result model, not unrestricted grammar fuzzing. Exhaustive axes guarantee planned coverage, controlled seed slots add legal diversity, complete oracles make behavior checkable, independent implementations expose drift, and provenance makes future reduction/replay possible.
