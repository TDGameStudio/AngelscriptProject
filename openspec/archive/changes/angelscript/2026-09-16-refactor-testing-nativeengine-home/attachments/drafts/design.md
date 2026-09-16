# Accepted design: NativeEngine test homes and language coverage

Source: angelscript/newversion-retirement, selected design nativeengine-test-home. Approved 2026-09-15 (layout and coverage in Round 7; combined delivery in Round 8). This English export is the accepted design, not the exploration transcript.

## 1. Scope

Delete `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/` as a source root. Place the four tenants at the module root. Recut NativeEngine by proof layer. Register public identities as `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`. Then fill the Parser unit tree and the language core matrix through VM execution.

Phase 1 success:

- `NewVersion/` is no longer a source root.
- `ue.test` can select one layer, for example `Angelscript.UnitTest.NativeEngine.VM` contains only VM.
- Framework, Bindings, and Baseline public prefixes stay the same.
- `WITH_ANGELSCRIPT_TESTS=1` and `WITH_ANGELSCRIPT_UNITTESTS=0`.

Phase 2 success:

- `Parser/` has Contracts, Recovery, and Precedence classes and an independently runnable prefix.
- Every axis in section 4 has a positive case, a boundary case, and a rejection.
- Positive expression cases use runtime inputs, not constant folding alone.
- Retired syntax has an explicit rejection list.

Out of scope:

- Production `frontend/` changes.
- Implementing `angelscript/refactor-testing-unified-framework`.
- Rewriting TestCode corpus contents, or treating `.as` file counts as execution evidence.
- Bindings surface expansion, JIT, Standalone, or Legacy Frontend corpus mapping.
- A second source-level suite for every VM opcode.
- Turning foreach from rejection into a supported product in this Change.

## 2. Target tree

```text
AngelscriptTest/
├─ NativeEngine/
│  ├─ Basic/                 // gate smoke; class remains Foundation
│  ├─ Lexer/                 // existing plus Preprocessor
│  ├─ Parser/                // home in phase 1; tests in phase 2
│  ├─ AST/
│  ├─ Sema/
│  ├─ Compile/
│  ├─ SourceExecution/
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
└─ TestFramework/NativeEngine/  // helpers only
```

## 3. Phase 1 relocation

| Current | Destination | TestDir |
|---|---|---|
| Root Foundation / SourceInput / … | Basic/ | `...Basic` (class `Foundation`) |
| NativeEngine/Lexer | keep | `...Lexer` |
| Preprocessor | Lexer/ | `...Lexer` |
| AST | AST/ | `...AST` |
| Declarations + Bodies | Sema/ | `...Sema` |
| LanguageSurface | split into Parser / Sema / SourceExecution | by landing |
| Builder + CompileLifecycle + ModuleGraph + Reflection + Api | Compile/ | `...Compile` |
| Compiler/VMSource* | SourceExecution/ | `...SourceExecution` |
| Diagnostics + SourceDiagnostics | Diagnostics/ | `...Diagnostics` |
| Tooling | Tooling/ | `...Tooling` |
| Definitions | Definitions/ | `...Definitions` |
| Identity | Identity/ | `...Identity` |
| TypeOwnership | TypeOwnership/ | `...TypeOwnership` |
| Registration | Registration/ | `...Registration` |
| VM | VM/ | `...VM` |
| NewVersion/Bindings | Bindings/ | `RuntimeBindings.*` unchanged |
| Framework(+Tests) | Framework/ + FrameworkTests/ | `Framework` unchanged |
| IsolationBaseline | Baseline/ | `Baseline.*` unchanged |

Must rewrite `NewVersion/Framework/...` includes, module entry points, generated TestCode, AngelscriptTestJIT, the angelscript-test skill, and `testing/baseline`. Delete the empty `NativeEngineASTTest.h`.

Retired flat Automation names. A class token must not equal its Layer.

```cpp
TEST_CLASS_WITH_FLAGS(
    Foundation,
    "Angelscript.UnitTest.NativeEngine.Basic",
    EditorContext | EngineFilter)
{
    TEST_METHOD(ReplacementGateProvidesCQTest) { /* ... */ }
};
// Angelscript.UnitTest.NativeEngine.Basic.Foundation.ReplacementGateProvidesCQTest
```

## 4. Phase 2 language core matrix

Default oracle is SourceExecution: compile, link, execute. Sema rejection cells do not require the VM.

| Axis | Positive | Boundary | Rejection |
|---|---|---|---|
| Arithmetic `+ - * / %` | Integer widths and float/double with runtime variables | Division by zero; signed overflow per product | Illegal type pairs |
| Compound assignment `+= -= *= /= %=` | Visible lvalue update | Const / read-only lvalue | Non-lvalue |
| Comparison and logic | `== != < <= && \|\| !` with short-circuit | Empty statements; side-effect order | Incomparable types |
| Bitwise | `& \| ^ ~ << >>` and compounds | Over-wide shift | Bitwise on float |
| Control flow | if/else, while, do, full for, switch, break/continue/return, ternary | Omitted for clauses; comma expressions | Illegal case; break at the wrong level |
| Calls | Positional, defaults, overloads, methods, `N::F()` | Named arguments; this | Return-type-only fake overloads |
| Objects | struct/class ctor/dtor order; member read/write | Inherited same-name dispatch | Illegal inheritance if the product rejects it |
| Storage | Locals, members, reference write-back | Init storage class | Script-mutable module globals if still rejected |
| Conversion | Explicit casts; builtin widening | Failed narrowing | Unrelated forced casts |
| Retired | — | — | shared/external, foreach if still retired, escaping anonymous functions |

Parser classes: `Contracts`, `Recovery`, `Precedence`.

Order: Parser, then operators, control flow, calls, objects/storage, conversions and the rejection inventory. Each group has its own RED/GREEN. After the move, mark overlap with existing methods and write only the missing cells.

## 5. Verification

Phase 1: `ue.build`, then Fast smoke on Basic, Lexer, VM, Framework, RuntimeBindings, and Baseline. At close-out, zero retired flat names under `Angelscript.UnitTest`.

Phase 2: exact `...Parser` or `...SourceExecution` (and Sema rejection) prefixes per group. Lexer and VM remain non-regression prefixes.

## 6. Risks

- Nested renames stale other Change task prefixes; phase 1 lists old-to-new paths.
- The matrix can grow; the axis table is the contract.
- `refactor-testing-unified-framework` may still mention NewVersion; this Change updates current skill/spec text only and does not implement that Change.
