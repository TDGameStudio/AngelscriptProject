# Target directories and identity tokens (accepted 2026-09-15)

English export of the local taxonomy finding after Q1, Q5, Q6, Q7, and Q9.

```text
AngelscriptTest/
├─ NativeEngine/
│  ├─ Basic/               // gate smoke; class Foundation
│  ├─ Lexer/               // existing; Preprocessor merged here
│  ├─ Parser/              // new
│  ├─ AST/
│  ├─ Sema/                // Declarations + Bodies
│  ├─ Compile/             // Builder stages, lifecycle, module graph, language service
│  ├─ SourceExecution/     // current Compiler/VMSource*: source to VM
│  ├─ Diagnostics/
│  ├─ Tooling/
│  ├─ Definitions/
│  ├─ Identity/
│  ├─ TypeOwnership/
│  ├─ Registration/
│  └─ VM/
├─ Bindings/
├─ Framework/
├─ FrameworkTests/
├─ Baseline/
└─ TestFramework/          // helpers only
```

Nested TestDir: `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`. The class token is not the Layer name. Bindings, Framework, and Baseline keep their current public prefixes.
