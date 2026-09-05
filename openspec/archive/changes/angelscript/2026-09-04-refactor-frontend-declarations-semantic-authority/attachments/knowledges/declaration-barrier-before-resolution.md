# Candidate Knowledge: Put a declaration barrier before cross-source resolution

## Status

Candidate. Promote only after the Declarations implementation proves the rule with reversed source order and one-worker versus multi-worker CQTests.

## Rule

In a language without mandatory per-file import ordering, collect typed declaration headers from the complete compilation input before resolving cross-source names, bases, and signatures. Parser drives grammar; Sema creates and resolves the concrete typed AST. Runtime registration is not a substitute for semantic collection.

## Why it matters

If a frontend resolves while files are still arriving, file enumeration order becomes a hidden language rule. Pre-registering runtime placeholders hides the symptom while coupling error recovery, parallelism, and semantic identity to mutable runtime state. A declaration barrier makes the symbol universe explicit and gives deterministic diagnostics a stable input.

## Reusable shape

1. Freeze source, options, tokens, and preprocessing provenance.
2. Collect concrete typed declarations and unresolved type locations into isolated source fragments.
3. Merge declaration contexts and stable symbols in canonical source/key order.
4. Resolve declaration semantics against the frozen symbol set.
5. Defer bodies and runtime publication to later explicit phases.

The barrier must distinguish an inspectable error-bearing result from a valid publication candidate. Recovery nodes retain ranges and structure but never satisfy valid lookup.

## Anti-patterns

- Registering empty runtime types so later files happen to find a name.
- Calling a sequential loop “parallel” while all workers mutate one Builder or Engine registry.
- Returning a generic key/value declaration record and describing it as a typed AST.
- Adding a new `import` construct solely to work around compilation-session ownership.
- Using pointer, runtime ID, thread completion, or insertion order as canonical declaration identity.

## Evidence

- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2654-2656 records the user's correction that AngelScript does not have the assumed C++ forward-declaration model.
- [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 2315-2317 records the user's request to decouple Builder/Engine and batch later output.
- `as_builder.cpp:2101-2130` shows the retained parse loop is sequential despite its name.
- `as_builder.cpp:4297-4405` shows runtime object construction and Engine/module registration during declaration handling.

## Applicability boundary

Use this rule for the reconstructed frontend and similar whole-program/session compilers. It does not require copying Clang's C++ translation-unit rules, include system, modules, raw source-location encoding, or memory layout. Publication and VM boundaries remain separate design problems.
