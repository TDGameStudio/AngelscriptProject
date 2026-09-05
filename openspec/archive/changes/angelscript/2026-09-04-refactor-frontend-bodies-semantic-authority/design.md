## Context

The declaration Change establishes a whole-source barrier, a frozen canonical declaration environment, and deferred function-body ranges. This Change is its direct consumer. Changes 1-6 in the reconstruction sequence are transitive prerequisites; the cross-Change order is documented by `angelscript/refactor-frontend-declarations-semantic-authority/attachments/talks/talk-20260905-010701-frontend-reconstruction-sequencing.md`, not duplicated as task-graph edges.

The retained root implementation already contains many Sema-like action methods, but it stores statement and expression facts in wide enum-tagged records and still coexists with Builder/Engine-bound compiler work. `asCCompiler` is constructed from `asCBuilder` and emits bytecode-oriented results. Those files are reference evidence, not a base to expose as the new body contract.

All new code remains under `ThirdParty/angelscript/source/frontend/`, inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`, with final leaf names and no `V2` suffix. It consumes the concrete `frontend::asCDecl`, `asCStmt`, `asCExpr`, `asCType`, `asCAttr`, and `asCASTContext` hierarchy from the AST Change.

## Goals / Non-Goals

**Goals:**

- Parse deferred bodies only against the frozen declaration result.
- Make concrete typed statement/expression nodes and Sema-authored semantic facts authoritative.
- Represent overload choice, conversions, value categories, control targets, and lifetime obligations before lowering.
- Recover locally and preserve useful typed structure and later diagnostics.
- Analyze independent bodies in deterministic isolated fragments.

**Non-Goals:**

- Change declaration collection or permit bodies to mutate the canonical declaration environment.
- Generate bytecode, VM/JIT instructions, stack layouts, runtime functions, or executable call targets.
- Construct runtime objects, publish to Engine/module registries, or switch production.
- Implement reflection/dependency projection, Builder replacement, candidate graphs, transactional publication, or VM decoupling.
- Add a new source-level `import` or another generic AST/semantic IR beside the concrete hierarchy.

## Decisions

### Deferred bodies become stable work items after declaration resolution

Each valid function declaration owns a deferred body descriptor containing its stable function key, source/token range, declaration context, and immutable frontend options. The descriptor is not a copied source string and does not contain runtime identity. A session creates body work only after declaration resolution freezes lookup and overload sets.

Functions whose declarations are invalid can be skipped while independent valid functions are still analyzed for diagnostic completeness. The session result records why a body is unavailable; absence cannot masquerade as a successfully empty body.

### Parser reports syntax; Sema creates typed meaning

Parser controls body grammar, precedence, bounded lookahead, delimiter matching, and synchronization. It calls typed Sema actions for literals, references, calls, operators, conversions, declarations, compound statements, control statements, lambdas, and other supported syntax. Sema performs name lookup, overload resolution, conversion ranking, contextual typing, value-category determination, and control-target validation, then creates concrete nodes through `frontend::asCASTContext`.

Implicit conversions and temporary materializations are explicit typed AST nodes. Resolved declarations use stable semantic identities. Parser never writes a generic `kind` plus optional fields as the final semantic representation, and Sema never asks a live Engine or Builder to decide source-language meaning.

### Lifetime belongs to semantics, not bytecode accidents

Each full expression and lexical scope has an explicit typed lifetime region. Sema records materialized temporaries, constructed locals, cleanup order, and the cleanup edges required by return/break/continue and other supported transfers. These facts use AST identities and stable type/declaration keys, not stack offsets or opcodes.

This creates a testable contract for later code generation and VM separation. It does not predetermine the executable representation; a later lowering may map the same obligations to bytecode, native code, or another backend.

### One body owns one isolated semantic fragment

A worker receives a deferred body descriptor plus read-only declaration and source services, then owns its Parser, Sema body state, typed-node arena, diagnostics, and lifetime facts. It returns an immutable `frontend::asCBodyFragment`. It cannot add declarations to the session-wide environment or mutate another body.

Finalization orders fragments by stable owning-function key, logical source range, and fragment-local ordinal, remaps local AST identities, attaches bodies to their declarations, and merges diagnostics deterministically. Worker count and completion order are excluded from semantic identity.

### Recovery creates typed nodes and preserves progress

Expression recovery creates concrete `asCRecoveryExpr` nodes with source range and canonical `asCErrorType` semantic state. Statement recovery creates typed recovery statements and synchronizes at grammar-aware delimiters or starters. Every failed parse either consumes input or exits the current construct; no loop may retry the same token indefinitely.

Recovered nodes are traversable, and valid later statements/functions remain analyzable. A fragment with unrecovered semantic errors can be finalized for inspection but is never marked executable or eligible for later publication.

### The output stops before executable lowering

The body result contains typed AST, resolved semantic references, structured diagnostics, and control/lifetime facts only. `asCCompiler`, runtime function construction, bytecode, VM, JIT, Builder adapters, and Engine publication are excluded. VM decoupling becomes discussable only after a later candidate/publication boundary defines the stable executable inputs.

## Risks / Trade-offs

- Per-body arenas require identity remapping when attached to the session AST. Stable keys and explicit fragment-local IDs prevent addresses from becoming cross-fragment identity.
- Some diagnostics depend on facts across multiple bodies. The default is independent analysis against frozen declarations; any true cross-body analysis must be an explicit deterministic finalization pass, not hidden shared state.
- Making implicit conversions explicit increases node count. It removes repeated downstream inference and provides a stable oracle for tests and later lowering.
- Lifetime semantics are easy to contaminate with current bytecode assumptions. Tests inspect source-language construction and destruction obligations only, keeping storage and opcode choices deferred.
