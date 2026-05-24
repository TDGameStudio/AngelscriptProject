# AngelscriptTest 测试模块清理清单

> 最后评估：2026-05-25  
> 背景：Bindings P1/P2/P5 已合并（子模块 `420c7af`）。本文档是**后续 backlog**，不是实施计划。  
> 规范入口：`Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md`、`Shared/README.md`。

---

## 评估摘要（先看这里）

| 优先级 | 工作量 | 收益 | 建议项 |
|--------|--------|------|--------|
| **P0** | 极小 | 高 | ✅ 5 个 Bindings 文件头注释已更新（2026-05-25） |
| **P1** | 小 | 中 | ✅ `LogCategory` / `TArrayBindingsFormatCoverageText` 已删除（2026-05-25） |
| **P2** | 中 | 中 | include 已统一为无 `Shared/` 前缀（Build.cs + 184 文件）；转发 shim 仍可用 |
| **P3** | 中～大 | 低～中 | Bindings 专用 Private 抽 helper；WorldFunctionLibrary 仅常量 Private |
| **Defer** | 大 | 低（可读性） | TArray Profile 改 `constexpr`、去掉 `Run*Section` 的 `Profile` 参数 |
| **不做** | — | — | 全模块 ~178 个 `*_Private` 收敛；Shared 物理分目录 |

**关于 TArray 两个 `CoverageProfile()` 函数：**  
**不是多余**——两套配置必须并存；**可简化的是**「函数 + 文件内 `static const`」这一层包装，以及未使用的 `LogCategory` / 恒等 `FormatCoverageText`。不必为删函数而删函数。

**本文档是否保留：** 建议保留至 P0+P2 完成后再删或缩成 `Shared/README.md` 一段「Optional follow-ups」。

---

## 1. TArray `CoverageProfile`（设计说明）

### 1.1 什么不能删

| 字段 / 配置 | TArray 标准 | Syntax compat | 用途 |
|-------------|-------------|---------------|------|
| `ModulePrefix` | `ASTArray` | `ASTArraySyntaxCompat` | `BuildCoverageModule` 模块名 |
| `TraceFunctionDecl` | `TraceTArrayCase` | `TraceSyntaxCase` | 脚本内 trace 声明 |
| `bBracketArraySyntax` | `false` | `true` | `TArray<T>` vs `T[]` |
| `CasePrefix` | `TArray` | `TArraySyntax` | **有使用**：`TArrayBindingsTests.cpp` 里 `AddInfo` 日志前缀 |

### 1.2 什么可以删或简化

| 项 | 现状（已核对） | 建议 |
|----|----------------|------|
| `LogCategory` | 工厂函数里赋值 `TArrayBindings` / `TArraySyntaxCompatBindings`，**全仓库无读取** | **删除**成员及初始化 |
| `TArrayBindingsFormatCoverageText` | `return Text;`，调用 ~10+ 处但无格式化效果 | **内联**为 `ContextLabel`，或实现 `[CasePrefix] Label` |
| `TArrayBindingsCoverageProfile()` 等 | 仅返回字面量聚合 | 可改为 `inline constexpr TArrayBindingsProfile{...}`；**非必须** |
| `Run*Section(..., Profile)` | 单文件内 Profile 固定 | 去掉参数可减少传参噪音；**大范围 diff，Defer** |

### 1.3 `constexpr` 示例（若做 cosmetic）

注意字段顺序须与结构体一致（含删除 `LogCategory` 后）：

```cpp
struct FTArrayBindingsTestProfile  // 可选重命名
{
	const TCHAR* CasePrefix = nullptr;
	const TCHAR* ModulePrefix = nullptr;
	const TCHAR* TraceFunctionDecl = nullptr;
	bool bBracketArraySyntax = false;
};

inline constexpr FTArrayBindingsTestProfile TArrayBindingsProfile{
	TEXT("TArray"), TEXT("ASTArray"), TEXT("void TraceTArrayCase(const FString&in)"), false};

inline constexpr FTArrayBindingsTestProfile TArraySyntaxCompatProfile{
	TEXT("TArraySyntax"), TEXT("ASTArraySyntaxCompat"), TEXT("void TraceSyntaxCase(const FString&in)"), true};
```

验证：`Angelscript.TestModule.Bindings.Container.TArray`（2 tests）。

---

## 2. Bindings — P0 过期注释（应立即做）

以下文件**代码已迁移**，头注释仍写旧 helper，易让后续改回 Private Execute：

| 文件 | 过期描述 | 应改为 |
|------|----------|--------|
| `AngelscriptMathBindingsTests.cpp` | `ExecuteValueFunction`、Private namespace | `ExecuteAndExtractStruct` + `AngelscriptMathBindingsTestCompare.h` |
| `AngelscriptMathOrientationBindingsTests.cpp` | 同上 | 同上 |
| `AngelscriptAssetRegistryBindingsTests.cpp` | `ExecuteFunctionExpectingException` | `WorldCollisionExecuteFunctionExpectingException` |
| `AngelscriptWorldFunctionLibraryTests.cpp` | `ExecuteBoolFunction` 等 retained | `WorldCollisionExecute*` / `FAngelscriptTestExecutor` |
| `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp` | address-based helpers retained | `AngelscriptWorldCollisionBindingsTestHelpers.h` |
| `AngelscriptGameInstanceLocalPlayerBindingsTests.cpp` | helpers retained（若仍准确可只改措辞） | 核对后仅更新不准确部分 |

**不在此列：** `AngelscriptScriptFunctionLibraryTests.cpp` 的 Private 仍合理（`ExecuteStringGlobalFunction` 已用 Executor，但含热重载模块脚手架）。

---

## 3. Bindings — P3 专用 Private（保留为主）

| 文件 | Private 内容 | 动作 |
|------|--------------|------|
| `AngelscriptReflectiveFallbackCacheTests.cpp` | 缓存 / GameplayTag 前缀 | 保留；过长再抽 helper |
| `AngelscriptMathAndPlatformBindingsTests.cpp` | `FormatScriptFloatLiteral` | 保留；可抽 `*TestHelpers.h` |
| `AngelscriptTextFormattingBindingsTests.cpp` | 文本格式化 | 保留 |
| `AngelscriptWorldCollisionBindingsTests.cpp` | 碰撞体、Functional 世界 | 保留 |
| `AngelscriptCollisionParamsBindingsTests.cpp` | `CopyIgnoredIds` | 保留 |
| `AngelscriptAssetRegistryBindingsTests.cpp` | AssetRegistry 查询 helper | 可选抽 `*TestHelpers.h` |
| `AngelscriptScriptFunctionLibraryTests.cpp` | 热重载 + `ExecuteStringGlobalFunction` | 保留 |
| `AngelscriptWorldFunctionLibraryTests.cpp` | 仅 2 个模块名 `constexpr` | 可改为匿名 `namespace` |
| `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp` | 组件/世界 | 保留 |
| `AngelscriptWorldCollisionAsyncBindingsTests.cpp` | Async + Functional | 保留 |

**已从 backlog 移除：** `AngelscriptDataTableBindingsTests.cpp` — 已使用全局 `ExecuteIntFunction`，无需 P1 式迁移。

**Console 簇：** Bindings 批量 include 已覆盖主文件；无单独 `Console/` 子目录问题。

---

## 4. Syntax / Functional — P2 include 迁移

### 4.1 规模（2026-05-25 实测）

```text
rg -l 'AngelscriptBindingsAssertions\.h' ... --glob '*.cpp'  →  25 个文件
```

分布大致为：Syntax ~17、Functional Interface/Inheritance ~7、`Template/Template_CQTest.cpp` ~1（路径重复计数去重后约 25）。

Bindings 目录：**0**（已完成）。

### 4.2 更高效做法

不要只批量改 25 个 `.cpp`：

1. **先改** `Syntax/AngelscriptSyntaxTestHelpers.h`（仍 `#include "Shared/AngelscriptBindingsAssertions.h"`）→ 改为 `AngelscriptTestExecute.h` + 按需 `AngelscriptTestModuleScope.h`。  
2. 再对仍**直接** include shim 的 `.cpp` 跑 `Tools/Diagnostics/UpdateBindingsTestIncludes.py`（扩展 glob 到 `Syntax/`、`Functional/`、`Template/`）。

`Template_CQTest.cpp`、`Shared/AngelscriptBindingsExampleSectionTests.cpp` 仍含 `FCoverageModuleScope` 字样（注释/示例），与 shim 迁移一并处理。

### 4.3 验证

```powershell
rg "AngelscriptBindingsAssertions\.h" Plugins/Angelscript/Source/AngelscriptTest --glob "*.{cpp,h}"
rg "FCoverageModuleScope" Plugins/Angelscript/Source/AngelscriptTest --glob "*.cpp"
```

目标：测试源文件为 0（Shared 转发头 `.h` 自身可保留）。

---

## 5. Shared / 全模块 — 长期 Defer

| 项 | 说明 |
|----|------|
| 转发 shim 退役 | Syntax/Functional 迁完后再加 deprecation 注释 |
| `AngelscriptTestUtilities.h` 伞头 | 新代码 include 子头；不大规模改 305 TU |
| `Shared/Engine\|Execute\|Module/` 物理分目录 | 单独 OpenSpec |
| 全模块 `AngelscriptTest_*_Private` | ~178 文件；按 HotReload / Learning 等主题分批，**勿与 Bindings 混做** |

---

## 6. 父仓库临时脚本

| 文件 | 状态 | 建议 |
|------|------|------|
| `UpdateBindingsTestIncludes.py` | **已提交** | P2 扩展 glob 后复用 |
| `strip_tarray_private.py` 等 3 个 | 未跟踪 | 删除本地副本，勿提交 |

---

## 7. 推荐实施顺序（修订）

1. **P0**：6 个 Bindings 文件头注释（可单独 PR，零行为变化）。  
2. **P1**：TArray helper 删 `LogCategory`、内联 `FormatCoverageText`。  
3. **P2**：`AngelscriptSyntaxTestHelpers.h` + 脚本扩展 + 剩余 `.cpp`。  
4. **P3**：按需抽 ReflectiveFallback / MathAndPlatform helper。  
5. **Defer**：TArray `constexpr` / 去掉 `Run*Section` Profile 参数。

---

## 8. 验证命令

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Container.TArray"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Math"
```

---

## 9. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-05-25 | 初版 |
| 2026-05-25 | **再评估**：增加摘要表；修正 Syntax 文件数（25）；标出 `SyntaxTestHelpers.h` 枢纽；`CasePrefix` 有使用；DataTable 移出 backlog；补充 6 个过期注释文件；区分 P0/P1/P2/Defer |
| 2026-05-25 | **实施**：P0 注释（Math×2、AssetRegistry、WorldFunctionLibrary、WorldCollision Trace）；P1 TArray helper；`AngelscriptSyntaxTestHelpers.h` → `AngelscriptTestExecute.h` |
