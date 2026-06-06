# Tasks: refactor-as-engine-inline-hook-accessors

## 1. Sanity-check accessor name collisions

- [x] 1.1 <!-- Non-TDD --> grep 19 `Get*()` accessor 名(`GetPreCompile` / `GetDynamicSpawnLevel` / `GetDebugBreakFilters` 等)在 `FAngelscriptEngine` 现有方法体里**没冲突**。结论:0 碰撞,可直接使用原名。

## 2. AngelscriptEngine.h 头部并入

- [x] 2.1 <!-- Non-TDD --> 把 `Core/AngelscriptEngineHooks.h` 的 13 个 `DECLARE_*_DELEGATE_*` 宏、`typedef ... EnumNameList` 与 `FAngelscriptDebugBreakOptions/Filters` typedef、9 个 forward declare(UClass/UEnum/UScriptStruct/UDelegateFunction/UActorComponent/ULevel/UASClass/FAngelscriptClassDesc/FAngelscriptModuleDesc)上提到 `AngelscriptEngine.h` 顶部已有 forward-decl 区块之后。删除原 `#include "Core/AngelscriptEngineHooks.h"`。

## 3. FAngelscriptEngine 类体增字段 + accessor

- [x] 3.1 <!-- Non-TDD --> 19 个 delegate 字段加入 `FAngelscriptEngine` 私有区(顺序与原 hooks struct 一对一,以保 git-blame 干净)。
- [x] 3.2 <!-- Non-TDD --> 19 对 `Get*()` accessor(mutable + const overload)加入 `FAngelscriptEngine` 公共区,实现都是 `return FieldName;`。
- [x] 3.3 <!-- Non-TDD --> 删除原 `Hooks` 字段与 `GetHooks()` 方法对。

## 4. 删除 hooks 文件

- [x] 4.1 <!-- Non-TDD --> 删除 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.h`。
- [x] 4.2 <!-- Non-TDD --> 删除 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.cpp`(本来就 1 行空实现)。
- [x] 4.3 <!-- Non-TDD --> grep `#include "Core/AngelscriptEngineHooks.h"` 全部移除。

## 5. 批量替换 133 调用点

- [x] 5.1 <!-- Non-TDD --> Runtime 36 处 / 10 文件:`Bind_AActor.cpp` / `Bind_BlueprintType.cpp` / `Bind_Console.h` / `Bind_FString.cpp` / `Bind_UActorComponent.cpp` / `Bind_UObject.cpp` / `AngelscriptDebugServer.cpp` / `AngelscriptPreprocessor.cpp` / `AngelscriptEngine.cpp` / `AngelscriptClassGenerator.cpp`。规则:`GetHooks().` → ``。
- [x] 5.2 <!-- Non-TDD --> Editor 16 处 / 7 文件。`ClassReloadHelper.h` 内 `FAngelscriptEngineHooks& Hooks = Engine.GetHooks();` 局部变量需消除,直接 `Engine.GetXxx()`。
- [x] 5.3 <!-- Non-TDD --> Test 81 处 / 11 文件(含新增 MultiEngineHooks 测试 + 5 个 ClassReloadHelper Tests + 4 个 HotReload Tests + Debugger / Compiler / Preprocessor 相关 hooks 测试)。同样消除任何 `FAngelscriptEngineHooks&` 局部引用。
- [x] 5.4 <!-- Non-TDD --> grep `GetHooks\(\)` 必须归零(plugin 源码内,archive 文档不算);grep `FAngelscriptEngineHooks` 必须归零(`FAngelscriptEngineHooksTests` 测试类名保留)。

## 6. spec 修订 + OpenSpec change

- [x] 6.1 <!-- Non-TDD --> `openspec/specs/as-engine-owned-hooks/spec.md` line 64 calling pattern 文案 `FAngelscriptEngine::Get().GetHooks().GetOnXxx()` → `FAngelscriptEngine::Get().GetOnXxx()`(MODIFIED delta)。
- [x] 6.2 <!-- Non-TDD --> 创建 OpenSpec change `refactor-as-engine-inline-hook-accessors` 包含 `proposal.md` / `tasks.md` / `specs/as-engine-owned-hooks/spec.md` MODIFIED delta。

## 7. 验证

- [x] 7.1 <!-- Non-TDD --> `Tools\RunBuild.ps1` 全 clean(增量构建,目标已就绪)。
- [x] 7.2 <!-- Non-TDD --> Smoke / RuntimeCpp / Bindings / HotReload 套件全绿(60 + 105 + 258 + 42 个测试)。
- [x] 7.3 <!-- Non-TDD --> Engine 前缀测试 97/97。

## 8. 提交 + 归档

- [ ] 8.1 <!-- Non-TDD --> 子模块 commit:`[Angelscript] Refactor: inline FAngelscriptEngineHooks fields onto FAngelscriptEngine`。
- [ ] 8.2 <!-- Non-TDD --> 父仓 commit:gitlink bump + spec amendment + change archive。
- [ ] 8.3 <!-- Non-TDD --> `openspec archive refactor-as-engine-inline-hook-accessors -y`。
