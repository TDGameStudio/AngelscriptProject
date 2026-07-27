# Destructors and Lifetime Exit

## Dimensions

| Axis | Values |
| --- | --- |
| Owner/exit scenario | thirty-seven coherent local, nested-local, field, base/derived, temporary, returned-value, argument-copy, reference-alias, module-global, and engine-global workflows |
| Exit path | block end, function return, early return, break, continue, switch exit, exception, context abort, context unprepare, module discard, engine shutdown, only where the workflow owns the relevant state |
| Construction boundary | before root, root started, first owned storage, middle owned storage, all owned storage, completed construction/transfer |
| Nesting | one object, sequential objects, nested scopes, nested calls, loop iterations, recursive calls |
| Topology | independent, nested member, base/derived, copy transfer, assignment transfer, self-assignment, reference alias |
| Observation | exact count, exact reverse order, single destruction, no double destruction, remaining live count, callback/exception interaction |

## Required products

- `Thirty-seven coherent owner/exit scenarios × six nesting shapes × event-order/ownership-once/terminal-state-and-recovery observations`. Owner and exit are paired before multiplication so a local stack owner is not falsely treated as a module-global teardown object.
- `Nesting shape × exit path(return/break/continue/exception)` with concrete construction and reverse destruction sequence.
- `Construction failure point × initialized prefix` proving only initialized subobjects destruct once.
- `Base/member/derived relation × normal/exception exit` proving derived-before-base and reverse declaration order.
- `Copy/assignment/temporary form × exit path` proving independent ownership and no double destruction.
- `Context termination(abort/unprepare/release) × live stack/object state` where the raw SDK guarantees cleanup; unsupported/unsafe cases receive exact classification.
- `Seven ownership/transfer topologies × six real lifecycle boundaries × normal/exception/abort/unprepare` for partial cleanup. Boundary names refer to actual events in every topology; copy, assignment, self-assignment, and alias workflows map them to source/target/handle events explicitly.
- Twelve implicit/declared/native/empty/field/inherited/private/throwing/malformed destructor scenarios × compile/metadata/runtime/cleanup observation pin the declaration boundary separately from exit-path multiplication.

## Product ownership and scale

| Product ID | Cases | Purpose |
| --- | ---: | --- |
| `LANG-DTOR-OWNER-EXIT` | 666 | Thirty-seven coherent owner/exit scenarios × six nesting shapes × three observations |
| `LANG-DTOR-PARTIAL` | 168 | Seven ownership/transfer topologies × six real lifecycle boundaries × four exits |
| `LANG-DTOR-DECLARATION` | 48 | Twelve declaration/boundary scenarios × four evidence observations |

The three destructor products contain 882 expected cases. Exit and nesting cells must generate a concrete owner graph and teardown route; partial cells must name the reached event prefix. Unsupported context/module/engine combinations remain explicit classified behavior rather than omitted rows, but no cell fabricates a local owner for a teardown path that only owns module globals.

## Boundaries

Empty types, no-op/generated destructor, user-declared destructor, inaccessible/invalid destructor declaration where supported, exception thrown during destruction if the fork defines behavior, repeated context cleanup, module discard with retained object, and engine shutdown counters are included.

## Planned ownership

- `Language/Destructors/AngelscriptNativeDestructorExitTests.cpp`
- `Language/Destructors/AngelscriptNativeDestructorPartialConstructionTests.cpp`
- `Language/Destructors/AngelscriptNativeDestructorDeclarationTests.cpp`
