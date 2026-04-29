# Bindings/Shared/ — Coverage Section 基座

> 主 Plan：[`../../../../../../Documents/Plans/Plan_BindingsTestSuiteRefactor.md`](../../../../../../Documents/Plans/Plan_BindingsTestSuiteRefactor.md)  
> 子 Plan 索引：[`../../../../../../Documents/Plans/Plan_BindingsTestSuiteRefactor/README.md`](../../../../../../Documents/Plans/Plan_BindingsTestSuiteRefactor/README.md)

本目录是 `Bindings/` 测试目录的"Coverage Section"基座，把所有 SubPlan 共用的 Profile / Module RAII / 断言 helper 集中到一处。

## 文件清单

| 文件 | 角色 |
|------|------|
| `AngelscriptBindingsCoverage.h` | `FBindingsCoverageProfile` 结构体 + 模块名/标签格式化 |
| `AngelscriptBindingsModuleBuilder.h` | `FCoverageModuleScope` —— 编译时 BuildModule，析构时 DiscardModule |
| `AngelscriptBindingsAssertions.h` | `ExpectGlobalInt` / `ExpectGlobalIntAtLeast` / `ExpectGlobalBool` / `ExpectGlobalDouble` / `ExpectGlobalInts` / `ExecuteFunctionExpectingScriptException` |
| `AngelscriptBindingsExampleSection.h` | 50 行最简示例 Section（执行者抄改起点） |
| `AngelscriptBindingsExampleSectionTests.cpp` | 注册 `Angelscript.TestModule.Bindings.SharedExample`，端到端验证基座可用 |

## 命名空间

```cpp
using namespace AngelscriptTestBindings;
```

## 最简使用

```cpp
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

static const FBindingsCoverageProfile GMyProfile{
    TEXT("MyTopic"), TEXT(""), TEXT("ASMyTopic"),
    TEXT("MyTopic"), TEXT("MyTopicBindings"),
};

static bool RunMySection(FAutomationTestBase& Test, FAngelscriptEngine& Engine,
    const FBindingsCoverageProfile& Profile)
{
    FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Example"), TEXT(R"(
        int EchoOne() { return 1; }
        int EchoSum() { return 17 + 25; }
    )"));
    if (!ModuleScope.IsValid()) return false;
    asIScriptModule& Module = ModuleScope.GetModule();

    bool bPassed = true;
    bPassed &= ExpectGlobalInt(Test, Engine, Module, Profile,
        TEXT("int EchoOne()"), TEXT("EchoOne returns 1"), 1);
    bPassed &= ExpectGlobalInt(Test, Engine, Module, Profile,
        TEXT("int EchoSum()"), TEXT("EchoSum returns 42"), 42);
    return bPassed;
}
```

完整范例请直接读 `AngelscriptBindingsExampleSection.h` + 配套 `*Tests.cpp`。

## 关键约定

1. **模块名**：永远走 `MakeCoverageModuleName(Profile, SectionName)`（由 `FCoverageModuleScope` 内部调用），禁止文件内裸写 `BuildModule(..., "ASXxx", ...)`。
2. **case 函数返回值**：脚本侧每个 case 函数返回 int（0/1 或小数字），C++ 侧用 `ExpectGlobalInt` 断言。
3. **case 标签**：写"行为描述"而非"函数名"，例如 `TEXT("Empty Optional should not be set")`，因为函数声明已被 invoker 自动包含在失败信息中。
4. **share-clean 引擎**：所有 SubPlan 沿用 `ASTEST_CREATE_ENGINE_SHARE_CLEAN()` + `ResetSharedCloneEngine` 模式。
5. **AddExpectedError**：基座不接管，由具体 SubPlan 自己注册（旧文件中的注册必须迁移到新模块名 `MakeCoverageModuleName(Profile, ...)`）。

## 与 `AngelscriptTest/Shared/` 的关系

- 不复制 `AngelscriptGlobalFunctionInvoker` / `BuildModule` / `ASTEST_*` 宏，本目录直接 include `../../Shared/`。
- `AngelscriptGlobalFunctionInvoker` 仍是首选调用基座，本目录的 `Expect*` 只是它的一行式包装。复杂场景（多参数、struct return、out-ref）执行者直接用裸 invoker。

## 自检测试

`Angelscript.TestModule.Bindings.SharedExample` 是基座的金丝雀。执行：

```powershell
Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Bindings.SharedExample
```

绿色即基座可用；任何子 Plan 改造前都应先确认这个测试通过。
