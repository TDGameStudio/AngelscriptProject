# Gate smoke uses theme Basic and class Foundation

## Context

`NativeEngineTestFoundationTests.cpp` already registers class `Foundation` with four gate and fixture methods. Nesting a layer also named Foundation would publish `Foundation.Foundation.*`.

## Evidence

Lexer and the baseline spec forbid a class token that repeats the layer token. The user rejected inventing `Gates` and asked to divide by a simple theme instead.

## Options

| Option | Result |
|---|---|
| A. Theme `Basic/`, keep class `Foundation` | `...Basic.Foundation.*`; no class rename |
| B. No extra theme; keep flat NativeEngine TestDir for these four | Shortest, but they stay outside layer prefixes |
| C. Foundation layer and rename the class to Gates | Extra name the user rejected |

## Settled Decision

Option A.

## Consequences and Flip Condition

Folder `Basic/` is the TestDir token. Do not create a Foundation layer. Reopen only if Basic later collides with another accepted theme; Diagnostics must not be renamed Basic.

## Visual

```text
Angelscript.UnitTest.NativeEngine.Basic.Foundation.ReplacementGateProvidesCQTest
```

## Sources

Exploration Round 6 Q9 and Q11.
