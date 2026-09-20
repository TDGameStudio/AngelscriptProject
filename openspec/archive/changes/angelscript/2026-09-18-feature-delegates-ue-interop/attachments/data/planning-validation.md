# Planning validation

Self-review 2026-09-18 for `angelscript/feature-delegates-ue-interop`.

## Coverage

Every requirement and acceptance condition in `tasks.md` `## Requirement coverage` maps to a task:

| Requirement / scenario | Task |
|---|---|
| Remaining interface names, planning-validation, source API confirm | 1.1 |
| 60 DECLARE forms via one table + 60-row matrix | 1.2 |
| Typed Bind/Add plans | 1.3 |
| Definition-graph CallPtr returns 42 | 1.4 |
| Removed-keyword and unsupported-family diagnostics | 1.5 |
| Preprocess does not wrap DECLARE_* or leftover keywords | 1.6 |
| Flavor-aware definition-graph type and FAngelscriptDelegateDesc | 1.7 |
| Execute / Broadcast on CompileModules | 2.1 |
| Explicit named-target payloads | 2.2 |
| Multicast handle mutation | 2.3 |
| Native TDelegate adapters | 3.1 |
| UDelegateFunction / property materialization | 3.2 |
| Blueprint and script dynamic invocation | 3.3 |
| Editor/cooked load and invalidation | 4.1 |

Delta specs under `specs/angelscript/**` keep the same mapping: lexing reject (1.5), declarations (1.2/1.5), preprocessing (1.6), bodies CallPtr (1.4/2.1), reflection-dependencies (1.7/3.2), language-fixtures catalog (1.2 notes), runtime delegates (2.1–2.3), bindings delegates (3.1–3.3/4.1).

## Placeholder scan

`tasks.md` has no TBD, TODO, implement later, fill in details, or empty Interfaces fences. 4.1 cook route is no longer unspecified: `planning-contracts.md` records `ue.commandlet` `Commandlet=Cook`.

## Symbols

Glossary / design names `asECallableFlavor`, `bIsDynamic`, `DelegateDeclarations`, `DelegateBinding`, `DelegateCallRetVal`, `DelegateDiagnostics`, `DelegatePreprocess`, `DelegateRegister`, `DelegateExecute`, `DelegatePayloads`, `DelegateMulticast`, `DelegateNativeInterop`, `DelegateReflection`, `DelegateDynamicInterop`, `DelegateLifecycle` match the producing cards. Inspected source names (`ParseCallableDeclaration`, `ActOnCallableType`, `ProcessDelegates`, `CreateCallableType`, `FAngelscriptDelegateOperations`, `CreateFullReloadDelegate`) match current `file:line` citations. Assumed names that do not exist yet are listed in `planning-contracts.md`.
