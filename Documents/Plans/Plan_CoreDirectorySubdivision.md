# Core 目录细分：将 GAS 等独立模块迁移至子目录

## 背景与目标

`Core/` 目录当前混放了 **59 个文件**，涵盖引擎核心、GAS（Gameplay Ability System）、Commandlet 等多个完全不同的关注点，导致目录职责模糊、文件查找成本高。

具体问题：

- **GAS 文件（11 个 .h + 7 个 .cpp = 18 个文件）** 全部依赖 `GameplayAbility`、`AbilitySystemComponent`、`AttributeSet` 等 GAS 插件头文件，与引擎核心文件（`AngelscriptEngine.h`、`AngelscriptBinds.h` 等）完全不同的依赖域，却混放在同一层级。
- **Commandlet 文件（2 对 .h/.cpp）** 是工具类入口，与运行时核心无关，也混在 `Core/` 中。
- `Core/` 本应只承载"引擎核心、绑定基础设施、运行时模块入口"，当前已严重膨胀。

目标：将 `Core/` 中职责明确的独立模块迁移至子目录，保持 `Core/` 聚焦于引擎核心。

## 影响范围

本次迁移涉及以下操作：

- **文件移动**：`Core/Foo.h` → `Core/<SubDir>/Foo.h`
- **include 更新**：`#include "Foo.h"` → `#include "<SubDir>/Foo.h"`（仅在 `Core/` 外部引用时需要；GAS 文件内部互相引用不受影响）

### 迁移目标子目录与文件清单

#### `Core/GAS/`（新建，18 个文件）

GAS 相关的所有脚本化基类、组件、工具库，全部依赖 GAS 插件头文件：

- `AngelscriptAbilityAsyncLibrary.h`
- `AngelscriptAbilitySystemComponent.cpp` / `.h`
- `AngelscriptAbilityTask.cpp` / `.h`
- `AngelscriptAbilityTaskLibrary.h`
- `AngelscriptAttributeSet.cpp` / `.h`
- `AngelscriptGameplayCueUtils.h`
- `AngelscriptGameplayEffectUtils.h`
- `AngelscriptGASAbility.cpp` / `.h`
- `AngelscriptGASActor.cpp` / `.h`
- `AngelscriptGASCharacter.cpp` / `.h`
- `AngelscriptGASPawn.cpp` / `.h`

#### `Core/Commandlets/`（新建，4 个文件）

工具类 Commandlet 入口，与运行时核心无关：

- `AngelscriptAllScriptRootsCommandlet.cpp` / `.h`
- `AngelscriptTestCommandlet.cpp` / `.h`

#### `Core/`（保留，37 个文件）

引擎核心、绑定基础设施、运行时模块入口，不移动：

`angelscript.cpp/.h`、`AngelscriptBindDatabase.*`、`AngelscriptBinds.*`、`AngelscriptBindString.h`、`AngelscriptComponent.*`、`AngelscriptDebugValue.h`、`AngelscriptDelegateWithPayload.h`、`AngelscriptDocs.*`、`AngelscriptEngine.*`、`AngelscriptGameInstanceSubsystem.*`、`AngelscriptInclude.h`、`AngelscriptRuntimeModule.*`、`AngelscriptSettings.h`、`AngelscriptSharedPtr.h`、`AngelscriptSkipBinds.cpp`、`AngelscriptSort.h`、`AngelscriptThirdPartyLib.cpp`、`AngelscriptType.*`、`AngelscriptAnyStructParameter.h`、`EndAngelscriptHeaders.h`、`FCpuProfilerTraceScoped.h`、`FunctionCallers.h`、`Helper_Reification.h`、`StartAngelscriptHeaders.h`、`UnversionedPropertySerialization.*`、`UnversionedPropertySerializationTest.*`

### include 引用扫描范围（已确认）

`Binds/` 中引用 GAS 头文件的文件：

- `Binds/Bind_AngelscriptGASLibrary.cpp`：`#include "AngelscriptAbilityAsyncLibrary.h"`

`AngelscriptEditor/Tests/` 中引用 GAS 头文件的文件（裸 include，通过 PublicIncludePaths 解析）：

- `Tests/AngelscriptBlueprintImpactScannerCoreTests.cpp`：`#include "AngelscriptAbilitySystemComponent.h"`
- `Tests/AngelscriptClassReloadHelperDelegateTests.cpp`：同上
- `Tests/AngelscriptClassReloadHelperTests.cpp`：同上

`AngelscriptTest/Core/` 中引用 GAS 头文件的文件（相对路径 `../../AngelscriptRuntime/Core/AngelscriptXxx.h`，共约 18 条）：

- `AngelscriptGASTestTypes.h`（5 条）
- `AngelscriptGASActorBaseTests.cpp`（3 条）
- `AngelscriptGASAbilityTests.cpp`、`AngelscriptGASAsyncLibraryTests.cpp`、`AngelscriptGameplayCueUtilsTests.cpp`、`AngelscriptGameplayEffectUtilsTests.cpp`（各 1 条）
- `AngelscriptAbilityTaskLibrary*Tests.cpp`（5 个文件，各 1 条）
- `AngelscriptGeneratedFunctionTableTests.cpp`、`AngelscriptHeaderShimTests.cpp`（各 1 条）

注：`Binds/Bind_FGameplayAbilitySpec.cpp`、`Bind_FGameplayAttribute.cpp`、`Bind_FGameplayEffectSpec.cpp` 仅引用 `AngelscriptBinds.h` / `AngelscriptEngine.h`，不受 GAS 迁移影响。

## 分阶段执行计划

### Phase 1：确认 include 引用全貌

- [ ] **P1.1** 全仓扫描被移动文件的 `#include` 引用，建立完整影响清单
  - 搜索 `AngelscriptGASAbility`、`AngelscriptGASActor`、`AngelscriptGASCharacter`、`AngelscriptGASPawn`、`AngelscriptAbilitySystemComponent`、`AngelscriptAbilityTask`、`AngelscriptAttributeSet`、`AngelscriptGameplayCueUtils`、`AngelscriptGameplayEffectUtils`、`AngelscriptAbilityAsyncLibrary`、`AngelscriptAbilityTaskLibrary` 在 `Source/` 下的所有 `#include` 命中
  - 搜索 `AngelscriptAllScriptRootsCommandlet`、`AngelscriptTestCommandlet` 在 `Source/` 下的所有 `#include` 命中
  - 确认 `AngelscriptRuntime.Build.cs` 中的 `PrivateIncludePaths` 是否需要追加 `Core/GAS` 和 `Core/Commandlets`（UBT 默认递归扫描子目录，通常不需要）
- [ ] **P1.1** 📦 Git 提交：无（纯调查阶段，不提交）

### Phase 2：移动 GAS 文件到 `Core/GAS/`

- [ ] **P2.1** 新建目录 `Core/GAS/`，移动 18 个 GAS 文件
  - 移动 `AngelscriptAbilityAsyncLibrary.h`
  - 移动 `AngelscriptAbilitySystemComponent.cpp` / `.h`
  - 移动 `AngelscriptAbilityTask.cpp` / `.h`
  - 移动 `AngelscriptAbilityTaskLibrary.h`
  - 移动 `AngelscriptAttributeSet.cpp` / `.h`
  - 移动 `AngelscriptGameplayCueUtils.h`
  - 移动 `AngelscriptGameplayEffectUtils.h`
  - 移动 `AngelscriptGASAbility.cpp` / `.h`
  - 移动 `AngelscriptGASActor.cpp` / `.h`
  - 移动 `AngelscriptGASCharacter.cpp` / `.h`
  - 移动 `AngelscriptGASPawn.cpp` / `.h`
  - GAS 文件内部互相引用（如 `AngelscriptGASActor.h` include `AngelscriptAbilitySystemComponent.h`）：同目录内引用路径不变，无需修改
- [ ] **P2.1** 📦 Git 提交：`[Runtime/Core] Refactor: move GAS files to Core/GAS/ subdirectory`

### Phase 3：更新 GAS 文件的外部 include 引用

- [ ] **P3.1** 更新所有外部模块引用 GAS 头文件的 `#include` 路径
  - `Binds/Bind_AngelscriptGASLibrary.cpp`：`"AngelscriptAbilityAsyncLibrary.h"` → `"GAS/AngelscriptAbilityAsyncLibrary.h"`
  - `AngelscriptEditor/Tests/` 3 个文件：`"AngelscriptAbilitySystemComponent.h"` → `"GAS/AngelscriptAbilitySystemComponent.h"`
  - `AngelscriptTest/Core/` 13 个文件：`../../AngelscriptRuntime/Core/AngelscriptXxx.h` → `../../AngelscriptRuntime/Core/GAS/AngelscriptXxx.h`
  - 更新 `AngelscriptRuntime.Build.cs` 追加 `Core/GAS` 到 PublicIncludePaths 和 PrivateIncludePaths
- [ ] **P3.1** 📦 Git 提交：`[Runtime/Binds] Fix: update include paths after Core/GAS/ migration`

### Phase 4：移动 Commandlet 文件到 `Core/Commandlets/`

- [ ] **P4.1** 新建目录 `Core/Commandlets/`，移动 4 个 Commandlet 文件
  - 移动 `AngelscriptAllScriptRootsCommandlet.cpp` / `.h`
  - 移动 `AngelscriptTestCommandlet.cpp` / `.h`
  - 按 P1.1 扫描结果更新外部 include 引用
- [ ] **P4.1** 📦 Git 提交：`[Runtime/Core] Refactor: move Commandlet files to Core/Commandlets/ subdirectory`

### Phase 5：构建验证与文档同步

- [ ] **P5.1** 执行完整构建，确认无编译错误
  - 运行 `RunBuild.ps1`，确认 0 错误
  - 如有 UHT 生成文件路径问题，清理 `Intermediate/` 后重新构建
- [ ] **P5.2** 更新 `AGENTS.md` 中 `Key Paths` 章节的 `Core/` 描述，补充 `Core/GAS/` 和 `Core/Commandlets/` 子目录说明；同步更新 `AGENTS_ZH.md`
- [ ] **P5.1 + P5.2** 📦 Git 提交：`[Docs] Update: document Core/GAS/ and Core/Commandlets/ subdirectory layout`

## 验收标准

1. `Core/GAS/` 目录存在，包含全部 18 个 GAS 文件
2. `Core/Commandlets/` 目录存在，包含全部 4 个 Commandlet 文件
3. `Core/` 根目录不再包含任何 GAS 或 Commandlet 文件
4. 构建通过（`RunBuild.ps1`）：无编译错误
5. 测试通过（`RunTests.ps1`）：无新增 FAIL
6. `AGENTS.md` 中 `Core/` 路径描述已更新，包含子目录说明

## 风险与注意事项

### 风险

1. **UBT include 路径扫描**：`AngelscriptRuntime.Build.cs` 使用**显式** `Path.Combine(ModuleDirectory, "Core")` 添加 include 路径，**不会**自动递归包含子目录。迁移后**必须**在 Build.cs 中追加 `Core/GAS` 和 `Core/Commandlets` 路径。
   - **缓解**：Phase 3 中与 include 更新同步处理

2. **IDE 索引刷新**：文件移动后 IDE（Rider/VS）可能需要重新生成项目文件（`GenerateProjectFiles.bat`）才能正确跳转。
   - **缓解**：构建验证后提示用户重新生成项目文件

### 已知行为变化

1. **GAS 文件内部互相引用路径不变**：`AngelscriptGASActor.h` include `AngelscriptAbilitySystemComponent.h` 等同目录引用，移动后仍在同一目录，路径无需修改。
2. **`Binds/` 中的 GAS Bind 文件 include 路径需更新**：`Bind_AngelscriptGASLibrary.cpp` 等文件的 include 从 `"AngelscriptXxx.h"` 改为 `"GAS/AngelscriptXxx.h"`，这是确定性的修改，Phase 3 必须处理。
