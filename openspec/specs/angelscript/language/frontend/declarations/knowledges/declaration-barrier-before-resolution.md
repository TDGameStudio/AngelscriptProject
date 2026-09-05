# Put a declaration barrier before cross-source resolution

## Status

Accepted. The declaration capability proves this rule with reversed source-order and one-worker versus multi-worker focused CQTests.

## Rule

In a language without mandatory per-file import ordering, collect typed declaration headers from the complete compilation input before resolving cross-source names, bases, and signatures. Parser drives grammar; Sema creates and resolves the concrete typed AST. Runtime registration is not a substitute for semantic collection.

## Why it matters

If a frontend resolves while files are still arriving, file enumeration order becomes a hidden language rule. Pre-registering runtime placeholders hides the symptom while coupling recovery, parallelism, and semantic identity to mutable runtime state. A declaration barrier makes the symbol universe explicit and gives deterministic diagnostics a stable input.

## Reusable shape

1. Freeze source, options, tokens, and preprocessing provenance.
2. Collect concrete typed declarations and unresolved type locations into isolated source fragments.
3. Merge declaration contexts and stable symbols in canonical source/key order.
4. Resolve declaration semantics against the frozen symbol set.
5. Defer bodies and runtime publication to later explicit phases.

The barrier distinguishes an inspectable error-bearing result from a valid publication candidate. Recovery nodes retain ranges and structure but never satisfy valid lookup.

## Anti-patterns

- Registering empty runtime types so later files happen to find a name.
- Calling a sequential loop “parallel” while all workers mutate one Builder or Engine registry.
- Returning a generic key/value declaration record and describing it as a typed AST.
- Adding a new import construct solely to work around compilation-session ownership.
- Using pointer, runtime ID, thread completion, or insertion order as canonical declaration identity.

## Verification

- Build db53e5d3e1cf45ea9ab51c65abbd2afd compiled the final declaration implementation.
- Focused run 8b39ac6637304c9da3991bcd196e8285 passed 12/12 Declarations tests, including reversed inputs, worker-count equivalence, deterministic duplicates, and later-file type resolution.

## Applicability boundary

Use this rule for the reconstructed frontend and similar whole-program/session compilers. It does not require copying Clang's C++ translation-unit rules, include system, modules, raw source-location encoding, or memory layout. Body semantics, publication, bytecode, and VM boundaries remain separate design problems.
