# Wave B remaining operator rewrites (B-operator-rest)

> **Queued exclusive UBT after B-compile-seal GREEN.** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Do **not** start while B-compile-seal holds `as_sema_expr.cpp` or this worktree's UBT. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2.

**Goal:** After `ttMinus`→`opSub` lands, grow the same snExpression rewrite for remaining binary operator methods that dumps would otherwise intern as builtin Binary.

**Architecture:** Same `OperatorMethodName` helper in `as_sema_expr.cpp`. One token pair per failing SemaAuthority compile→seal test. Production Bytecode stays `asCCompiler`.

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Package | **B-operator-rest** |
| Mode now | **LANDED 2026-08-21.** SemaAuthority **104/104**, CanonicalAST **119/119**, Compiler **307/307**. Did not mark `tasks.md`. `opMod` / unary `opNeg` not in this slice. |
| Gate | `OperatorMinusSelectsOpSubNotBuiltinBinary` PASS. Then `ttStar`→`opMul` and `ttSlash`→`opDiv` after RED of those two methods. |

## Do not implement until a RED test exists

Mirror `OperatorMinusSelectsOpSubNotBuiltinBinary` / `OperatorPlusSelectsOpAddNotBuiltinBinary`:

| Token | Method | Fixture sketch |
| --- | --- | --- |
| `ttStar` | `opMul` | `struct T { int opMul(int a) { return a; } }; return v * 3;` must dump `callee=T::opMul(int)`, not `kind=Binary literal=*` |
| `ttSlash` | `opDiv` | same shape with `/` |
| `ttPercent` | `opMod` | only if the fork accepts `%` on that type |

Do **not** batch all three into one helper expansion without watching each RED.

Unary `opNeg` / `opAssign` / comparison operators are later slices. Do not start them in the same UBT session as the first remaining binary if the RED set grows past one method.

## Verification (later exclusive UBT)

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-operator-rest-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-operator-rest-red -TimeoutMs 600000
```

Then minimal helper rows, then SemaAuthority + CanonicalAST + Compiler. Leave 13.2 `[ ]`. Do not start D Task 6.

## Forbidden

- Sharing UBT with B-compile-seal
- Editing `as_compiler.cpp` / `as_module.cpp` `Build()` / verifier / CodeGen
- Script `funcdef` / `@` / `is`
- Marking 13.2 from dump greens
