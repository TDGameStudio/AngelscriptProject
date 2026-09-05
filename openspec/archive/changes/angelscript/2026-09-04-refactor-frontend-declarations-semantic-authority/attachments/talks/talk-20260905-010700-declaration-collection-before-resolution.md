# Talk: Declaration collection before resolution

## Question

How should the reconstructed AngelScript frontend remove Parser/Builder/Engine declaration coupling while allowing every source file to refer to declarations in every other source file?

## Direct user evidence

The Temp transcripts contain user questions and requests, not a settled implementation specification. The following rows quote the intent category without treating the adjacent assistant answers as authority.

| Local source | User-authored intent | Consequence here |
|---|---|---|
| [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 208-210 | Asked why `asCParser` must receive `asCBuilder`. | The new Parser must have an explicit reason for every dependency; declaration work gets Sema/session services instead of Builder. |
| [Temp reconstruction transcript 2](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/2.md), lines 441-443 | Asked whether Builder can be created without Engine and what it reads from Engine. | Frontend options and semantic inputs are frozen values; a live Engine is not a frontend service locator. |
| [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 2315-2317 | Asked whether Builder and Engine can be decoupled and results batch-written later. | This Change stops before publication and creates the frozen semantic result required by a later transactional batch write. |
| [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2654-2656 | Pointed out that AngelScript does not have C++-style forward declarations. | The design cannot solve cross-file lookup by inventing source syntax or pretending a runtime stub is a language forward declaration. |
| [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3955-3957 and `4465-4467` | Asked whether Builder is analogous to Clang and how to decouple it from Engine. | Parser, Sema, AST context, compilation session, and eventual publication become explicit layers rather than one replacement god object. |

## Current source evidence

| Local source | Observation | Architectural pressure |
|---|---|---|
| `as_parser.cpp:1533-1543` | Parser constructors retain Builder or Engine pointers. | Parser cannot be independently instantiated from immutable frontend inputs. |
| `as_builder.cpp:1226-1244` | Builder construction binds Engine and module immediately. | Builder is not a neutral semantic context. |
| `as_builder.cpp:2101-2130` | `BuildParallelParseScripts` loops over scripts and calls `ParseScript` in sequence. | The name does not establish safe parallelism or deterministic fragment ownership. |
| `as_builder.cpp:2648-2684` | Builder determines type relations and completes/registers declaration products after parsing. | Declaration semantics and runtime construction are interleaved. |
| `as_builder.cpp:4297-4405` | Class handling constructs `asCObjectType` and mutates module/Engine collections. | A partially analyzed declaration can acquire runtime identity too early. |
| `as_decl.h:49-91`, `as_stmt.h:11-34`, `as_expr.h:44-69` | Root-level AST data uses wide enum-tagged records with many fields. | The approved AST Change must replace this shape in isolated `source/frontend/` code with concrete hierarchies before Sema can become authoritative. |

## Settled answer

The unit of work is a compilation session over a complete immutable source set. Each source may be collected in an isolated fragment. Parser recognizes grammar and calls typed Sema actions; Sema creates concrete declaration nodes and records unresolved type locations. No body semantics or runtime object is needed to finish collection.

After every source reaches the declaration barrier, the session deterministically merges declaration contexts and stable symbols. Sema then resolves bases, signatures, overloads, redeclarations, and references against that frozen set. This produces source-order independence without a new `import` statement, without a fake AngelScript forward-declaration syntax, and without pre-registering runtime objects.

## Rejected transcript suggestions

Adjacent AI-generated text in the Temp transcripts is research history, not user-approved design. In particular:

- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2591-2637 recommends registering Engine-side forward type stubs. That conflicts with the user's observation that AS has no such source-level model and with the approved no-live-Engine boundary.
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 2079-2101 similarly treats early `RegisterObjectType` calls as the answer. Runtime registry mutation is publication, not declaration collection.
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3959-4043 offers a useful rough comparison between Builder and Clang layers, but its role mapping is explanatory, not a final architecture. This Change adopts real Parser/Sema/typed-AST boundaries rather than renaming Builder.
- [Temp reconstruction transcript 3](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/3.md), lines 1441-1512 claims Parser fundamentally needs Builder for diagnostics, storage, and allocation. Current coupling explains those dependencies; it does not prove they belong together. Source diagnostics, AST ownership, and session storage are already separate prerequisites.

## Deferred decisions

This talk does not select runtime candidate layout, Engine transaction mechanics, Builder retirement, production compatibility policy, bytecode format, or VM ownership. Their entry criteria are recorded in the sequencing talk, and none is a task of this Change.
