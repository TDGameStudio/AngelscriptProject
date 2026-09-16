# Current replacement-test layout (2026-09-15)

English export of the local inventory. Source identity: angelscript/newversion-retirement findings/current-layout.md. Observations, not a proposal.

`NewVersion/` is a temporary physical shell. The baseline spec already allows registering units under module-root `NativeEngine/` and forbids `NewVersion` in public test names. Lexer has already moved; everything else still sits in the shell.

`NewVersion/` is not NativeEngine-only. It has four tenants:

```text
AngelscriptTest/
├─ NativeEngine/Lexer/                 // durable home already open: 3 cpp / 3 classes / 31 methods
├─ TestFramework/NativeEngine/         // replacement helpers; Tokenizer still used by Lexer
│                                      // AST header is empty
├─ NewVersion/                         // temporary shell
│  ├─ NativeEngine/                    // 130 cpp / ~138 classes / 1182 methods
│  ├─ Bindings/                        // 42 cpp / 43 classes / 314 methods
│  ├─ Framework/ + FrameworkTests/     // TestCode center + 7 self-test cpp / 40 methods
│  └─ AngelscriptIsolationBaselineTests.cpp  // 3 Baseline simple Automation tests
├─ TestCode/                           // generated Language corpus; not a NewVersion tenant
└─ Legacy/                             // .ubtignore isolated; not compiled by default
```

Production frontend is `AngelscriptRuntime/angelscript/frontend/{Lexer,Parser,AST,Sema,Compile,Basic}/`, not a source tree named NativeEngine. Durable test homes are `AngelscriptTest/NativeEngine/`.

CQTest composes `TestDir.Class.Method`. Physical folders need not appear in the name. Lexer already nests TestDir as `Angelscript.UnitTest.NativeEngine.Lexer`. Most other NativeEngine classes still use the flat TestDir `Angelscript.UnitTest.NativeEngine`. Bindings use `RuntimeBindings.*`. Framework uses `Framework`. Baseline uses simple Automation names under `Angelscript.UnitTest.Baseline.*`.

There is no `Parser/` test tree. The current `Compiler/` folder is source-to-VM, not `frontend/Compile`.

## Conclusion

1. Deleting `NewVersion/` requires durable homes for all four tenants.
2. Lexer already shows the durable folder plus nested TestDir pattern.
3. Current NativeEngine subfolders are historical theme names, not a `frontend/` mirror.
4. Literal `NewVersion/Framework/...` includes break when the shell is removed.
