# Nest NativeEngine identities by proof layer

## Context

CQTest public names are `TestDir.Class.Method`. Most replacement NativeEngine tests used a flat TestDir. Lexer already nests `Angelscript.UnitTest.NativeEngine.Lexer`.

## Evidence

Flat names prevent a clean `ue.test` prefix for one proof layer. A prefix `...NativeEngine.VM` would also collide with `VMSource*` class names that are not VM-layer tests. Lexer already publishes nested names and forbids `Lexer.Lexer.*`.

## Options

| Option | Result |
|---|---|
| A. Nest every layer | Folder token equals TestDir; one prefix per layer; old flat names die |
| B. Keep flat names | Shortest move; new Parser tests stay in a flat sea |
| C. Nest only new layers | Two identity rules forever |

## Settled Decision

Option A. Public identity is `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`. Bindings, Framework, and Baseline prefixes do not change.

## Consequences and Flip Condition

Existing Harness prefixes and any locked dashboards break. Reopen if an external dashboard is contractually locked to the old flat names.

## Visual

```text
before: Angelscript.UnitTest.NativeEngine.VMScalar.ExecuteAdd...
after:  Angelscript.UnitTest.NativeEngine.VM.VMScalar.ExecuteAdd...
```

## Sources

Exploration Round 3 Q6. Baseline spec Lexer nested-TestDir scenario.
