# Compiler Assertion-Depth Repair Review

## Scope and review method

This is the independent post-repair review of the 17 Compiler products marked
`ChangeRequired` in `assertion-depth-frontend-compiler-review.csv`.

Each product was checked against:

- its current catalog evidence and expected behavior;
- the exact current owner and any shared helper used by that owner;
- compile, diagnostic, metadata, bytecode, debug, runtime, lifecycle, cleanup,
  isolation, and recovery assertions where declared;
- explicit module removal and `asGM_ONLY_IF_EXISTS` null lookup where cleanup
  is claimed;
- independent engine/module, native-storage/type identity, or before/after
  property observations where isolation is claimed.

The detailed row-level evidence is recorded in
`assertion-depth-compiler-repair-review.csv`.

## Final disposition

- Repair-review scope: 17 Complete, 0 ChangeRequired, 0 Deferred.
- Original Compiler rows already Complete: 12.
- Current Compiler assertion-depth disposition: 29 Complete,
  0 ChangeRequired, 0 Deferred.

No row was promoted merely because the parent prefix passed. Every promotion
has a source-level oracle for each currently declared evidence category.

## Closure by concern

### Located rejection and recovery evidence

`COMPILER-BUILDER-SHAPE-FAILURE` and
`COMPILER-BUILDER-REBUILD-RECOVERY` now require the exact failed builder stage,
diagnostic section, row, and message fragment. Rejected functions cannot carry
executable bytecode. The invalid module is explicitly removed before recovery;
same-engine and fresh-engine recovery both publish `Entry`, execute the exact
result, and remove the replacement module.

### Per-cell module ownership and isolation

The four direct builder application products cover 84 generated cells:

- function declarations: 48;
- scalar declarations: 12;
- template declarations: 12;
- property verification: 12.

Each cell starts with absent same-name case/control modules, creates distinct
module identities in independent engines, preserves the control, and
explicitly removes both modules. Property verification additionally checks an
unchanged control `TypeInfo` identity and property count before and after each
cell.

### Diagnostics and direct CompileFunction

The warning-policy owner uses a before/after warning-property observation.
Warning promotion compares an independent engine's policy. The three direct
`CompileFunction` products remove the product module and then compile a clean
control function, asserting publication identity, absence of leaked symbols or
diagnostics, and final control-module removal.

The primary warning-promotion property is restored by its scope guard; the
isolation disposition does not depend on that unobservable scope exit. It rests
on the asserted independent-engine property baseline.

### Publication, storage, layout, and parse teardown

Declaration publication, const globals, class layout, and parse-only products
release transient builder/parser or AST observations before module removal.
Their independent controls are behavior-specific:

- declaration publication and parse-only state remain absent in a second
  engine;
- const-global native storage retains exact address and value identity;
- class-layout native type identity remains unchanged and a second engine has
  no published class or module.

The staged class-layout route and finalized public runtime route are both
removed explicitly.

### Bytecode products

Bytecode shape and optimization cells explicitly remove the exact module after
their opcode, debug/metadata, and runtime assertions. The object-layout shape
continues to record the current-fork local reference-class construction
limitation and does not claim unsupported method execution.

## Runtime support

The completed Compiler parent-prefix run is `120/120 PASS`. This supports the
review by showing that the current owners execute together, but it is not the
basis for any `Complete` disposition; the CSV records the source assertion
that closes each prior gap.
