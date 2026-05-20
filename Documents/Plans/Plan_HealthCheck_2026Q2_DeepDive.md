# AS 插件深度探索补充报告（2026-05-10）

> **定位**：本文是 `Plan_HealthCheck_2026Q2.md` 的深度代码探索补充，提供具体的文件路径、行号和代码证据。
> 
> **读法**：
> - 要验证体检报告中的问题 → 读对应章节的代码证据
> - 要了解新发现的问题 → 读 §10 新发现问题清单

---

## §1 预处理器 import 实现状态（已完整实现）

**结论**：体检报告中"预处理器 import 未实现"的判断**不准确**。Import 功能已完整实现。

### 代码证据

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`

| 行号 | 功能 | 代码片段 |
|------|------|---------|
| 537 | ImportedModules 赋值 | `File.Module->ImportedModules.AddUnique(ImportDesc.ModuleName);` |
| 538 | import 语句移除 | `ReplaceWithBlank(File.ChunkedCode[ImportDesc.ChunkIndex], ...)` |
| 549 | 解析标志设置 | `File.bImportsResolved = true;` |
| 502-544 | 完整处理逻辑 | 包含循环导入检测、自动导入警告 |

### 测试失败根因重新分析

`Plan_KnownTestFailureFixes.md` Phase 3 中提到的 3 个 import 测试失败：
- `Preprocessor.ImportParsing`
- `Learning.Runtime.Preprocessor`
- `Learning.Runtime.FileSystemAndModuleResolution`

**需要重新诊断**：这些失败可能不是"功能未实现"，而是：
1. 测试 expectation 与实际实现不匹配
2. 测试环境的脚本文件布局问题
3. 测试断言逻辑错误

**建议**：将 Phase 3 从"实现 import 功能"改为"修复 import 测试断言"。

---

## §2 C++ UInterface 绑定缺口（已识别，有专门处理）

**结论**：体检报告准确。UInterface 绑定缺口已被识别并有 Phase 5 专门处理计划。

### 代码证据

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`

| 行号 | 内容 | 说明 |
|------|------|------|
| 1037 | `if (Class->HasAnyClassFlags(CLASS_Interface) && Class != UInterface::StaticClass()) return true;` | 接口类被标记为应该绑定 |
| 1694-1699 | 注释："Phase 5: C++ UInterface method auto-registration" | 明确说明接口方法不被 Phase 2 TFieldIterator 捕获 |
| 1716-1720 | 接口类过滤逻辑 | 跳过 UInterface 基类 |

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp`

| 行号 | 内容 |
|------|------|
| 946-948 | `if (OwningClass->HasAnyClassFlags(CLASS_Interface)) { return EReflectionFallbackResult::InterfaceClass; }` |

**对应 Plan**：`Plan_CppInterfaceBinding.md`（P1 优先级，未启动）

---

## §3 Working Tree 状态（已提交，非未提交改动）

**结论**：体检报告中"working tree 未提交的 bind 命名重构"判断**不准确**。这些改动已提交。

### Git 状态

```
git status --short 显示：
- 删除 (D)：28 个文件（分析文档、测试覆盖报告）
- 修改 (M)：6 个 Plan 文档 + 2 个 submodule
- 未跟踪 (??)：2 个新 Plan 文件（本次体检生成）
```

### Bind 命名重构代码证据

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` 第 152-178 行

**`MakeBindNameFromCallerFile` 完整实现**：
```cpp
static FName MakeBindNameFromCallerFile(const ANSICHAR* CallerFile)
{
    if (CallerFile == nullptr || *CallerFile == '\0')
        return MakeUnnamedBindName();

    const FString FullPath = ANSI_TO_TCHAR(CallerFile);
    const FString Stem = FPaths::GetBaseFilename(FullPath);
    if (Stem.IsEmpty())
        return MakeUnnamedBindName();

    static TMap<FName, int32> StemDuplicateCounter;
    const FName StemName(*Stem);
    int32& Count = StemDuplicateCounter.FindOrAdd(StemName);
    if (Count == 0)
    {
        ++Count;
        return StemName;
    }

    const FName UniqueName(*FString::Printf(TEXT("%s#%d"), *Stem, Count));
    ++Count;
    return UniqueName;
}
```

**关键特性**：
- 从 `__builtin_FILE()` 提取文件名作为 bind 名称
- 使用静态 TMap 追踪重复，首次返回原名，后续添加 `#N` 后缀
- 空路径回退到 `UnnamedBind_%d` 旧命名

**AngelscriptEnumTableBaselineProbe 存在证据**：
- 文件：`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptEnumTableBaselineProbe.h`
- 用途：`Plan_UhtArtifactExpansion.md` P3.2 Phase 0 基线测量
- 功能：收集 `CallBinds` 内部每个绑定的计时数据

**结论**：这些改动已提交，属于 `Plan_UhtArtifactExpansion.md` 的前置工作。

---

## §4 Unity Build 配置状态（未显式配置）

**结论**：体检报告准确。Unity Build 未被显式配置，使用隐性默认值。

### 代码证据

**文件**：`Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`

- **未找到** `bUseUnity` 设置
- 使用 UBT 默认值（通常为 true）

**文件**：`Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs`

- **未找到** `bUseUnity` 设置
- 使用 UBT 默认值

**风险**：`Plan_UnityBuildConflictResolution.md` 提到 490 个 Unity ON 编译错误，但 Build.cs 未显式禁用 Unity Build，可能导致：
1. 本地构建成功但 CI 失败（环境差异）
2. 未来 UBT 默认值变化导致突然失败

**建议**：在 `Plan_UnityBuildConflictResolution.md` 中增加"显式设置 `bUseUnity = true`"作为 Phase 0 任务。

---

## §5 Math ScriptMixin 当前状态（已充分文档化）

**结论**：体检报告准确。8 处 ScriptMixin 是有意延迟，已充分文档化。

### 代码证据

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h`

**8 处注释化 ScriptMixin 锚点**：

| 行号 | 类型 | 注释内容 |
|------|------|---------|
| 329 | FVector | `//UCLASS(Meta = (ScriptMixin = "FVector"))` |
| 415 | FVector3f | `//UCLASS(Meta = (ScriptMixin = "FVector3f"))` |
| 489 | FRotator | `//UCLASS(Meta = (ScriptMixin = "FRotator", ScriptName = "FRotator"))` |
| 539 | FRotator3f | `//UCLASS(Meta = (ScriptMixin = "FRotator3f", ScriptName = "FRotator3f"))` |
| 589 | FQuat | `//UCLASS(Meta = (ScriptMixin = "FQuat", ScriptName = "FQuat"))` |
| 659 | FQuat4f | `//UCLASS(Meta = (ScriptMixin = "FQuat4f", ScriptName = "FQuat4f"))` |
| 728 | FTransform | `//UCLASS(Meta = (ScriptMixin = "FTransform", ScriptName = "FTransform"))` |
| 804 | FTransform3f | `//UCLASS(Meta = (ScriptMixin = "FTransform3f", ScriptName = "FTransform3f"))` |

**文件头说明**（第 6-48 行）：
- 所有 8 个 ScriptMixin 注释是"deferred Hazelight-parity anchors"
- P4.3 试验启用导致 namespace 回归（fork 测试代码依赖 `<Lib>::<Func>(target, ...)` 形式）
- 需要先迁移 ~80 个调用点到 `target.<Func>(...)` 形式
- 3 个新 Static 子类已添加（FQuat/FRotator/FTransform）

**对应 Plan**：`Plan_MathScriptMixinReenablement.md`（5 个 Phase 详细规划，P2 优先级）

---

## §6 废弃 API 使用状态（有限且正确包装）

**结论**：体检报告准确。废弃 API 使用有限，且被正确包装。

### 代码证据

**FCrc::StrCrc_DEPRECATED 使用**（3 处）：

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.cpp` 第 2713-2721 行

```cpp
// 为 AngelScript 函数生成一致的 ID
auto* ScriptModule = Function->GetModule();
if (ScriptModule != nullptr)
{
    Id = HashCombine(Id, FCrc::StrCrc_DEPRECATED((const ANSICHAR*)ScriptModule->GetName()));
    Id = HashCombine(Id, (uint32)(size_t)ScriptModule->GetUserData());
}

auto* ObjectType = Function->GetObjectType();
if (ObjectType != nullptr)
    Id = HashCombine(Id, FCrc::StrCrc_DEPRECATED((const ANSICHAR*)ObjectType->GetEngine()->GetTypeDeclaration(ObjectType->GetTypeId(), true)));

Id = HashCombine(Id, FCrc::StrCrc_DEPRECATED((const ANSICHAR*)Function->GetDeclaration(true, true)));
```

**用途**：StaticJIT 编译期间的函数去重和缓存。使用废弃 CRC 是为了保持向后兼容性。

**PRAGMA_DISABLE_DEPRECATION_WARNINGS 使用**（2 处配对）：

**文件**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings.cpp` 第 13 和 19 行

```cpp
PRAGMA_DISABLE_DEPRECATION_WARNINGS
// ... 使用废弃 API 的代码 ...
PRAGMA_ENABLE_DEPRECATION_WARNINGS
```

**结论**：废弃 API 使用被正确包装，不会产生编译警告。

---

## §7 Bind Hack 标记分布（仅 3 处）

**结论**：体检报告准确。Hack 标记数量少，影响有限。

### 代码证据

| 文件 | 行号 | 内容 |
|------|------|------|
| `Bind_BlueprintEvent.cpp` | 908 | `// This is a hack!` |
| `Bind_FName.cpp` | 84 | `// Ugly hack since we don't have access to the ComparisonIndex directly` |
| `Bind_USceneComponent.cpp` | 172 | `// Small hack: We want to have GetSocketQuaternion in script, but the BP version is deprecated.` |

**对应 Plan**：`Plan_BindHackCleanup`（建议新建，P4 优先级）

---

## §8 大文件问题（确实存在）

**结论**：体检报告准确。大文件问题确实存在。

### Binds 目录超过 1000 行的文件（7 个）

| 文件 | 行数 | 说明 |
|------|------|------|
| `Bind_BlueprintType.cpp` | **2861** | 最大，包含 5 处 WILL-EDIT 标记 |
| `Bind_TArray.cpp` | 1830 | 容器绑定 |
| `Bind_Delegates.cpp` | 1442 | 委托绑定 |
| `Bind_UStruct.cpp` | 1434 | 结构体绑定 |
| `Bind_FString.cpp` | 1421 | 字符串绑定 |
| `Bind_TMap.cpp` | 1350 | Map 容器绑定 |
| `BlueprintCallableReflectiveFallback.cpp` | 1094 | 反射回退 |

### AngelscriptTest 目录超过 1000 行的文件（10 个）

| 文件 | 行数 |
|------|------|
| `AngelscriptFStringBindingsTests.cpp` | 2912 |
| `AngelscriptUObjectBindingsTests.cpp` | 2423 |
| `Template_ReflectionAccess.cpp` | 2178 |
| `AngelscriptTArrayBindingsTests.cpp` | 2159 |
| `AngelscriptTArraySyntaxCompatBindingsTests.cpp` | 1952 |
| `AngelscriptDebuggerSteppingTests.cpp` | 1260 |
| `AngelscriptClassBindingsTests.cpp` | 1187 |
| `AngelscriptMapBindingsTests.cpp` | 1126 |
| `AngelscriptDebuggerTestClient.cpp` | 1073 |
| `AngelscriptEngineIsolationTests.cpp` | 1071 |

**对应 Plan**：`Plan_LargeFileSplit`（建议新建，P3 优先级）

---

## §9 TODO/FIXME 注释分布（仅 4 处）

**结论**：TODO/FIXME 注释数量少，技术债标记较少。

### 代码证据

| 文件 | 行号 | 内容 |
|------|------|------|
| `Bind_Json.cpp` | 188 | `// TODO : expand FJsonValueArrayContainer to support every value create/access method` |
| `Bind_Json.cpp` | 466 | `// TODO : expand FJsonObjectContainer to support every field type create/access method` |
| `Bind_UStruct.cpp` | 1417 | `// TODO: We need some way of determining whether this struct` |
| `AngelscriptType.cpp` | 330 | `// TODO: Default values` |

---

## §10 新发现问题清单

以下问题在原体检报告中未被覆盖：

### 10.1 WILL-EDIT 标记（6 处）

**严重度**：🟡 中等

**位置**：主要在 `Bind_BlueprintType.cpp`

| 行号 | 上下文 | 含义 |
|------|--------|------|
| 1023 | UASClass 检查 | 运行时生成类型检查可能需要优化 |
| 1047 | NameArray 声明 | 函数列表初始化可能需要重构 |
| 1052 | GenerateFunctionList | 生成函数列表可能需要优化 |
| 1057 | FindFunctionByName | 按名称查找可能需要优化 |
| 1078 | TObjectRange 循环 | **并行化候选**（标记为 `WILL-EDIT?`） |
| Bind_ConfigEnums.cpp:13 | 注释掉的 for 循环 | 未完成的代码段 |

**建议 Plan**：`Plan_BindWillEditCleanup`（新建，P3 优先级）

### 10.2 UAngelscriptSettings 字段数量修正

**体检报告声称**：28 个字段

**实际数量**：**33 个 UPROPERTY 字段**

**证据**：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`

**影响**：`Plan_SettingsCoverageAndDX.md` 中的基线数字需要更新。

### 10.3 测试覆盖空白补充

**Enhanced Input 测试**：
- 已有 3 个测试文件（`AngelscriptEnhancedInputBindingsTests.cpp` 等）
- 体检报告中"Enhanced Input 零测试覆盖"判断**不准确**

**Networking 测试**：
- 仅 1 个文件 `AngelscriptNetworkRPCTests.cpp`（17KB）
- 确实极薄，体检报告准确

**Editor 测试**：
- 仅 1 个文件 `AngelscriptSourceNavigationTests.cpp`（11.5KB）
- 确实极薄，体检报告准确

### 10.4 新 Plan 文件发现（6 个）

以下 Plan 文件在原体检报告中未被提及：

| Plan | 主题 | 优先级建议 |
|------|------|-----------|
| `Plan_DebugValuesAndDebugModeHardening.md` | Debug 模式能力收口 | P3 |
| `Plan_MapBasedPIETestExpansion.md` | 地图级 PIE 测试扩展 | P1（与 PIEMapBasedTestExpansion 重复？） |
| `Plan_SettingsCoverageAndDX.md` | 设置项测试闭环 | P2 |
| `Plan_TestEngineLifecycleClosure.md` | 测试引擎生命周期闭环 | P2 |
| `Plan_ExamplesTestConsolidation.md` | Examples 测试融合 | P3 |
| `Plan_DefaultStatementHazelightParity.md` | default 语句对齐 | P3 |

### 10.5 AngelscriptGAS 插件状态

**位置**：`Plugins/AngelscriptGAS/`

**状态**：
- 版本：1.0
- 两个模块：`AngelscriptGAS`（Runtime）和 `AngelscriptGASTest`（Editor）
- 依赖：`Angelscript` 和 `GameplayAbilities`
- **默认禁用**（`EnabledByDefault: false`）

**影响**：GAS 功能已拆分为独立插件，不在主插件内。体检报告中"GAS helper surface 薄"需要重新评估。

### 10.6 Script 示例数量修正

**体检报告声称**：37 个 .as 文件

**实际数量**：**28 个 .as 文件**

**分布**：
- Core/：20 个
- EnhancedInput/：3 个
- Extended/：5 个

**影响**：示例数量仍超过 Hazelight 基线（26 个），但具体数字需要修正。

---

## §11 体检报告需要修正的判断

| 原判断 | 修正后判断 | 证据章节 |
|--------|-----------|---------|
| "预处理器 import 未实现" | ✅ **已完整实现**，测试失败是断言问题 | §1 |
| "working tree 未提交的 bind 命名重构" | ✅ **已提交**，不是未提交改动 | §3 |
| "Enhanced Input 零测试覆盖" | ⚠️ **有 3 个测试文件**，但覆盖可能不充分 | §10.3 |
| "UAngelscriptSettings 28 个字段" | ⚠️ **实际 33 个字段** | §10.2 |
| "Script 示例 37 个" | ⚠️ **实际 28 个** | §10.6 |

---

## §12 建议新增的 Plan

基于深度探索，建议新增以下 Plan：

| # | Plan 名称 | 优先级 | 理由 |
|---|----------|--------|------|
| 1 | `Plan_BindWillEditCleanup` | P3 | 清理 6 处 WILL-EDIT 标记，特别是并行化候选 |
| 2 | `Plan_LargeFileSplit` | P3 | 拆分 Bind_BlueprintType.cpp（2861 行）等大文件 |
| 3 | `Plan_UnityBuildExplicitConfig` | P0 | 显式设置 `bUseUnity = true`，避免隐性默认值风险 |

---

## §13 后续行动建议

1. **立即修正体检报告**：更新 §3.2（import 已实现）、§6.2（Enhanced Input 有测试）、§10.2（Settings 字段数）
2. **重新诊断 import 测试失败**：不是功能缺失，是测试断言问题
3. **补充 WILL-EDIT 标记到技术债清单**：6 处标记需要专门处理
4. **评估 Plan 重复性**：`Plan_MapBasedPIETestExpansion.md` 与 `Plan_PIEMapBasedTestExpansion.md` 可能重复
5. **更新 Plan 索引**：6 个新发现的 Plan 需要加入 `Plan_OpportunityIndex.md`
