# ScriptMixin Re-enable Audit Matrix

> 本矩阵是 `Plan_FunctionLibrariesCleanup.md` Phase 4 的 P4.1 产出，作为 P4.2 / P4.3 / P4.4 实施的精确分类依据。
>
> 数据采集时点：2026-04-28（fork commit `53a3f98`）。仅基于**静态分析**（`Bind_*.cpp` include 扫描 + .h 实现形态），未依赖运行时 `as.DumpEngineState` 数据。

## 三个汇总数

| 汇总维度 | 数值 | 落点 |
|---|---:|---|
| ① 总锚点数 | **16**（分布在 7 个文件）| 详见 §1 全景表 |
| ② 可重启锚点数 | **15**（类 1.5 + 类 3）| P4.2 / P4.3 实施目标 |
| ③ 禁止重启锚点数 | **1**（类 1，仅 WorldLibrary）| P4.4 单独决策（手工接管 vs 切回 ScriptMixin）|

P4.x 与 Phase 5 的协同：

- P5.1 已确认 16 处锚点 100% 是 Hazelight 上游 active ScriptMixin（真 parity gap）—— 意味着 P4.2 / P4.3 重启工作在签名层面有上游兜底参考
- P5.4 注释清理工作量进一步缩窄：仅在 P4.x 完成后 修整 6 处 cleanup parity note 的描述准确性，不删除任何锚点

## 1. 锚点全景分类表

| # | 文件 | 锚点 ScriptMixin 目标 | Bind_*.cpp 命中 | 类型 | 重启可行性 | P4.x 落点 |
|---|---|---|---|---|---|---|
| 1 | `AngelscriptWorldLibrary.h` | `UWorld` | `Bind_UWorld.cpp:7` (include) + `Bind_UWorld.cpp:81` (实际调用) | **类 1** | **禁止** | P4.4 单独决策 |
| 2 | `InputComponentScriptMixinLibrary.h` | `UInputComponent` | `Bind_InputComponentScriptMixins.cpp:4` (include) | **类 1.5** | 可重启 | P4.3 |
| 3 | `InputComponentScriptMixinLibrary.h` | `APlayerController` | 同上 | 类 1.5 | 可重启 | P4.3 |
| 4 | `InputComponentScriptMixinLibrary.h` | `UPlayerInput` | 同上（`AddFunctionEntry`/`ERASE_FUNCTION_PTR` 用于 UHT 重载消歧）| 类 1.5 | 可重启 | P4.3 |
| 5 | `AngelscriptMathLibrary.h` | `FVector` | 无 | **类 3** | 可重启 | P4.3 |
| 6 | `AngelscriptMathLibrary.h` | `FVector3f` | 无 | 类 3 | 可重启 | P4.3 |
| 7 | `AngelscriptMathLibrary.h` | `FRotator` (with `ScriptName = "FRotator"`) | 无 | 类 3 | 可重启 | P4.3 |
| 8 | `AngelscriptMathLibrary.h` | `FRotator3f` (with `ScriptName = "FRotator3f"`) | 无 | 类 3 | 可重启 | P4.3 |
| 9 | `AngelscriptMathLibrary.h` | `FQuat` (with `ScriptName = "FQuat"`) | 无 | 类 3 | 可重启 | P4.3 |
| 10 | `AngelscriptMathLibrary.h` | `FQuat4f` (with `ScriptName = "FQuat4f"`) | 无 | 类 3 | 可重启 | P4.3 |
| 11 | `AngelscriptMathLibrary.h` | `FTransform` (with `ScriptName = "FTransform"`) | 无 | 类 3 | 可重启 | P4.3 |
| 12 | `AngelscriptMathLibrary.h` | `FTransform3f` (with `ScriptName = "FTransform3f"`) | 无 | 类 3 | 可重启 | P4.3 |
| 13 | `AngelscriptHitResultLibrary.h` | `FHitResult` | 无 | 类 3 | 可重启 | **P4.2 试点首选** |
| 14 | `GameplayTagContainerMixinLibrary.h` | `FGameplayTagContainer` | 无 | 类 3 | 可重启 | P4.3 |
| 15 | `GameplayTagMixinLibrary.h` | `FGameplayTag` | 无 | 类 3 | 可重启 | P4.3 |
| 16 | `UAssetManagerMixinLibrary.h` | `UAssetManager` | 无 | 类 3 | 可重启 | P4.3 |

---

## 2. 三类（实为四类）定义与判定依据

### 类 1：`Bind_*.cpp` 手工 lambda 完全接管

**判定依据**：
- `Bind_*.cpp` `#include "FunctionLibraries/<X>.h"` ✓
- `Bind_*.cpp` 含 `<TargetType>_.Method("...", [&] { ... UAngelscript<X>Library::Method(...) })` 形态
- 实际调用了 `UAngelscript<X>Library::<func>` 静态方法

**典型样本**：`AngelscriptWorldLibrary.h` × `Bind_UWorld.cpp:79-82`

```cpp
UWorld_.Method("TArray<ULevelStreaming> GetStreamingLevels() const", [](const UWorld* World) -> TArray<ULevelStreaming*>
{
    return UAngelscriptWorldLibrary::GetStreamingLevels(World);
});
```

**重启风险**：
- 反射 mixin 路径会试图再次注册 `World.GetStreamingLevels()`
- 若签名一致（`TArray<ULevelStreaming> GetStreamingLevels() const` 完全等价），被 `Bind_BlueprintCallable.cpp:62-70` 的 `IsScriptDeclarationAlreadyBound` 静默跳过 —— 白做工
- 若签名细微差异（`TArray<ULevelStreaming@>` vs `TArray<ULevelStreaming>`、`bForceConst` 推导不一致），AS 引擎注册成两条 overload —— 调用歧义

**结论**：类 1 文件**禁止**自动 P4.3 批量重启；改在 P4.4 单独决策（保留手工接管 / 切回 ScriptMixin 删除手工 lambda）。

**P4.4 实测结论（2026-04-28，Bind_UWorld 删除手工 lambda + 重启 ScriptMixin）**：fork 当年加 lambda 的目的是"强制 AS 签名 `TArray<ULevelStreaming>` 而非反射推导的 `TArray<ULevelStreaming@>`"，但删除后 AS 测试 `WorldStreamingNullGuards` / `WorldStreamingAccess` 共 2 个全部 PASS，零回归。**根因**：fork 已处理 `TObjectPtr` 路由，UObject 容器在 AS 中按引用语义传递，`@` 与无 `@` 形式在调用语义上等价（`.Num()` / `[i] != Expected` 等用法跨形式可移植）。**类 1 在 fork 中的实例数**：原 1 处（World）已迁移；fork 内**类 1 实例数归 0**，未来扫描需重新评估"是否有新增手工 lambda"。

### 类 1.5：`Bind_*.cpp` UHT 重载消歧 helper（fork 独有 / 非接管）

**判定依据**：
- `Bind_*.cpp` `#include "FunctionLibraries/<X>.h"` ✓
- `Bind_*.cpp` 仅含 `FAngelscriptBinds::AddFunctionEntry` + `ERASE_FUNCTION_PTR` 形态
- **不**含 `Method(...lambda...)` 形态
- 注释自陈"UHT marks these wrappers overloaded-unresolved, so register the exact signatures before the generated function table falls back to reflective dispatch"

**典型样本**：`InputComponentScriptMixinLibrary.h` × `Bind_InputComponentScriptMixins.cpp:6-26`

```cpp
FAngelscriptBinds::AddFunctionEntry(
    UPlayerInputScriptMixinLibrary::StaticClass(),
    "AddActionMapping",
    { ERASE_FUNCTION_PTR(UPlayerInputScriptMixinLibrary::AddActionMapping, (UPlayerInput*, const FInputActionKeyMapping&), ERASE_ARGUMENT_PACK(void)) });
```

**关键差别**：这条路径只是补充函数指针表（让 UHT 生成的反射函数表知道精确指针），它**不**注册 AS 成员方法 —— 跟 ScriptMixin 反射注入路径正交、可共存。

**重启策略**：可与 ScriptMixin 重启**共存**——重启后函数获取成员方法形式（mixin 路径），重载消歧 helper 仍提供精确函数指针。但 P4.3 实施前需要试编译验证 ScriptMixin 重启后是否引入新的 UHT 警告。

### 类 2：`BlueprintCallableReflectiveFallback` 反射兜底（**fork 内实例为 0**）

**判定依据**：
- `Bind_*.cpp` 无 include
- 函数实现位于独立 `.cpp`（导致 native function pointer 可能为 nullptr）
- `Bind_BlueprintCallable.cpp:74-91` 走 `BindBlueprintCallableReflectiveFallback` 路径

**fork 现状**：扫了 5 个候选文件（Math / Hit / TagContainer / Tag / AssetMgr），**全部** static 函数都是 `.h` 内 inline 实现，没有 sidecar `.cpp`，意味着 native function pointer 总是有效 —— **不会走 ReflectiveFallback**。

**结论**：fork 当前 16 处锚点中**类 2 实例为 0**。理论上若未来某个 mixin 库改为 sidecar `.cpp` 实现，分类会变化；但 P4.x 当前阶段无类 2 案例。

### 类 3：仅静态命名空间形式可见（5 个文件，12 处锚点）

**判定依据**：
- `Bind_*.cpp` 无 include
- `.h` 内 static 函数有 inline 实现（native function pointer 有效）
- AS 脚本里只能用 `Lib::Func(target, ...)` 静态形式调用，**无成员方法形式**

**重启效果**（最理想的纯增益）：取消 `//UCLASS(Meta = (ScriptMixin = "..."))` 注释后，`Helper_FunctionSignature.h:339` 的 mixin 注入路径会自动生效，AS 脚本里既可以保留原 `Lib::Func(target, ...)` 形式（如有 `bGlobalScope`），也可以新获得 `target.Func(...)` 成员方法形式 —— **对齐 Hazelight 上游**。

**P4.2 试点首选**：`AngelscriptHitResultLibrary.h`（FHitResult）—— 单 mixin 子类、11 个函数、active 行 ScriptTrivial 已齐全（见 `MetaLossMatrix.md` §1）、Hazelight 上游 active ScriptMixin 一致，是验证最小最安全的样本。

---

## 3. P4.x 执行映射

| Phase 任务 | 本矩阵驱动数据 | 执行规模 |
|---|---|---|
| P4.2（单文件试点）| §1 第 13 行（HitResult） | 1 个文件、1 个锚点解封、1 个 commit |
| P4.3（批量重启类 3 + 类 1.5） | §1 第 5-12, 14-16 行（11 处类 3）+ 第 2-4 行（3 处类 1.5）| 共 14 锚点，建议**按文件单独提交**（5 个 commit）|
| P4.4（类 1 单独决策） | §1 第 1 行（World） | 单文件单决策、最多 2 个 commit（决策 + 执行）|

P4.x 与 Phase 5 协同：

- **P5.3 与 P4.3 不冲突**：P5.3 补 3 个**完全没写过**的 Static 子类（`UAngelscriptFQuatStaticLibrary` 等），P4.3 重启 16 个**已有 //注释锚点**的 mixin 子类 —— 操作类型严格区分
- **P5.2 与 P4.2/P4.3 协同**：P5.2 补 16 个 helper 函数时若文件 ScriptMixin 已重启（P4.2/P4.3 已合入），新补函数应同步携带 `BlueprintCallable` + 完整 Meta，自然走 mixin 注入
- **P5.4 在 P4.x 全部完成后做**：6 处 cleanup parity note 描述修整需要参考最终的 ScriptMixin 状态

---

## 4. 类 1（World）单独决策框架（P4.4）

### 4.1 当前手工接管价值

| 控制维度 | 手工 lambda 提供 | 反射 mixin 路径默认 |
|---|---|---|
| 返回值类型 | `TArray<ULevelStreaming>` | `TArray<ULevelStreaming@>` |
| `const` 限定 | 显式 `const` | `bForceConst` 推导（依赖第一参数 `const UWorld*`）|
| 第一参数剥离 | lambda 中显式接收 + 调用 helper | `Helper_FunctionSignature.h:382` 自动 `RemoveAt(0)` |
| 自定义类型映射 | 任意（lambda 可包装/转换）| 仅按 reflection 默认规则 |

### 4.2 决策选项

- **选项 A（保留手工接管）**：在文件头永久标注"由 `Bind_UWorld.cpp` 接管，禁止重启 ScriptMixin"。已在 `cc764db` 注释中实现，本计划无需再动。
- **选项 B（切回 ScriptMixin 路径）**：删除 `Bind_UWorld.cpp:79-82` 手工 lambda + 重启 `ScriptMixin = "UWorld"` + 修整 helper 函数返回类型让反射路径产物等价于原手工签名。需要确认 AS 脚本对返回值的 `@` 指针引用是否可接受。

### 4.3 P4.4 推荐决策

**保持选项 A 不变**：当前 `Bind_UWorld.cpp` 仅有 1 处手工 lambda，维护成本低、签名控制收益明确。除非 Phase 5 后续发现这条路径阻碍其他 helper 接入，否则不切。

---

## 5. 数据采集命令记录

```powershell
# 类 1 / 类 1.5 启发式：Binds/*.cpp 是否 include 候选 .h
$candidates = @("AngelscriptHitResultLibrary","AngelscriptMathLibrary","AngelscriptWorldLibrary",
                "GameplayTagContainerMixinLibrary","GameplayTagMixinLibrary",
                "InputComponentScriptMixinLibrary","UAssetManagerMixinLibrary")
foreach ($c in $candidates) {
    $hits = Select-String -Path "Plugins\Angelscript\Source\AngelscriptRuntime\Binds\*.cpp" `
        -Pattern "FunctionLibraries/$c"
    if ($hits) { Write-Host "$c -> $($hits.Filename | Sort -Unique)" }
}

# 类 1 vs 类 1.5 区分：是否含 Method(... lambda ...) 形态
Select-String -Path "Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_UWorld.cpp" `
    -Pattern "_\.Method\("
Select-String -Path "Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_InputComponentScriptMixins.cpp" `
    -Pattern "_\.Method\("

# 类 2 vs 类 3 区分：函数实现是 inline 还是 sidecar .cpp
$ours = "Plugins\Angelscript\Source\AngelscriptRuntime\FunctionLibraries"
foreach ($f in @("AngelscriptHitResultLibrary","AngelscriptMathLibrary",
                  "GameplayTagContainerMixinLibrary","GameplayTagMixinLibrary",
                  "UAssetManagerMixinLibrary")) {
    $hasCpp = Test-Path "$ours\$f.cpp"
    Write-Host "$f.h: HasSidecarCpp=$hasCpp"
}
```

后续运行时验证（可选）：完成 P4.2 试点后跑 `as.DumpEngineState` 导 `BindFunctions.csv`，按 mixin 目标类型搜成员方法形式是否注入成功，与 P5.1 矩阵的 Hazelight 期望对照。
