# Helper headers → namespace + short types (Clang TestAST shape)

User 2026-09-12: `*TestHelper.h` should hold a **namespace**; short class names inside; CQTest `using` that namespace. Example: `FTestAST` like Clang `TestAST` + `TestInputs`.

Does not implement files. Q7 header stems (`LexTestHelper.h`, `ASTTestHelper.h`) can stay; the **type** inside need not be called `LexTestHelper`.

---

## How Clang does it

`clang/include/clang/Testing/TestAST.h`, namespace `clang`:

```
TestInputs                    // 虚文件：Code、语言、ExtraFiles、ErrorOK
TestAST(Inputs) / TestAST("int x = 42;")
    // 构造 = 跑 SyntaxOnly FrontendAction，活着就有 AST
    context() / sema() / sourceManager() / preprocessor() / diagnostics()
```

构造失败用 gtest `ADD_FAILURE()`，测试正文保持直线。**不是**给 Lexer 用的：一构造就 parse 整棵 TU。Lex 单测仍自己 `Lexer` / `CheckLex`。

---

## What we have today

```
NativeEngineTestSupport.h
namespace AngelscriptNativeEngineTest     // 已存在；多数 cpp 写全限定名
├─ FSourceInput::FromText                 // ≈ TestInputs（路径 + UTF-8 字节）
└─ FFrontendSessionRun                    // ≈ TestAST：lex+PP+CollectSource，不是只构图
```

`LexerTests.cpp` 另有文件内匿名命名空间里的 `FLexerSource`（和「不准匿名命名空间」冲突）。没有 `FTestAST`。

Q18：TEST_CLASS 文件默认**不要**文件级命名空间；非泛型代码进 `private:`。这次提议的是 **helper 命名空间 + using**，不是把 `TEST_CLASS` 包进命名空间。

---

## Proposed shape (not written)

```
TestFramework/NativeEngine/ASTTestHelper.h     // Q7 文件名仍 *TestHelper.h
namespace <HelperNS>                           // 短类名住这里
{
    struct FTestInputs { ... };                // 源；以后可吃 AS_TEST_SOURCE 字节
    class FTestAST                             // 构造 = 前端会话 / 可问 Context、Sema、诊断
    {
        explicit FTestAST(const FTestInputs&);
        explicit FTestAST(FStringView Code);
        asCASTContext& Context() const;
        // Sema / Diagnostics 按我们真实 API 暴露，不抄 CompilerInstance
    };
}

// 某个 AST/Sema TEST_CLASS 的 .cpp
using <HelperNS>::FTestAST;
using <HelperNS>::FTestInputs;
TEST_CLASS_WITH_FLAGS(TypedNodes, "Angelscript.UnitTest.NativeEngine.AST", ...)
{
    TEST_METHOD(OneDecl)
    {
        FTestAST AST(TEXT("int X = 42;"));
        ...
    }
}
```

Lex **不要**用 `FTestAST`（会进 parse）。词法用 `FTestInputs` + 薄的 `CheckLex` / `FTestLexer`，对应今天的 `FLexerSource` + `CaptureTokenProjection`。

`FModuleDefinitionSetHelper`（Q11）若采用短名，以后再缩，不在这一刀改。

---

## Settled this slice

| ID | Choice | Meaning |
|---|---|---|
| Q29 A | `FTestAST` + `FTestInputs` | UE `F` + Clang words. Not `TestAST` without `F`. Not `*Helper` type names for this pair. |
| Q30 A | AST/Sema only | Construct-is-session. Lex uses `FTestInputs` plus a thin lex helper (`CheckLex` / later lex type). Not one `FTestAST` from Lex through Sema. |

`FTestLexer` is **not** a settled public name yet — only the layering.

---

## What Q28 is asking (plain)

Today every test writes the long name:

```
AngelscriptNativeEngineTest::FSourceInput Input =
    AngelscriptNativeEngineTest::FSourceInput::FromText(...);
```

Some files already shorten **one** alias inside the class:

```
using FSessionRun = AngelscriptNativeEngineTest::FFrontendSessionRun;
```

The user’s earlier wording is: put short types in a helper namespace, `using` that namespace in the CQTest cpp, then write `FTestAST` inside `TEST_METHOD`. That is option **A**.

Option **B** keeps today’s long names forever.

Option **C** wraps `TEST_CLASS` itself in the namespace. That would change Automation identities and fights Q18 (test TUs stay at file scope).

```text
ASTTestHelper.h
└─[owns] namespace <HelperNS>                          // short types live here so tests can using them
   ├─[type] FTestInputs                                // source bytes / path; Lex and AST both take this
   └─[type] FTestAST                                   // construct = parse session; AST/Sema only (Q30 A)

SomeASTTests.cpp
├─[using] using namespace <HelperNS>                   // or using <HelperNS>::FTestAST
└─[file-scope] TEST_CLASS TypedNodes                   // stays outside the namespace (Q18)
   └─[method] FTestAST AST(TEXT("int X = 42;"))        // short name visible inside the class
```

---

## Settled from Round 23 replies

| ID | Choice | Meaning |
|---|---|---|
| Q28 | TEST_CLASS stays at file scope | User: 「cqtest 不用进命名空间, cqtest 内部, 使用 using namespace」. Not option C. |
| Q31 | Per-helper namespace | User: 「每个Helper 自己的命名空间就行」. Not one shared `AngelscriptNativeEngineTest`. |

## C++ constraint (not a preference)

`using namespace X;` is legal at **file/namespace scope** and inside a **function body**. It is **illegal in a class body**.

So this does not compile:

```
TEST_CLASS(...)
{
    using namespace ASTTest;   // 非法：class 里不能 using namespace
    TEST_METHOD(OneDecl) { FTestAST AST(TEXT("int X = 42;")); }
}
```

Legal ways to get the same short names inside methods:

```
using namespace ASTTest;                 // 文件顶部，TEST_CLASS 之前
TEST_CLASS(...) { TEST_METHOD(...) { FTestAST AST(...); } }

TEST_CLASS(...)
{
private:
    using ASTTest::FTestAST;             // 合法：using-declaration，不是 using namespace
    using ASTTest::FTestInputs;
}

TEST_METHOD(...)
{
    using namespace ASTTest;             // 合法，但每个方法写一次
    FTestAST AST(...);
}
```

Today’s neighbours already use per-helper namespaces, never `using namespace` inside `TEST_CLASS`:

```
TypeOwnershipTestSupport.h  → namespace TypeOwnershipTest
RuntimeBindingTestSupport.h → namespace RuntimeBindingTestSupport
SyntaxTests.cpp             → class 里 using FSessionRun = ...::FFrontendSessionRun
```

Q18 forbids wrapping the `TEST_CLASS` in a namespace. A file-scope `using namespace` is a using-directive, not wrapping.

## Settled from Round 24

| ID | Choice | Meaning |
|---|---|---|
| Q32 B | Class-scope using-declaration | Inside `TEST_CLASS` `private:` write `using ASTTest::FTestAST;` — not `using namespace`. File-scope using-directive rejected. |
| Q33 A | `{Unit}Test` | `ASTTest`, `LexerTest`, `SemaTest`, matching today’s `TypeOwnershipTest`. Not `{Unit}TestHelper`, not nested under `AngelscriptNativeEngineTest`. |
| Q34 | held | User: 源码输入之后再敲定；可能有统一框架。`FTestInputs` remains the type name (Q29); its header/namespace wait. |

Example that matches Q18 + Q32 B + Q33 A (not written):

```
#include "ASTTestHelper.h"

TEST_CLASS_WITH_FLAGS(TypedNodes, "Angelscript.UnitTest.NativeEngine.AST", ...)
{
private:
    using ASTTest::FTestAST;
public:
    TEST_METHOD(OneDecl)
    {
        FTestAST AST(TEXT("int X = 42;"));
    }
}
```

## Settled from Round 25

| ID | Choice | Meaning |
|---|---|---|
| Q35 A | Public TestDir token | `LexerTest`, later `PreprocessorTest`. Headers may stay `LexTestHelper.h` until renamed. |
| Q36 A | Bindings same rule | `RecordTest`, `CallsTest`, …; generic units `BindingsEngineTest`, `BindingsTypesTest`. |

Derived NativeEngine namespaces (not written): `LexerTest`, `PreprocessorTest`, `ASTTest`, `SemaTest`, `IdentityTest`, `BuilderTest`, `LoweringTest`, `SourceExecTest`, `VMTest`, `LanguageSurfaceTest` (today’s TestDir, not inventory `Surface`), `ModuleDefinitionSetTest`. `TypeOwnershipTest` already matches.

## Held

- Q34 / source input home: user will settle a unified source framework later. `FTestInputs` is only the type name.
