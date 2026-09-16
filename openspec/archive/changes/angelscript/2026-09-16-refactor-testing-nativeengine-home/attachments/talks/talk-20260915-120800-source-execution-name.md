# SourceExecution is not Compile; Preprocessor joins Lexer

## Context

Current tests use `Compiler/` for source-to-VM cases. Production `frontend/Compile` is the session and builder-stage surface. Production preprocessor lives under `frontend/Lexer`.

## Evidence

[Target taxonomy](../drafts/findings/target-taxonomy.md). `Compiler/VMSource*` files execute source through bytecode and the VM. `Builder/` and compile-lifecycle tests match `frontend/Compile` more closely.

## Options

| Option | Result |
|---|---|
| A. SourceExecution for source-to-VM; Compile for session/stages; Preprocessor under Lexer | Names match proof layer and production |
| B. Keep a top-level Preprocessor TestDir | Readable, but not production-aligned |
| C. Keep the folder name Compiler for source-to-VM | Collides with Compile |

## Settled Decision

Option A.

## Consequences and Flip Condition

Phase 1 moves `VMSource*` into `SourceExecution/` and preprocessor tests into `Lexer/`. Reopen only if source-to-VM is later declared a Compile-only concern with no VM oracle.

## Visual

```text
frontend/Lexer      -> NativeEngine/Lexer (+ Preprocessor)
frontend/Compile    -> NativeEngine/Compile
source -> bytecode -> VM -> NativeEngine/SourceExecution
```

## Sources

Exploration Round 3 Q7.
