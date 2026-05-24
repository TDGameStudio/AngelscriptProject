# Note_ScreenshotTestHelper — 截图测试 Helper

> **所属前缀**: Note_（零散笔记族）
> **关注层面**: 站在"截图回归"视角盘点本仓库当前状态——本插件**没有**自己的截图 Helper，仓库里也**没有**任何 spec 调用 UE Automation Screenshot API；本笔记说明这一空缺的来由、与 `Test_Infrastructure.md §七.1` 的对应、UE 自带截图框架的接入约定，以及如果将来真的要落地，应该把代码放在哪里、走什么路径；不重述 `Note_CQTest.md` 的框架原理，不重写 `Test_Layering.md` 的模块边界
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths.cpp` (~30 行 `FPaths::ScreenShotDir` 绑定，整个仓库唯一与"screenshot"字面相关的代码)
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/` (40+ Helper 头文件，**无** `AngelscriptScreenshot*` 匹配)
> · `Plugins/Angelscript/Source/AngelscriptTest/Functional/Widget/AngelscriptWidgetBindWidgetTests.cpp` (~80 行，目前唯一的 UMG 测试，不截图)
> · `Plugins/Angelscript/Source/AngelscriptTest/Functional/Rendering/AngelscriptRenderingDynamicMaterialTests.cpp` (~80 行，目前唯一的渲染测试，不截图)
> · `Engine/Source/Runtime/Engine/Public/Tests/AutomationCommon.h` (UE 侧 `FAutomationScreenshotData` / `FAutomationScreenshotConfig` 定义所在)
> · `Engine/Source/Developer/FunctionalTesting/Public/AutomationScreenshotOptions.h`
> **关联文档**:
> `Documents/Knowledges/ZH/Test_Infrastructure.md` §七.1 — 截图与 CodeCoverage Helper 协同（本笔记把那一节里"待写"的内容补全）
> · `Documents/Knowledges/ZH/Test_Layering.md` §二 — Build.cs 边界（说明为什么 Editor 截图 API 不能进 Helper 公共头）
> · `Documents/Knowledges/ZH/Test_TopicClusters.md` §二.4 — UI / Rendering 簇（截图未来落点的两个候选目录）
> · `Documents/Knowledges/ZH/Note_CQTest.md` §三 — CQTest 生命周期（截图需要的 Latent Action 接入点）
> · `Documents/Plans/Plan_PIEMapBasedTestExpansion.md` §E.3 — `Observability.ScreenshotComparison_Frame60` 计划用例
> **外部参考**:
> [UE Automation Screenshot 文档](https://dev.epicgames.com/documentation/zh-cn/unreal-engine/automation-system-overview)
> · `Engine/Source/Runtime/AutomationTest/` — UE 自带 Automation 框架

---

## 概览

本文聚焦一个核心问题：**`Plugins/Angelscript` 里有没有截图测试 Helper？如果有，它放在哪里、怎么用、与 UE 自带 Automation Screenshot 框架的关系是什么？如果没有，未来想加该怎么落地？**

答案先交底——**整个仓库当前没有任何截图测试 Helper**，也没有任何 spec 调用过 UE 的 `FAutomationScreenshotConfig` / `TakeHighResScreenshot` / `FScreenshotComparisonRequest`。

具体证据（2026-05 baseline）：

- `Glob "Plugins/Angelscript/Source/AngelscriptTest/**/*Screenshot*"` → **零命中**。
- `Glob "Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptScreenshot*"` → **零命中**（这是 `AGENTS.md` 里隐式的命名约定，即使它存在也应在此路径）。
- `grep "FAutomationScreenshotData|TakeScreenshot|FScreenshotComparisonRequest|FAutomationScreenshotConfig"` 在整个 `Plugins/` 下 → **零命中**。
- 与 "screenshot" 字面相关的代码只有一处：`Bind_FPaths.cpp` 第 30 行 `FPaths::ScreenShotDir` 暴露给 AS 脚本，是路径查询绑定，与截图断言无关。

```text
================================================================================
   "AngelScript 截图测试 Helper" 现状（2026-05）：一张全空表
================================================================================

  期望落点                                         实际状态
  ─────────────────────────────                 ────────────────────────

  Shared/AngelscriptScreenshot*.h              ✗ 不存在
  Shared/AngelscriptScreenshot*.cpp            ✗ 不存在
  Functional/Widget/*Screenshot*.cpp           ✗ 不存在
  Functional/Rendering/*Screenshot*.cpp        ✗ 不存在
  Editor/Tests/*Screenshot*.cpp                ✗ 不存在
  AS 脚本里调用 TakeScreenshot                 ✗ 0 处
  CI lane 跑截图比对                           ✗ 无

  最接近的代码                                 实际作用
  ─────────────────────────────                 ────────────────────────
  Bind_FPaths.cpp:30 ScreenShotDir()           只暴露路径查询
                                                给 AS 脚本

  规划路径                                     状态
  ─────────────────────────────                 ────────────────────────
  Plan_PIEMapBasedTestExpansion §E.3.O4        计划用例（W20 周期），
  ScreenshotComparison_Frame60                  代码未落地
  Test_Screenshot.md (Documents/Guides/)       0 字节空文件
                                                Plan_HealthCheck_2026Q2
                                                误标 "✅ 有内容"

================================================================================
```

为什么仍然要写这篇笔记？三层理由：

1. `Test_Infrastructure.md §七.1` 把这个空缺记下来，并把"详见 `Note_ScreenshotTestHelper.md`（待写）"作为占位。本笔记完成这一占位。
2. `Index.md` 已经在 `Note_` 块里登记了 `Note_ScreenshotTestHelper.md`——索引里有入口、文件不存在会让读者迷路。
3. 未来若 `Plan_PIEMapBasedTestExpansion.md §E.3.O4` 真的开始施工，本笔记充当"落地前的设计约束清单"——它把 UE 自带框架的接入点、Build.cs 边界、Headless / NullRHI 限制、baseline 存储约定一次性写清楚。

后续按 **(一) 现状清单 → (二) UE Automation Screenshot 框架速览 → (三) Test_Infrastructure §七.1 的对应 → (四) Build.cs 与模块边界对截图代码的约束 → (五) 真要落地时该放在哪里 → (六) 当前限制与已知风险 → (七) 与现有 Test 测试的关系** 的顺序展开，最后用两份附录 + 小结收口。

---

## 一、现状清单：仓库里 "screenshot" 一共出现在哪

完整 grep 结果（不区分大小写）：

| 位置 | 内容 | 与截图测试的关系 |
|------|------|-----------------|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths.cpp:30` | `FAngelscriptBinds::BindGlobalFunction("FString ScreenShotDir()", &FPaths::ScreenShotDir);` | **无关**——只把 UE 的 ScreenShotDir 路径查询暴露给 AS 脚本，AS 端可读"截图目录"位置但没有截图 API |
| `Documents/Knowledges/ZH/Test_Infrastructure.md:500-504` | `当前 Shared/ 没有专门的截图 Helper / Note_ScreenshotTestHelper.md（待写）会落 UE 自带 FAutomationScreenshotConfig / Take(High|Editor)Screenshot 的接入约定` | 文档占位——本笔记的来源 |
| `Documents/Knowledges/ZH/Index.md:151` | `├── Note_ScreenshotTestHelper.md           // 截图测试 Helper` | 索引登记（占位条目） |
| `Documents/Plans/Plan_PIEMapBasedTestExpansion.md:1059` | `E.3.O4 MapTests.Observability.ScreenshotComparison_Frame60 — 启动 60 帧后截图与 baseline 对比（容差 ≤ 1%）` | 计划用例，未落地 |
| `Documents/Plans/Plan_PIEMapBasedTestExpansion.md:1517,1584` | `在 PR 描述中贴 PIE 启动截图（首屏）` / `PIE 截图（如适用）已附在 PR description` | PR 流程约定，与自动化截图无关 |
| `Documents/Plans/Plan_PIEMapBasedTestExpansion.md:1809` | `W20: TemporalLog / Insights / Screenshot 全集成` | 计划周期，未到 |
| `Documents/Plans/Plan_HealthCheck_2026Q2.md:635` | `Test_Screenshot.md 测试截图指南 ✅ 有内容` | **错误标注**——同名文件实际为 0 字节空文件（见 §一.2） |

### 1.1 唯一的 AS 端入口：`FPaths::ScreenShotDir()`

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FPaths.cpp
// 函数: 在 FAngelscriptBinds 内绑定 FPaths::ScreenShotDir 给 AS
// ============================================================================
FAngelscriptBinds::BindGlobalFunction("FString ScreenShotDir()", &FPaths::ScreenShotDir);
FAngelscriptBinds::BindGlobalFunction("FString VideoCaptureDir()", &FPaths::VideoCaptureDir);
```

这条绑定让 AS 脚本能用 `FPaths::ScreenShotDir()` 读到 UE 的"高分截图输出目录"（默认 `Saved/Screenshots/<Platform>/`）。它**不**触发截图，也**不**带 baseline 比对，是纯路径查询。

> **如果你在 spec 里搜到 `ScreenShotDir`**，那只是某段日志在拼路径串——把"我把截图存哪了"打到 Automation log；与"截图驱动断言"完全是两回事。

### 1.2 `Documents/Guides/Test_Screenshot.md` 的状态

`Plan_HealthCheck_2026Q2.md §17` 的"已有 Guides 清单"里把 `Test_Screenshot.md` 标为"✅ 有内容"——这条标注是**错的**：

```text
$ ls -la Documents/Guides/Test_Screenshot.md
0 bytes  (空文件)
```

文件物理存在，但是 **0 字节空文件**。这意味着：

- 不要在引用 Knowledges / Guides 时把它当真实存在的指南——它没有任何内容。
- 当 Plan_HealthCheck 之后被审计或重写时，应把这一条改为 "❌ 空文件 / 待写"，与本笔记保持口径一致。

---

## 二、UE Automation Screenshot 框架速览

由于本仓库**没有自封装层**，未来谁要加截图测试都得**直接用 UE 自带框架**。把 UE 那套的关键 API 列在这里供查：

### 2.1 三套并存的 UE 截图 API

| API 类别 | 头文件 | 触发方式 | 适用场景 |
|---------|-------|---------|---------|
| `FAutomationScreenshotData` + `FAutomationScreenshotConfig` | `Engine/Source/Runtime/AutomationTest/Public/AutomationScreenshot.h` | 配 metadata（图名、tolerance、视口大小） | 标准 Automation 测试 |
| `FFunctionalTestExternalScreenshotComparison` | `Engine/Source/Developer/FunctionalTesting/Public/` | `FunctionalTest` Actor 在关卡里直接拍 | PIE / FunctionalTest 风格 |
| `TakeHighResScreenshot` 控制台命令 | `HighResScreenshot.cpp` | `GEngine->Exec("HighResShot 1920x1080")` | 手工调试 / 无 Automation 上下文 |

`FAutomationScreenshotConfig` 是 Automation 测试族最常见的封装：

```cpp
// 节选自: Engine/Source/Runtime/AutomationTest/Public/AutomationScreenshot.h
//        (字段说明，不是实际抄录)
struct FAutomationScreenshotConfig
{
    FString    ScreenshotName;        // baseline 文件名，如 "MyMap_Frame60"
    FString    Notes;                 // 失败时附加描述
    int32      ResolutionX;
    int32      ResolutionY;
    float      ToleranceAmount;       // 像素差异容差 [0..1]，默认 0.02
    bool       bIgnoreAntiAliasing;
    bool       bIgnoreColors;
    EComparisonTolerance Tolerance;   // Low / Medium / High / Custom
    // ... 其他抗锯齿 / 滤镜旗子
};
```

调用入口典型用 `FFunctionalTestBase` 提供的 latent command（`SetEditorViewportVisualizeBuffer` / `TakeAutomationScreenshot`），或直接 `ADD_LATENT_AUTOMATION_COMMAND(FTakeScreenshotAfterTimeLatentCommand(...))`。

### 2.2 baseline 图片的存放约定

UE 默认 baseline 路径是：

```text
<ProjectRoot>/Test/Screenshots/<Platform>/<RHI>/<ScreenshotName>.png
```

实际比对时 UE 会按**优先级链**查找：

1. 先看 `Test/Screenshots/<Platform>/<RHI>/<Name>.png`（最具体）。
2. 找不到回退 `Test/Screenshots/<Platform>/<Name>.png`。
3. 再回退 `Test/Screenshots/<Name>.png`（最通用）。
4. 全找不到则记 baseline 缺失（首次跑测试时是预期行为，会把当前帧作为 baseline 写入 incoming 目录）。

新比对结果写到 `Saved/Automation/<TestName>/<ScreenshotName>.png`。CI 失败时关注 `Saved/Automation/Incoming/` 与 baseline 的差异图。

### 2.3 失败比对的报告路径

`FFunctionalTest` / `Automation` 框架在 baseline 不匹配时：

- 把 incoming 图、baseline 图、diff 图写到 `Saved/Automation/<TestName>/`。
- 在 Automation log 里 `AddError` 一条 `Screenshot comparison failed: <name> (similarity=X%)`。
- HTML 报告（`-AutomationReports`）会内嵌三张缩略图便于审查。

注意：UE 的截图比对**默认在 Editor / Game 进程完成**，比较开销不小（高分辨率 ≥ 数百 ms）；NullRHI / `-nullrhi` 下整个截图链路返回**全黑帧**或**直接被跳过**（取决于版本）。

---

## 三、与 Test_Infrastructure §七.1 的对应

`Test_Infrastructure.md §七.1` 写：

> 当前 `Shared/` **没有专门的截图 Helper**——`Note_ScreenshotTestHelper.md`（待写）会落 UE 自带 `FAutomationScreenshotConfig` / `Take(High|Editor)Screenshot` 的接入约定。本文只点出协同点：
>
> - AngelscriptTest **不在 Helper 头文件里依赖任何 Editor 截图 API**，因为 `AngelscriptEditor` 是 private + bBuildEditor 守卫依赖（`Test_Layering.md` §二.4）。
> - 真实截图回归落在 Editor 模块自己的 `AngelscriptEditor/Tests/` 下，对应 `Angelscript.Editor.*` 前缀，和 Shared/ 没有交叉。
> - 之后如果需要 Test 模块自己产出截图（例如 Widget 主题），将通过 `Functional/Widget/` 直接调 `FAutomationScreenshotConfig`，不需要新增 Shared/ Helper——保持 Helper 层"轻头"原则。

把这三条原则展开成本笔记的核心约束：

1. **Helper "轻头"原则**：任何对 `FAutomationScreenshotConfig` / `FunctionalTesting` / `Slate` 截图 API 的依赖，**不得**进 `Shared/*.h`。一旦进了公共头，所有引用 `Shared/` 的 spec 都要带这些依赖编译，违反 `Test_Layering.md §二.4` 的依赖最小化。
2. **Editor 与 Test 模块分工**：
   - 全屏 / Slate Widget / Editor viewport 截图 → 应该落在 `AngelscriptEditor/Tests/`，前缀 `Angelscript.Editor.<X>`。
   - PIE 内 GameViewport 截图（Map 加载后采图）→ 可以在 `AngelscriptTest/Functional/<Theme>/`，但**只在该 .cpp 内部** include UE 截图头文件。
3. **没有 Helper 化的诱因**：截图比对 case 数量预期很少（参考 Plan_PIEMapBasedTestExpansion，整个 §E.3 也只列 1 条）。"为 1 条 case 抽 helper"违反 `Test_Infrastructure.md` 附录 C.11 的 **cross-theme 才进 Shared/** 原则。

> 一句话：本仓库刻意**不**封装 UE 截图 API；如果将来 case 多到 ≥ 3 个不同主题都需要，再考虑抽到 `Shared/`，目前"直接调 UE 原生"是更经济的选择。

---

## 四、Build.cs 与模块边界对截图代码的约束

`Test_Layering.md §二` + `Note_UBT.md §三` 给出了 `AngelscriptTest.Build.cs` 的依赖白名单。要加截图代码，得先核对 Build.cs 是否带这些模块：

| UE 模块 | 用途 | 当前 `AngelscriptTest.Build.cs` 是否引入 |
|---------|------|----------------------------------------|
| `AutomationTest` | `FAutomationScreenshotConfig` 基础类型 | ✓（自动随 `EngineFilter` flags） |
| `FunctionalTesting` | `FFunctionalTestBase` / `TakeAutomationScreenshot` latent command | ✗（**未引入**） |
| `RenderCore` | `RHI` 截图回读 | ✓（间接通过 `Engine`） |
| `Slate` / `SlateCore` | Widget 截图 | ✗（**未引入**，Editor only） |
| `UnrealEd` | Editor viewport 截图 / `bBuildEditor` 守卫 | 仅在 `bBuildEditor` 时由 `AngelscriptEditor` 提供 |
| `MovieSceneCapture` / `ImageWriteQueue` | 写 PNG 文件 | ✗（**未引入**） |

也就是说**目前 `AngelscriptTest.Build.cs` 不带 `FunctionalTesting`**——任何 `FFunctionalTestBase` 派生 / `TakeAutomationScreenshot` 调用都会编译失败。要加截图测试，第一步是在 Build.cs 里加：

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
// 角色: 假想的"加截图能力"补丁——目前不存在
// ============================================================================
PrivateDependencyModuleNames.AddRange(new string[] {
    "FunctionalTesting",          // 拿到 FFunctionalTest / TakeAutomationScreenshot
    "MovieSceneCapture",          // 写 PNG 与 PiplineCapture
    "ImageWriteQueue",            // 异步 PNG 写盘
});
```

但是动 Build.cs 之前要回答：**这个能力放进哪个 Build target？** Editor only 还是 Runtime + Editor？答案见 §五。

---

## 五、真要落地时该放在哪里

如果 `Plan_PIEMapBasedTestExpansion §E.3.O4` 真的开始施工，理想落点拓扑：

```text
┌─────────────────────────────────────────────────────────────────┐
│  AngelscriptTest 模块（bBuildEditor 任意）                       │
│   ▼                                                            │
│   Functional/<Theme>/AngelscriptXxxScreenshotTests.cpp         │
│      用 ASTEST_CREATE_ENGINE_FULL 起隔离 Full engine            │
│      在 spec .cpp 内部 include "AutomationScreenshot.h"        │
│      不在 Shared/ 公共头里 include 任何截图 API                  │
│      失败时 baseline diff 写 Saved/Automation/                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  AngelscriptEditor 模块（bBuildEditor 守卫）                     │
│   ▼                                                            │
│   Tests/AngelscriptEditorWidgetScreenshotTests.cpp             │
│      用 Editor viewport / Slate widget snapshot                 │
│      前缀 Angelscript.Editor.Widget.<X>                         │
│      仅 Editor build 启用                                        │
└─────────────────────────────────────────────────────────────────┘
```

### 5.1 命名约定建议

为了与现有体系对齐：

- spec class：`F<Theme>ScreenshotTests`，例如 `FFunctionalRenderingScreenshotTests`。
- Automation 路径：`Angelscript.TestModule.Functional.<Theme>.Screenshot.<Case>`。
- baseline 文件名：`AS_<Theme>_<Case>.png`（前缀 `AS_` 避免与游戏自身的截图同名）。
- baseline 目录：`Test/Screenshots/Windows/D3D12/AS_<Theme>_<Case>.png`，多平台再扇出。

### 5.2 一份"真要写"的最小骨架

以下是**假想代码**，仓库当前**不存在**——只作为未来模板：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Functional/Rendering/AngelscriptScreenshotTests.cpp
// 角色: 假想的最小截图测试骨架（当前未落地）
// ============================================================================
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptTestWorld.h"
#include "AutomationScreenshot.h"             // ← 仅在 .cpp 内部 include
#include "Tests/AutomationCommon.h"
#include "CQTest.h"

#if WITH_DEV_AUTOMATION_TESTS

TEST_CLASS_WITH_FLAGS(FAngelscriptScreenshotTests,
    "Angelscript.TestModule.Functional.Rendering.Screenshot",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
    TEST_METHOD(BasicScene_Frame60)
    {
        FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
        FAngelscriptEngineScope Scope(Engine);

        FAngelscriptTestWorld W(*TestRunner, Engine);
        // ... 编译 + spawn AS Actor + BeginPlay + 跑 60 帧 ...

        FAutomationScreenshotConfig Cfg;
        Cfg.ScreenshotName  = TEXT("AS_Rendering_BasicScene_Frame60");
        Cfg.ToleranceAmount = 0.02f;
        Cfg.ResolutionX     = 1280;
        Cfg.ResolutionY     = 720;

        // UE 标准 latent command：拍照 → 异步比对 → AddError on mismatch
        ADD_LATENT_AUTOMATION_COMMAND(FTakeScreenshotAfterTimeLatentCommand(0.5f, Cfg));
    }
};

#endif
```

注意几点：

1. **必须 `ASTEST_CREATE_ENGINE_FULL`**——共享引擎在多 case 间复用，渲染状态可能被前序 case 污染；隔离 Full 干净的多。
2. **必须 `ADD_LATENT_AUTOMATION_COMMAND`**——CQTest 的 `TEST_METHOD` 默认同步执行，UE 截图链路是异步的，必须挂 latent command 让 frame loop 推进。
3. **必须 `EditorContext` flag**——非 Editor 进程 UI 渲染链路缺失；CI 跑 commandlet 时这条 case 应被 filter 掉。

---

## 六、当前限制与已知风险

即使有一天落地，下列约束**先天存在**，不要等踩坑了再补救：

1. **NullRHI / `-nullrhi` 不可用**：UE 截图链路依赖 RHI 拷回 backbuffer；NullRHI 模式下要么直接跳过、要么得到全黑图。`Documents/Guides/Test.md` 里 headless lane 走的就是 NullRHI——任何截图 case 必须挂 `EAutomationTestFlags::NonNullRHI` 或自行 filter。
2. **Headless commandlet 不可用**：与上同理；commandlet lane 没有 viewport，不能拍图。
3. **CI Lane 选择**：截图 case 应只跑在 **client / editor 全栈 lane**（比如 PR 触发的 windows-editor-full lane），不应进 quick / headless 烟雾包。
4. **Cooked target 不可用**：cooked build 不带 Editor，依赖 `EditorContext` 的 case 全部跳过；如果未来要在 cooked 跑截图，得换 `FunctionalTesting` 的关卡内 actor 路径。
5. **平台差异**：Windows / Linux / Mac 的字体渲染、AA pattern、ICC 色彩管理都会把 baseline 拍出微差——`tolerance` 给低于 0.02 几乎一定 flaky。基线分平台存（`Test/Screenshots/<Platform>/<RHI>/`）是底线。
6. **Editor 版本漂移**：UE 5.7 → 5.8 升级时 Slate / 字体 / shader 任意一处变化都会让 baseline 失效。**升级 Engine 的提交里得专门规划 baseline 重生**。
7. **Two tests Disabled (`#ue57-headless`)**：`AGENTS.md` 现状——已经有 2 个 headless 限制 case 被禁用。任何新增截图 case 都会扩大 disabled 集合（除非显式接入 NonNullRHI lane），是已知风险。
8. **Plan_HealthCheck_2026Q2 误标**：当前文档系统里有一处 `Test_Screenshot.md "✅ 有内容"` 是错的（§一.2）；落地截图 helper 时**顺手修正这条 Plan**。
9. **`Plan_PIEMapBasedTestExpansion` 是规划，不是任务**：W20 的"TemporalLog / Insights / Screenshot 全集成"是**蓝图**，不是 OpenSpec 任务；要施工得先走 OpenSpec proposal（`AGENTS.md "OpenSpec & TODO"` 章节）。

---

## 七、与现有 Test 测试覆盖的关系

当前可能"近似"截图测试的两个目录：

### 7.1 `Functional/Widget/`

唯一文件 `AngelscriptWidgetBindWidgetTests.cpp`：

```cpp
// 节选自: Functional/Widget/AngelscriptWidgetBindWidgetTests.cpp
// 角色: 唯一的 UMG 测试——验证 BindWidget 元数据，不截图
// ============================================================================
TEST_CLASS_WITH_FLAGS(FAngelscriptBindWidgetTests,
    "Angelscript.TestModule.Functional.Widget.BindWidget",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
    TEST_METHOD(MetadataAndPropertyTypes)
    {
        FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
        // ... 编译 UFunctionalScoreWidget 验证 BindWidget UPROPERTY 元数据 ...
        // 全程通过反射读 UPROPERTY, 不触发渲染、不拍图
    }
};
```

它**只验证 UMG 元数据正确性**，不渲染、不截图——是"语言绑定层"测试，不是"渲染回归"测试。

### 7.2 `Functional/Rendering/`

唯一文件 `AngelscriptRenderingDynamicMaterialTests.cpp`，验证 AS 端访问 Material Parameter Collection——**也不截图**。它走 `UMaterialParameterCollection::SetVectorParameterValue` 之后通过 GetVectorParameterValue 读回，断言数值，与帧缓冲完全无关。

### 7.3 `AngelscriptEditor/Tests/`

`AngelscriptEditor` 模块的 Tests 目录有 `Angelscript.Editor.SourceNavigation.*` / `Angelscript.Editor.HotReload.*` 等 case，但都是逻辑测试，**没有**任何 viewport / Slate widget 截图。

### 7.4 结论

→ 仓库内目前 0 个截图测试在跑、0 条 CI lane 配截图比对、0 个 baseline 图片入库；本笔记是这个空缺的"占位说明"，不是实施手册。

---

## 附录 A：UE Automation Screenshot API 速查（外部框架，非本仓库）

| 类型 / 函数 | 头文件 | 用途 |
|------------|-------|------|
| `FAutomationScreenshotData` | `Engine/Source/Runtime/AutomationTest/Public/AutomationScreenshot.h` | metadata POD（图名、tolerance、平台、RHI） |
| `FAutomationScreenshotConfig` | 同上 | 用户级配置（resolution / tolerance / 抗锯齿旗子） |
| `FTakeScreenshotAfterTimeLatentCommand` | `Engine/Source/Developer/FunctionalTesting/Public/AutomationCommon.h` | latent command：等 N 秒 → 拍照 → 异步比对 |
| `FTakeAutomationScreenshotLatentCommand` | 同上 | 立即拍照变体 |
| `FFunctionalTestBase::TakeAutomationScreenshot` | `Engine/Source/Developer/FunctionalTesting/Public/FunctionalTest.h` | 关卡内 Actor 风格的拍照入口 |
| `FAutomationTestFramework::OnScreenshotCompared` | `AutomationTestFramework.h` | 比对完成回调 |
| `FScreenshotComparisonRequest` | `AutomationCommon.h` | 提交比对请求的内部结构 |
| 控制台 `HighResShot WxH` | `HighResScreenshot.cpp` | 手工触发高分截图 |
| `FPaths::ScreenShotDir()` | `Misc/Paths.h` | 截图输出根目录（**唯一已被本插件 AS 端绑定**的入口） |

baseline 检索优先级（链式回退）：

```text
Test/Screenshots/<Platform>/<RHI>/<Name>.png
   ▼ 找不到回退
Test/Screenshots/<Platform>/<Name>.png
   ▼ 找不到回退
Test/Screenshots/<Name>.png
   ▼ 全找不到
[首次跑] 当前帧写到 Saved/Automation/Incoming/，标 baseline 缺失
```

---

## 附录 B：调试技巧 / FAQ

1. **AS 脚本里能拍截图吗？** 当前**不能**。`Bind_FPaths.cpp` 只暴露目录路径查询，UE 的 `FAutomationScreenshotConfig` 没有任何绑定。要拍图只能在 C++ spec 侧调 UE API。
2. **baseline 找不到怎么办？** 第一次跑时 baseline 缺失是**预期**——UE 会把当前帧写到 `Saved/Automation/Incoming/<Name>.png`，**手工**审查 OK 后挪到 `Test/Screenshots/...` 入库。这个流程没法自动化。
3. **CI 偶发 flaky 怎么排查？** 看 `Saved/Automation/<TestName>/` 里的三张图（baseline / incoming / diff）；diff 图深红色区域是像素差异最大的地方。常见诱因：字体抗锯齿 / 阴影抖动 / 时间相关后处理（bloom 残留 / motion blur）。
4. **怎么彻底跳过截图 case？** 在 `RunTests.ps1` / RunTestSuite 入口加 `-NoScreenshot` 参数（**当前不存在**，要落地截图 case 时一起加）；或者前缀过滤掉 `*.Screenshot.*` 串。
5. **截图依赖 Editor 还是 Runtime？** UE 自带框架两条路径：`AutomationScreenshot`（Editor + Game 通用，需要 viewport）/ `FunctionalTest`（关卡内 Actor，可在 cooked 跑）。本仓库未来若要在 cooked / 服务器 lane 拍图，必须走后者。
6. **本插件未来要不要自己做差异对比？** **不建议**。UE 自带的 Image Comparison + HTML 报告已经够用；自封一层只会把 baseline 漂移问题搬到自己头上。Helper 只在"重复样板 ≥ 3 处"时才考虑抽，参考 `Test_Infrastructure.md` 附录 C.11。
7. **`FPaths::ScreenShotDir()` 在 AS 脚本里能干啥？** 主要用于在游戏内"拍照功能"——AS 写菜单按钮触发 `GEngine.Exec("HighResShot 1920x1080")` 之后告诉用户存哪了。**与 Automation 测试无关**。

---

## 小结

- 本仓库**当前没有截图测试 Helper**：`Shared/` 下零文件、`Functional/` 下零 case、CI lane 零任务、baseline 库零图片；与 "screenshot" 字面相关的代码只有 `Bind_FPaths.cpp` 暴露的 `FPaths::ScreenShotDir()` 路径查询。
- `Test_Infrastructure.md §七.1` 把这个空缺记为"待写"，本笔记完成占位——明确**不**抽 Helper（直到至少 3 个跨主题需要才考虑），明确截图 API 不进 `Shared/` 公共头。
- 若未来 `Plan_PIEMapBasedTestExpansion §E.3.O4` 真的施工，落点应是 `AngelscriptTest/Functional/<Theme>/AngelscriptXxxScreenshotTests.cpp` 或 `AngelscriptEditor/Tests/AngelscriptEditorXxxScreenshotTests.cpp`；Build.cs 需要补 `FunctionalTesting` / `MovieSceneCapture` / `ImageWriteQueue` 三个依赖。
- 限制层面：NullRHI / headless / commandlet / cooked target 全部不可用；只能跑在 editor-full lane；Engine 升级会让 baseline 普遍失效，需专门重生节点。
- `Documents/Guides/Test_Screenshot.md` 当前是 **0 字节空文件**，但 `Plan_HealthCheck_2026Q2 §17` 误标为 "✅ 有内容"——审计时一并修正。
- 一句话：**本笔记记录的是"为什么没有"、"什么时候才该有"、"真要有时该放哪"**——它替你把所有"先想清楚"的问题写在了前面，避免日后第一个落地的人重新踩一遍。
