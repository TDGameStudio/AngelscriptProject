# Workstream 00: Feasibility and Contract Freeze

## Purpose

This workstream proves the architectural assumptions that every later standalone workstream depends on. It intentionally precedes broad portability refactors, exporter implementation, template adapters, and resource diagnostics.

No first-release support claim may be promoted from this workstream alone. A failed proof changes the later design and task plan instead of being hidden behind an approximation.

## Required Proofs

### 1. Unreal-independent maintained-fork build

Create a minimal Win64 CMake target that compiles the maintained parser, builder, compiler, module, bytecode save/restore, and context sources without Unreal Engine headers, libraries, generated code, installation paths, or process startup.

The proof SHALL:

- compile the same source files used by the UE module;
- identify every remaining UE dependency by source and dependency family;
- avoid copied fork sources and broad fake Unreal headers;
- pass a source/link architecture scan;
- preserve the UE build and the focused NativeCore baseline after each retained portability edit.

### 2. Deterministic native bytecode

Compile and save the same small native module twice under an identical engine profile.

The proof SHALL:

- normalize source/module ordering and logical paths;
- compare bytecode and deterministic identity fields byte-for-byte;
- isolate elapsed time, process ID, absolute path, allocation telemetry, and runtime output from compile identity;
- record any maintained-fork serialization source that prevents determinism.

### 3. Canonical contract and stable identity

Freeze the v1 physical files, schemas, canonical encoding, and stable identity rules before implementing the full producer or consumer.

The proof SHALL define:

- UTF-8 without BOM and LF line endings;
- JSON object-key and JSONL record ordering;
- Unicode normalization policy;
- namespace, owner, declaration, default-argument, logical module, and virtual source normalization;
- UE package/object/generated-class path case and spelling policy;
- canonical integer, floating-point, boolean, null, and escaped-string representation;
- required versus optional fields and unknown-field handling;
- schema major/minor compatibility;
- versioned SHA-256 symbol, module, adapter-surface, file, and bundle identities.

Machine-readable schemas SHALL be planned for the producer, consumer, package, tests, and documentation from the same contract version.

### 4. Compile-only registration and address-free linkage

Export and replay one representative enum, value/reference type, property, global, overloaded method, default argument, and inheritance relationship.

The proof SHALL:

- register callable declarations through one non-executable generic trap;
- resolve calls and overloads through the maintained compiler;
- map process-local descriptors to stable contract IDs;
- save bytecode through used-function identity/signature linkage;
- prove no native UE address enters the contract or validation artifact;
- fail immediately if a compile-only trap is invoked.

### 5. Script-baseline replacement

Create a frozen bundle containing declaration-only script module A and compile current source module B against it. Then include current source A in the selected closure and prove its baseline is suppressed before A and B compile.

The proof SHALL cover:

- stable module identity independent of source contents;
- closure-external baseline availability;
- exact closure replacement;
- duplicate and ambiguous module identity rejection;
- class, method, global, inheritance/interface, and overload references needed by the initial support slice.

### 6. Portable declaration IR

Route one representative include/import/condition fixture and one UE class/struct declaration fixture through a host-neutral source model and declaration IR in both UE and standalone test adapters.

The proof SHALL compare:

- logical module/source identity;
- include/import graph and order;
- annotation/declaration structure;
- source ranges;
- normalized diagnostic category and principal location;
- UE adaptation into the existing descriptor shape without invoking ClassGenerator in standalone.

### 7. Compiler semantic observation

Define a host-neutral, read-only observation boundary for resolved calls, constructors, assignments, argument types, selected stable function/type identities, and supported constant strings.

The proof SHALL:

- observe semantic results only after overload and type resolution;
- avoid a second expression parser;
- preserve compiler output when no observer is installed;
- support both UE evidence and standalone resource analysis;
- never expose process-local pointers in serialized artifacts.

### 8. Mixed UE/CTest runner dispatch

Define a repository runner entry model that distinguishes UE Automation prefixes from standalone CMake/CTest execution.

The proof SHALL cover:

- isolated `Standalone` configure/build/CTest execution;
- timeout, failure propagation, labels, output roots, and reports;
- `RunTestSuite.ps1`, the parallel runner, shard planner, and self-tests;
- deferred inclusion in `All` until release-soak evidence passes.

### 9. CLI output and allocation boundaries

Freeze:

- compile and run output-directory/default/stdout behavior;
- atomic replacement and partial-output rules;
- deterministic versus telemetry fields;
- which engine, context, script object, add-on, compiler, JSON, CLI, and process allocations count toward the 256 MiB runtime limit;
- allocation-failure propagation, active-context abort, peak accounting, and shutdown leak expectations.

## Exit Gate

Workstream 00 completes only when every proof has reproducible commands and evidence under `verification/phase-00-feasibility.md`, the main design/specs/tasks have been corrected for every discovered mismatch, and no later workstream relies on an unproven approximation.
