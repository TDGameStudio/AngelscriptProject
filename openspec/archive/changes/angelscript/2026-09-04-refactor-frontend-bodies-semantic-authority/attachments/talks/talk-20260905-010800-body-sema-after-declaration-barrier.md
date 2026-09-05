# Talk: Body Sema after the declaration barrier

## Question

Where should expression typing, control-flow meaning, cleanup obligations, and recovery live when the frontend is separated from Builder, Engine, bytecode, and VM concerns?

## Direct user evidence

The Temp files are conversation transcripts. Only the explicitly marked user passages are treated as intent; assistant passages are hypotheses that must be checked against source and the current approved constraints.

| Local source | User-authored intent | Consequence here |
|---|---|---|
| [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 3-12 | Requested the actual Parser call chain, lifecycle, purpose, and data formats. | Body Parser/Sema ownership and phase inputs/outputs must be explicit and testable. |
| [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 208-210 | Asked why Parser must receive Builder. | The new body Parser receives bounded grammar services and Sema, not the legacy orchestration object. |
| [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 441-443 | Asked whether Builder can exist without Engine and what Engine information it needs. | Semantic options are frozen before body work; live Engine queries are not permitted. |
| [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 2315-2317 | Asked to decouple Builder/Engine and batch generated data back later. | Typed body semantics complete the frontend result; candidate construction and transactional publication remain later work. |
| [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3955-3957 and `4465-4467` | Asked how Builder relates to Clang and how it can be decoupled from Engine. | The design extracts real Parser/Sema/AST phases instead of relabeling Builder or putting Engine behind a facade. |

## Current source evidence

| Local source | Observation | Architectural pressure |
|---|---|---|
| `as_parser.cpp:4234-4251` | Parser performs per-script final Sema callbacks immediately after parsing one script. | Whole-session declaration freezing must precede body lookup and cross-file resolution. |
| `as_stmt.h:11-34` and `as_expr.h:44-69` | Statements and expressions are wide records distinguished by enum fields. | The approved concrete hierarchy cannot be approximated by populating more optional fields. |
| `as_sema.h:1333-1499` | The retained Sema already exposes many expression and statement actions. | These are useful semantic coverage inventory, but their root data model and ownership are not the new contract. |
| `as_compiler.h:245-257` | Compiler construction and compile entry points take `asCBuilder*`. | Executable lowering remains coupled and must not define body semantics in this Change. |
| `as_compiler.cpp:86-126` | Compiler construction derives Engine state from Builder. | Running legacy compiler/bytecode generation would violate the no-live-Engine body boundary. |

## Settled answer

Declaration Sema first freezes every callable, type, context, and overload set. Each valid function then becomes a deferred body work item. A body-local Parser recognizes grammar and calls body-local Sema actions. Sema performs lookup and overload resolution against the frozen declaration environment and creates concrete typed statement/expression nodes, explicit conversions, value categories, semantic control targets, and source-language lifetime facts.

Each work item owns an isolated typed fragment and diagnostic stream. Finalization attaches fragments in stable function/source order and remaps local identities. A malformed body yields typed recovery nodes and diagnostics but cannot mutate declarations or produce an executable candidate. Bytecode and VM are consumers of this result in a later architecture batch, never authorities for whether the source is semantically valid.

## Rejected transcript suggestions and shortcuts

- [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 1441-1512 argues that Parser inherently needs Builder for diagnostics, AST storage, and allocation. Those are observations about current ownership, not a reason to preserve it; the preceding source/diagnostic and AST Changes provide dedicated owners.
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3959-4043 maps Builder roughly to Sema plus orchestration. The analogy is useful only as a decomposition prompt. A Builder facade that still performs Engine lookup and bytecode work is not a separated Sema.
- Treating root `asCStmt`/`asCExpr` enum records or side tables as a “typed AST” is rejected. Concrete inheritance, casting, visiting, and node-owned semantic relationships are approved prerequisites.
- Testing body correctness by emitted bytecode is rejected for this stage. It conflates language meaning with one backend and would make later VM decoupling harder.

## Deferred decisions

This Change does not decide executable candidate shape, bytecode format, stack allocation, opcode selection, runtime function construction, Builder retirement, transactional Engine publication, JIT integration, or VM ownership. The reconstruction sequencing talk defines when those topics become ready for their own Changes.
