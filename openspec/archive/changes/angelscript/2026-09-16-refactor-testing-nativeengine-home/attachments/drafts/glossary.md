# nativeengine-test-home vocabulary

English export of the selected design glossary. Identifiers are unchanged. Provenance: angelscript/newversion-retirement / nativeengine-test-home, approved 2026-09-15.

| Term | Chosen | Rejected | Reason |
|---|---|---|---|
| Change ID | `angelscript/refactor-testing-nativeengine-home` | retire-newversion; `test-` type | Confirmed Q15 |
| NativeEngine | `AngelscriptTest/NativeEngine/` | Runtime source tree | Q1 |
| Bindings | `AngelscriptTest/Bindings/` | Inside NativeEngine | Q1 T1 |
| Framework | `AngelscriptTest/Framework/` | Left under NewVersion | Q1 |
| FrameworkTests | `AngelscriptTest/FrameworkTests/` | Merged into Framework | Existing split |
| Baseline | `AngelscriptTest/Baseline/` | Loose module-root file | Q1 |
| Basic | Gate-smoke theme / TestDir | A Foundation layer | Q9 |
| Foundation | CQTest class under Basic | Gates | Q9 T4 |
| Lexer | Existing; includes Preprocessor | Top-level Preprocessor | Q7 T3 |
| Parser | New home | Sema-only indirect coverage | Q3 |
| AST | Keep | — | Q7 |
| Sema | Declarations + Bodies | Semantics | Q7 Q11 |
| Compile | Session / stages / module graph | Builder | Q7 |
| SourceExecution | Source to VM | Compiler | Q7 T3 |
| Diagnostics | Keep | Basic (collides with the gate theme) | Q7 |
| Tooling | Keep | Folded into Sema | Q7 |
| Definitions | Keep | — | Q7 |
| Identity | Keep | — | Q7 |
| TypeOwnership | Keep existing nest | — | Q7 |
| Registration | Keep | — | Q7 |
| VM | Keep | — | Q7 |
| Parser classes | Contracts, Recovery, Precedence | Parser | Matches Lexer; forbids Layer.Layer |

Shared topic terms used by this design: NewVersion (temporary shell to delete), proof layer (independently selectable test layer).
