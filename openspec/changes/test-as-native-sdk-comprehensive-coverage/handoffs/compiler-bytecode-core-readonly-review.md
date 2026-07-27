# Compiler Bytecode/Core Read-only Method Review

## Scope and decision rules

This handoff is a source-backed review of the 17 currently `Unowned` CQTest
methods in:

- `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp`
- `Compiler/AngelscriptNativeBytecodeJumpTests.cpp`
- `Compiler/AngelscriptNativeCompilerCoreTests.cpp`
- `Compiler/AngelscriptNativeOutputBufferTests.cpp`

Every method body was read in full and compared with the executable Compiler
products in `catalogs/coverage-products.psd1`. A method name is not treated as
evidence. In particular, a method is not declared superseded when the stronger
product does not prove the method's unique observable contract.

The recommended dispositions below use the states accepted by
`ReconcileNativeSdkSource.ps1`:

- `ProductOwned`: the method should own a product only after its body satisfies
  the complete product evidence contract.
- `ExplicitNonProduct / LegacyCompatibility`: retain a representative or
  compatibility smoke whose combinations are owned by a stronger product.
- `ExplicitNonProduct / AggregateSupport`: retain a multi-feature aggregate
  only as supporting evidence, not as the owner of each feature.

Where no current product owns the unique behavior, this review recommends a new
product rather than forcing a misleading mapping.

## Per-method findings

| File | Class | Method | Recommended disposition category | Stronger ProductId or proposed new product | Source evidence and evidence-layer gap |
|---|---|---|---|---|---|
| `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp` | `FBytecodeGenerationTests` | `CompiledFunctionExposesExecutableBytecode` | `ProductOwned` only after expanding the case; otherwise retain temporarily as unowned work | Proposed `COMPILER-BYTECODE-RETURN-TERMINATION` | The method compiles `int Entry() { return 42; }`, obtains a non-empty raw bytecode buffer, executes `Entry` to `42`, and finds `asBC_RET`. `COMPILER-BYTECODE-SHAPE` is stronger for generated-source visibility, scoped cleanup, runtime, and representative opcode families, but it does not explicitly promise a return terminator. The current method therefore has unique `RET` evidence and must not be marked superseded merely because a broader bytecode product exists. A real product should vary return shape (`void`, scalar, multiple exits, branch return, fall-through where legal), assert the terminator/exit layout rather than only opcode presence, print every generated source, and retain cleanup/isolation evidence. |
| `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp` | `FBytecodeGenerationTests` | `CompiledControlFlowProducesBranchOpcode` | `ExplicitNonProduct / LegacyCompatibility` | `COMPILER-BYTECODE-SHAPE` | The method compiles a two-arm `if`, executes a wrapper to `42`, and accepts any opcode in the conditional-branch family. `COMPILER-BYTECODE-SHAPE` already prints each source, compiles a conditional shape, checks exact runtime, obtains non-empty bytecode, checks the representative branch family, and scopes cleanup across all declared shapes. The retained method adds two call inputs inside one wrapper but does not prove path-specific bytecode targets, source/debug coordinates, or branch offsets. It is a representative compatibility smoke, not an independent product owner. |
| `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp` | `FBytecodeGenerationTests` | `CompiledLoopProducesBackwardJump` | `ExplicitNonProduct / LegacyCompatibility`; open a new product only if the name's backward-edge contract is required | `COMPILER-BYTECODE-SHAPE`, with proposed `COMPILER-BYTECODE-CONTROL-FLOW-EDGES` for the missing direction contract | The method executes a `for` loop to `15`, then merely accepts any unconditional or conditional jump opcode. It never decodes a relative operand and therefore does **not** prove a backward jump. `COMPILER-BYTECODE-SHAPE` already owns the same level of loop runtime plus jump-family evidence with generated-source and cleanup evidence. If backward-edge generation is intentional coverage, add a product varying loop form and edge kind and assert the actual signed target/relative offset; do not preserve the present method name as proof. |
| `Compiler/AngelscriptNativeBytecodeGenerationTests.cpp` | `FBytecodeGenerationTests` | `CompiledArithmeticBytecodeDiffersFromConstantReturn` | `ExplicitNonProduct / LegacyCompatibility` | `COMPILER-BYTECODE-SHAPE` | The method compiles a constant-return module and an `A + B` module, copies both raw buffers, executes only the arithmetic module to `42`, and asserts that the buffers differ. It does not require `asBC_ADDi`, execute the constant module, compare optimization modes, or prove stable semantic equivalence. `COMPILER-BYTECODE-SHAPE` prints and executes the arithmetic shape and explicitly requires its representative arithmetic opcode, so it is the stronger semantic owner. Raw inequality between two implementation buffers is a weak compatibility observation. |
| `Compiler/AngelscriptNativeBytecodeJumpTests.cpp` | `FBytecodeJumpTests` | `ForwardJumpResolves` | `ExplicitNonProduct / LegacyCompatibility` | `COMPILER-BYTECODE-CONTAINER-OPERATIONS` | The method emits `JMP(label 1)`, payload, and the target label, requires successful resolution, retains the `JMP`, and checks a positive signed relative argument. `COMPILER-BYTECODE-CONTAINER-OPERATIONS` generates seed-count × mutation × payload combinations, includes jump resolution, verifies linked count/head/tail/serialization/payload state, and explicitly checks the resolved forward offset. It is strictly broader for the same direction contract. |
| `Compiler/AngelscriptNativeBytecodeJumpTests.cpp` | `FBytecodeJumpTests` | `BackwardJumpResolves` | `ProductOwned` after expanding into a complete jump product | Proposed `COMPILER-BYTECODE-JUMP-RESOLUTION` | The method places the label before the payload and `JMP`, requires successful resolution, and checks a negative relative argument. Neither `COMPILER-BYTECODE-MUTATION` nor `COMPILER-BYTECODE-CONTAINER-OPERATIONS` declares or proves a backward-offset axis. This is unique evidence, but one direction-only case lacks multi-label, unresolved, appended-sequence, serialization, payload-retention, cleanup, and isolation combinations. It should become one cell of a direction × label topology × composition × resolution-outcome product. |
| `Compiler/AngelscriptNativeBytecodeJumpTests.cpp` | `FBytecodeJumpTests` | `MultipleLabelsResolveIndependently` | `ProductOwned` only as an expanded cell; current body is insufficient | Proposed `COMPILER-BYTECODE-JUMP-RESOLUTION` | The method emits `JZ` to label 1 and `JNZ` to label 2 and checks only that resolution returns success and both opcodes remain present. It never checks either rewritten argument, distinct targets, direction, serialized offsets, or that one label was not accidentally substituted for the other. The topology is not owned by a current product, but the present assertions do not prove the method's “independently” claim. |
| `Compiler/AngelscriptNativeBytecodeJumpTests.cpp` | `FBytecodeJumpTests` | `JumpToUnresolvedLabelReturnsError` | `ProductOwned` after adding failure-state and recovery evidence | Proposed `COMPILER-BYTECODE-JUMP-RESOLUTION` | The method emits a jump to missing label `99`, appends `RET`, and checks only that `ResolveJumpAddresses()` is negative. No current Compiler bytecode product has an unresolved-label outcome axis. A full owner must additionally prove the linked/serialized state after rejection, retained payload/instructions, absence of partial rewrite, a subsequent repair/retry or clean fixture recovery, and cleanup/isolation. |
| `Compiler/AngelscriptNativeBytecodeJumpTests.cpp` | `FBytecodeJumpTests` | `JumpAcrossAddedSequences` | `ProductOwned` after strengthening exact target and composition evidence | Proposed `COMPILER-BYTECODE-JUMP-RESOLUTION` | The method creates a head sequence containing `JMP(label 5)` and a payload, creates a tail with another payload and label 5, calls `AddCode`, observes increased serialized size, and requires resolution success. This cross-sequence target is not covered by the current container product: that product tests `AddCode` payload/order separately and forward resolution inside one generated container, but not a jump whose label arrives from the appended sequence. The method still needs the exact rewritten offset/target, final linked order, both payloads, serialized parity, ownership of the consumed tail, and failure/recovery counterparts. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `FCompilerCoreTests` | `CompilerCoreSimpleFunction` | `ExplicitNonProduct / LegacyCompatibility` | `COMPILER-BUILDER-SHAPE-FAILURE` | The method creates a case-owned engine, builds one one-line function, and checks exact declaration lookup. It does not execute the function, inspect bytecode/metadata beyond lookup, or print the source. `COMPILER-BUILDER-SHAPE-FAILURE` owns successful basic-function publication through the builder stages, exact entry discovery, runtime `42`, metadata, source logging, cleanup, and the corresponding failure forms. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `FCompilerCoreTests` | `MultipleFunctions` | New product work; do not map to the current single-shape product | Proposed `COMPILER-BUILDER-MULTI-FUNCTION-PUBLICATION` | The method builds sibling functions `A`, `B`, and `C`, checks count `3`, and checks only exact lookup of `C`. The current Compiler products do not declare function cardinality, sibling inventory, ordering, overload/name interaction, or cross-sibling calls. The present method also fails to look up all three declarations, execute them, inspect indexed identity/order, print the source, or vary cardinality. A new product should cover zero/one/many functions, declaration shapes/overloads/namespaces, indexed and exact lookup, sibling calls, section ownership, and rejection without partial publication. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `FCompilerCoreTests` | `CompilerCoreGlobalVariables` | New product work or temporary `ExplicitNonProduct / LegacyCompatibility`; not fully superseded | Proposed `COMPILER-BUILDER-MULTI-GLOBAL-PUBLICATION`; partial overlap with `COMPILER-BUILDER-SHAPE-FAILURE` | The method builds two constant globals plus `Read`, checks global count `2`, and executes `Read` to `42`. `COMPILER-BUILDER-SHAPE-FAILURE` owns a representative const-global builder shape and its runtime/publication rejection, but its axes do not promise multiple-global cardinality, exact names/types/addresses, declaration order, or initializer dependency order. The current method's two-global aggregate is unique but shallow. If retained as coverage, introduce cardinality, type, initializer dependency, namespace, and success/failure axes with indexed metadata and exact runtime values; otherwise mark it a legacy representative only after that stronger owner exists. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `FCompilerCoreTests` | `CompilerCoreBasic` | `ExplicitNonProduct / AggregateSupport` | Primary owner `COMPILER-BUILDER-SHAPE-FAILURE`; arithmetic/control-flow details belong to `COMPILER-BYTECODE-SHAPE` | The method compiles one aggregate source containing a const global, multiplication function, and boolean `Entry`, then executes `Entry == true`. It prints no generated source and separately proves none of global metadata, function inventory, bytecode, diagnostics, or stage transitions. The focused builder and bytecode products own those feature contracts. Retaining this method as an end-to-end aggregate smoke is reasonable, but it must not be counted as independent depth for each construct. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `FCompilerCoreTests` | `CompilerCoreConfig` | `ExplicitNonProduct / LegacyCompatibility` unless a dedicated copied-section lifetime product is added | Proposed `ENG-PROPERTY-COPIED-SCRIPT-SECTION-LIFETIME`; existing `ENG-PROPERTY-ISOLATION` and `ENG-PROPERTY-PROFILE` do not include this property | The method only checks that setting `asEP_COPY_SCRIPT_SECTIONS` to true returns non-negative, schedules a write of false, and registers a no-count reference type. It does not read the property back, compile from a temporary source buffer, release/mutate the source, inspect retained section/debug text, execute code, verify restoration, or compare independent engines. The existing engine-property products intentionally omit `copy_script_sections`, so this cannot be mapped to them. The unrelated object-type registration result also does not prove copied-section semantics. |
| `Compiler/AngelscriptNativeCompilerCoreTests.cpp` | `FCompilerCoreTests` | `RecompileAfterError` | `ExplicitNonProduct / LegacyCompatibility` | `COMPILER-BUILDER-REBUILD-RECOVERY` | The method rejects one undefined identifier, clears messages without asserting them, rebuilds valid source under the same name, and executes `Entry` to `7`. `COMPILER-BUILDER-REBUILD-RECOVERY` prints invalid and recovery sources and varies syntax/missing-type/missing-brace × literal/namespace × same/fresh engine; it requires diagnostic, publication exclusion, cleanup/isolation, exact recovery lookup, and runtime. It is the stronger owner. |
| `Compiler/AngelscriptNativeOutputBufferTests.cpp` | `FOutputBufferTests` | `OutputBufferErrorCapture` | `ExplicitNonProduct / LegacyCompatibility` after assigning diagnostics to focused owners | Primary Compiler owner `COMPILER-BUILDER-SHAPE-FAILURE`; callback transport is more strongly owned by `ENG-MESSAGE-CALLBACK-CARTESIAN` and `ENG-MESSAGE-CALLBACK-LIFECYCLE` | The method builds one undefined-symbol source, checks build failure, scans for any error severity, and checks only that the message list is non-empty. It does not assert exact section, row, column, text, ordering, callback identity/lifecycle, no-publication metadata, source visibility, or recovery. The builder product owns compile rejection/diagnostic publication, while Engine products own exact callback transport across severity/location/payload and callback lifecycle. This is a weak integration smoke across those layers, not an independent output-buffer product. |
| `Compiler/AngelscriptNativeOutputBufferTests.cpp` | `FOutputBufferTests` | `OutputBufferWarningCapture` | `ExplicitNonProduct / Infrastructure` only if retained for manual logging; otherwise delete after stronger owners are verified | Proposed Compiler product `COMPILER-DIAGNOSTIC-SEVERITY-POLICY`, with callback transport owned by `ENG-MESSAGE-CALLBACK-CARTESIAN` | The method builds an unused-local source and only emits `AddInfo` lines for the observed messages. It does not assert that the module built, that a warning exists, that a warning is absent under a known profile, or any exact severity/location/text/policy. The comment admits configuration dependence, and “does not crash” is not asserted as a meaningful product result. Existing Engine callback products prove transport of explicitly written warning messages, but not compiler warning generation/policy. If warning policy matters, create a deterministic property/profile × diagnostic source × expected severity/build-outcome product; this method cannot own it in its present form. |

## Recommended product changes

The 17 methods should not produce 17 new products. The source evidence supports
four focused additions and a set of stronger-owner dispositions:

1. `COMPILER-BYTECODE-JUMP-RESOLUTION`
   - Direction: forward, backward.
   - Label topology: single, multiple independent, missing.
   - Composition: same sequence, appended sequence.
   - Outcome: resolved, rejected, repaired/retried.
   - Required evidence: linked instructions, exact signed target/offset,
     serialized parity, payload retention, post-failure state, cleanup, and
     isolation.
   - Absorbs the unique parts of four jump methods and makes the current
     multi-label and appended-sequence claims real.

2. `COMPILER-BYTECODE-RETURN-TERMINATION`
   - Add only if exact exit-bytecode behavior is intended to remain a stable
     fork contract.
   - Return shape should include void/scalar and single/multiple control-flow
     exits, with exact runtime and terminator/exit layout.

3. `COMPILER-BUILDER-MULTI-FUNCTION-PUBLICATION` and
   `COMPILER-BUILDER-MULTI-GLOBAL-PUBLICATION`
   - These are distinct cardinality/publication contracts not declared by the
     current single-shape builder product.
   - If that depth is judged unnecessary, retain the existing methods only as
     `LegacyCompatibility`; do not claim the present products cover axes that
     they do not declare.

4. `ENG-PROPERTY-COPIED-SCRIPT-SECTION-LIFETIME`
   - This belongs to Engine property/lifetime behavior rather than Compiler
     core compilation.
   - It must prove property readback, copied-buffer lifetime, source/debug
     metadata retention, runtime, restoration, and independent-engine
     isolation.

`COMPILER-DIAGNOSTIC-SEVERITY-POLICY` is additionally warranted if compiler
warning behavior is intended as a deterministic contract. Without that
requirement, `OutputBufferWarningCapture` is information-only infrastructure
and contributes no assertion-backed coverage.

## Disposition count for this reviewed batch

- 8 methods can map to stronger existing products as explicit non-product
  compatibility/aggregate evidence:
  - conditional bytecode
  - loop jump-family smoke
  - arithmetic buffer-difference smoke
  - forward jump
  - simple function
  - aggregate compiler core
  - rebuild after error
  - error capture
- 8 methods retain behavior not fully owned by current products and require a
  focused new product or an explicit decision to demote them to legacy
  compatibility:
  - return terminator
  - backward jump
  - multiple labels
  - unresolved label
  - appended-sequence jump
  - multiple functions
  - multiple globals
  - copied script-section lifetime
- 1 method (`OutputBufferWarningCapture`) has no assertion-backed compiler
  warning contract and should be infrastructure-only or replaced by a
  deterministic diagnostic-policy product.

This review resolves what should happen to these 17 rows, but it does not modify
the source/catalog reconciliation. They remain part of Compiler's reported 61
`Unowned` methods until the recommended source and catalog changes are applied.
