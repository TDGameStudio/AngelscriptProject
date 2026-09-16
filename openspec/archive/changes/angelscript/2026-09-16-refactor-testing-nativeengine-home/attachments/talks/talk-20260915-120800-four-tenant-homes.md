# Four tenants leave NewVersion for separate homes

## Context

The user asked to delete the temporary `NewVersion/` directory and put its tests under NativeEngine. Inventory showed four tenants in that shell, not one.

## Evidence

[Current layout](../drafts/findings/current-layout.md): NativeEngine (~1182 methods), Bindings (314, `RuntimeBindings.*`), Framework plus FrameworkTests (40, `Framework`), and three Baseline Automation tests.

## Options

| Option | Result |
|---|---|
| A. Retire the whole shell; each tenant gets a module-root home | NewVersion can disappear; public prefixes stay honest |
| B. Move only NativeEngine tests | The shell cannot be deleted |
| C. Dump every tenant under NativeEngine/ | Bindings and Framework identities and duties collapse |

## Settled Decision

Option A. NativeEngine tests go to `AngelscriptTest/NativeEngine/`. Bindings, Framework, FrameworkTests, and Baseline get their own module-root homes. Bindings and Framework are not placed under NativeEngine.

## Consequences and Flip Condition

Phase 1 must rewrite Framework includes that still say `NewVersion/Framework/...`. Reopen only if Bindings or Framework are later declared NativeEngine proof layers, which they are not today.

## Visual

```text
NewVersion/
├─ NativeEngine  -> AngelscriptTest/NativeEngine/
├─ Bindings      -> AngelscriptTest/Bindings/
├─ Framework     -> AngelscriptTest/Framework/
└─ Baseline      -> AngelscriptTest/Baseline/
```

## Sources

Exploration Round 1 Q1. [Current layout](../drafts/findings/current-layout.md).
