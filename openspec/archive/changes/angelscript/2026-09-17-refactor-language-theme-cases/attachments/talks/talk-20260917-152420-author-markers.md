# Talk: @begin, @function, @summary

## Context

Case identity was overloaded onto `@version`. Closing used unnamed `@end`. Callables had no mark. Pending functions carried a richer comment block.

## Evidence

The live grammar has no `@begin`. Annotation marks are one token. Pending comments use `@Inputs` / `@Return` / an unlabeled first paragraph.

## Options

Open/close: `@begin <tag>` plus unnamed `@end` versus paired names versus keep `@tag`.
Entry: `@function` versus `@entry` versus `UFUNCTION`.
Description: `@summary` versus `@description`.

## Settled Decision

Q12=B1 `@begin <tag>` plus unnamed `/** @end */`. Q14=`@function`. Q17=function description is `@summary`. Q15=C2 function-header block and Q16=D1 fields (`@inputs` / `@return`, optional `@covers`) at R20.

## Consequences and Flip Condition

A third parse layer (function header) is required; it is not `@point`. Flip if Bindings mashups later prove the contract must live on the case header only.

## Visual

```
file header     @version v1 + @summary
case header     @begin tag + @summary
function header @function + @summary + @inputs + @return
```

## Sources

Exploration log R11, R14, R19. Approval R20.
