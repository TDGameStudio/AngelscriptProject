# NewVersion was a four-tenant shell

Disposition: candidate. Origin: angelscript/refactor-testing-nativeengine-home exploration inventory on 2026-09-15. Not promoted.

## Reusable Insight

A temporary physical directory named for "the new suite" can accumulate unrelated public identities. Deleting the directory is not the same as moving one test tree. Each public prefix needs its own durable home.

## Evidence

[Current layout](../drafts/findings/current-layout.md) counted NativeEngine, Bindings (`RuntimeBindings.*`), Framework, and Baseline tenants under `NewVersion/`, while Lexer already lived at module-root `NativeEngine/Lexer/`.

## Boundaries

This is about replacement Automation layout under `AngelscriptTest`. It is not a claim about production `frontend/` folders or about Legacy isolation.

## Application

Before retiring a temporary test root, list tenants by public Automation prefix, not by folder name alone. Do not place Bindings or TestCode-framework tests under NativeEngine.

## Sources

[Current layout](../drafts/findings/current-layout.md). Talk: four-tenant homes.
