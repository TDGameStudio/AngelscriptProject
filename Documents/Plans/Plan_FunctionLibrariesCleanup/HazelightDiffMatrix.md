# Hazelight Upstream FunctionLibraries Diff Matrix

> 本矩阵是 `Plan_FunctionLibrariesCleanup.md` Phase 5 的 P5.1 产出，作为 P5.2 / P5.3 / P5.4 实施的精确输入。
>
> 数据采集时点：2026-04-28（fork commit `53a3f98`，Hazelight 工作树 `K:\UnrealEngine\UEAS\Engine\Plugins\Angelscript\Source\AngelscriptCode\`）

## 三个汇总数（P5.1 验收要点）

| 汇总维度 | 数值 | 落点 |
|---|---:|---|
| ① 缺函数总数（active `UFUNCTION`） | **21**（19 + Phase 2 后新增 ActorLibrary 缺 `GetAttachedActors` / `GetAttachedActorsOfClass` 2 处）— P5.2 完成 **20/21**：5 小文件函数 + 15 Math 函数已恢复；1 处 `WrapUInt(uint32)` 因 UHT BlueprintCallable + uint32 不兼容**永久 deferred**（详见 Plan P5.2 Math 部分实施记录）| P5.2 已收口 |
| ② 缺 mixin 子类总数（active `UCLASS`） | **3** | P5.3 实施目标 |
| ③ 可清理锚点注释数（`//UCLASS(Meta = (ScriptMixin = "..."))` 但 Hazelight 上游也无该 mixin） | **0** | P5.4 实施目标，**所有 16 处锚点全是真 parity gap** |

辅助统计：

- fork 与 Hazelight 都是 **20 个 `.h`，文件层面 100% 一致**，无新增/缺失文件。
- fork 共 **16 处 `//UCLASS(Meta = (ScriptMixin = "..."))` 锚点**，全部对应 Hazelight 上游 active `ScriptMixin`（详见 §3 全景表）；P5.4 实质工作变为"修整 7 处 cleanup parity note 的描述准确性"，非"删除锚点"。
- 16 个文件**完全 parity**（函数数 / UCLASS 数 / mixin 子类 100% 一致）；4 个文件存在缺漏（详见 §2）。

---

## 1. 文件级高层数据表

模块路径差异（不算 parity gap）：fork 用 `AngelscriptRuntime/FunctionLibraries/`，Hazelight 用 `AngelscriptCode/Public/FunctionLibraries/` 与 `AngelscriptCode/Private/FunctionLibraries/`。

| 文件 | Haze 行 | Fork 行 | Haze UCLASS | Fork UCLASS | Haze UFUNC | Fork UFUNC | Gap |
|---|---:|---:|---:|---:|---:|---:|---|
| `AngelscriptActorLibrary.h` | 186 | 81 | 1 | 1 | 29 | 9 | **P2.2 后修正** Phase 2 已完成 B' 混合处置：保留 9 fork 独有 + 删 21 冗余；fork 仍多 `SetActorLocationAdvanced`，**Hazelight 多 `GetAttachedActors` / `GetAttachedActorsOfClass`**（待 P5.2 补） |
| `AngelscriptComponentLibrary.h` | 231 | 208 | 1 | 1 | 36 | 36 | 完全 parity（待 §6 meta 维度 P1.1 补） |
| `AngelscriptFrameTimeMixinLibrary.h` | 16 | 15 | 1 | 1 | 1 | 1 | 完全 parity |
| `AngelscriptHitResultLibrary.h` | 100 | 75 | 1 | 1 | 12 | 11 | **缺 1 函数：`SetPhysMaterial`** |
| `AngelscriptLevelStreamingLibrary.h` | 17 | 16 | 1 | 1 | 1 | 1 | 完全 parity |
| `AngelscriptMathLibrary.h` | 957 | 735 | 12 | 9 | 103 | 87 | **缺 16 函数 + 3 static 子类**（见 §2.1）|
| `AngelscriptScriptLibrary.h` | 28 | 28 | 1 | 1 | 3 | 3 | 完全 parity |
| `AngelscriptWorldLibrary.h` | 15 | 29 | 1 | 1 | 1 | 1 | 完全 parity（fork +14 行是 cleanup note，已修正为 `Bind_UWorld.cpp` 手工接管说明）|
| `GameplayLibrary.h` | 57 | 57 | 1 | 1 | 2 | 2 | 完全 parity |
| `GameplayTagContainerMixinLibrary.h` | 119 | 122 | 1 | 1 | 21 | 20 | **缺 1 函数：`AppendTags`** |
| `GameplayTagMixinLibrary.h` | 59 | 67 | 1 | 1 | 9 | 9 | 完全 parity（fork +8 行是 cleanup note）|
| `GameplayTagQueryMixinLibrary.h` | 29 | 29 | 1 | 1 | 3 | 3 | 完全 parity |
| `InputComponentScriptMixinLibrary.h` | 191 | 235 | 3 | 3 | 22 | 22 | 完全 parity（fork +44 行是 cleanup note + 三处 ScriptMixin 关闭注释）|
| `RuntimeCurveLinearColorMixinLibrary.h` | 21 | 19 | 1 | 1 | 1 | 1 | 完全 parity |
| `RuntimeFloatCurveMixinLibrary.h` | 230 | 230 | 1 | 1 | 27 | 27 | 完全 parity |
| `SoftReferenceStatics.h` | 11 | 11 | 1 | 1 | 0 | 0 | 完全 parity |
| `SubsystemLibrary.h` | 50 | 50 | 1 | 1 | 6 | 6 | 完全 parity |
| `UAssetManagerMixinLibrary.h` | 72 | 113 | 1 | 1 | 10 | 9 | **缺 1 函数：`ScanPathForPrimaryAssets`** |
| `WidgetBlueprintStatics.h` | 32 | 32 | 2 | 2 | 2 | 2 | 完全 parity |
| `WorldCollisionStatics.h` | 13 | 12 | 1 | 1 | 0 | 0 | 完全 parity（仅 UCLASS 占位）|
| **合计** | 2433 | 2280 | 31 | 28 | 286 | 267 | **20 文件中 4 个有 gap，16 个完全 parity** |

---

## 2. 文件级精细 diff（仅 4 个 gap 文件）

### 2.1 `AngelscriptMathLibrary.h` — 最大缺口

#### 2.1.1 缺 3 个 active `UCLASS` Static 子类（P5.3 直接补全目标）

Hazelight 12 个 active UCLASS，fork 仅 9 个；缺以下 3 个：

| Hazelight UCLASS 行 | 类名 | 用途 |
|---|---|---|
| `UCLASS(Meta = (ScriptName = "FQuat"))` | `UAngelscriptFQuatStaticLibrary` | FQuat 静态 helper（与 `UAngelscriptFQuatLibrary` 的 mixin 方法分离） |
| `UCLASS(Meta = (ScriptName = "FRotator"))` | `UAngelscriptFRotatorStaticLibrary` | FRotator 静态 helper |
| `UCLASS(Meta = (ScriptName = "FTransform"))` | `UAngelscriptFTransformStaticLibrary` | FTransform 静态 helper |

补全策略：Hazelight 用"主子类承载 mixin 方法 + Static 子类承载静态构造/常量/工具"的双子类模式来分离 AS 命名空间下的"成员调用"和"`FQuat::XXX(...)` 静态调用"。补回时直接以 enabled 状态合入，无需走"先注释 → 后重启"两步。

#### 2.1.2 fork 8 个子类的 `ScriptMixin` meta 全部被关闭（与 §3 锚点表交叉）

Hazelight：`UCLASS(Meta = (ScriptMixin = "FVector"))` 等 8 个子类全是 active `ScriptMixin` + `ScriptName`。

fork：所有 8 个改成了 `UCLASS()` 或 `UCLASS(Meta = (ScriptName = "..."))`，原始 `ScriptMixin = "..."` 部分被抹掉，并以 `//UCLASS(Meta = (ScriptMixin = "..."))` 死注释保留作为锚点（见 §3）。

→ 这部分由 Phase 4 P4.2 / P4.3 处理（重启 ScriptMixin meta），**不在 P5.3 范围**。Phase 5 与 Phase 4 在 MathLibrary 的分工：P5.3 补 3 个完全没写过的 Static 子类、P4.x 重启 8 个已存在锚点的 mixin 子类。

#### 2.1.3 缺 16 个 active `UFUNCTION`（P5.2 直接补全目标）

按重载分组：

##### 重载组 A：transform 增量/相对工具（4 组 × 3 重载 = 12 函数）

每组 FQuat / FRotator / FTransform 三重载，签名一致。

```cpp
// ApplyDelta — 在原始 transform 上叠加增量
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FQuat ApplyDelta(const FQuat& OriginRotation, const FQuat& DeltaRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FRotator ApplyDelta(const FRotator& OriginRotation, const FRotator& DeltaRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FTransform ApplyDelta(const FTransform& OriginTransform, const FTransform& DeltaTransform);

// ApplyRelative — 父空间合成子相对 transform
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FQuat ApplyRelative(const FQuat& ParentWorldRotation, const FQuat& ChildRelativeRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FRotator ApplyRelative(const FRotator& ParentWorldRotation, const FRotator& ChildRelativeRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FTransform ApplyRelative(const FTransform& ParentWorldTransform, const FTransform& ChildRelativeTransform);

// GetDelta — 求两 transform 间的增量
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FQuat GetDelta(const FQuat& OriginRotation, const FQuat& TargetRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FRotator GetDelta(const FRotator& OriginRotation, const FRotator& TargetRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FTransform GetDelta(const FTransform& OriginTransform, const FTransform& TargetTransform);

// GetRelative — 父子世界 transform 求子相对父
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FQuat GetRelative(const FQuat& ParentWorldRotation, const FQuat& ChildWorldRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FRotator GetRelative(const FRotator& ParentWorldRotation, const FRotator& ChildWorldRotation);
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FTransform GetRelative(const FTransform& ParentWorldTransform, const FTransform& ChildWorldTransform);
```

##### 重载组 B：单函数（4 函数）

```cpp
// FVector 子类
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial))
static FVector GetSafeNormal2D(const FVector& Vector, const FVector& UpDirection,
                                double Tolerance = 0.0,
                                const FVector& ResultIfZero = FVector::ZeroVector);

// 全局 Math 子类
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FVector MakeAngularVelocityFromDeltaRotation(const FQuat& DeltaRotation, float DeltaTime);

UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FQuat MakeDeltaRotationFromAngularVelocity(const FVector& AngularVelocity, float DeltaTime);

// 全局 Math 子类（带 deprecation 标记）
UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptName = "Wrap", ScriptNoDiscard,
    DeprecatedFunction,
    DeprecationMessage = "Wrapping integers is inclusive, and returns unintuitive values. Use Math::WrapIndex for the natural behavior."))
static uint32 WrapUInt(uint32 X, uint32 Min, uint32 Max);
```

##### Meta 转换提示

按 fork 当前惯例，补回时把 `ScriptCallable` → `BlueprintCallable`，其余 `ScriptTrivial / ScriptNoDiscard / ScriptName / DeprecatedFunction / DeprecationMessage` 等保留：

```cpp
// 补回模板（Math 全局 / FVector / FRotator / FQuat / FTransform 子类）
UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
static FQuat ApplyDelta(const FQuat& OriginRotation, const FQuat& DeltaRotation);
```

实现体应直接照搬 Hazelight 上游 `AngelscriptCode/Private/FunctionLibraries/AngelscriptMathLibrary.cpp` 对应函数（P5.2 实施时一并取）。

### 2.2 `AngelscriptHitResultLibrary.h` — 缺 1 函数

| 函数 | Hazelight 完整声明 |
|---|---|
| `SetPhysMaterial` | （位于 `K:\UnrealEngine\UEAS\Engine\Plugins\Angelscript\Source\AngelscriptCode\Public\FunctionLibraries\AngelscriptHitResultLibrary.h`，P5.2 实施时取完整签名+实现）|

P5.2 补全要点：fork 该文件已启用 `UCLASS(Meta = (ScriptMixin = "FHitResult"))`，补回的 `SetPhysMaterial` 第一个参数应为 `const FHitResult&` 或 `FHitResult&`，会自动走 mixin 注入路径。

### 2.3 `GameplayTagContainerMixinLibrary.h` — 缺 1 函数

| 函数 | 备注 |
|---|---|
| `AppendTags` | fork 当前 `UCLASS(Meta = (ScriptMixin = "FGameplayTagContainer"))` 是注释关闭状态（见 §3 锚点表第 11 行），补回 `AppendTags` 同时由 Phase 4 P4.x 重启 ScriptMixin 时自动暴露为成员方法 |

### 2.4 `UAssetManagerMixinLibrary.h` — 缺 1 函数

| 函数 | 备注 |
|---|---|
| `ScanPathForPrimaryAssets` | fork 当前 ScriptMixin 锚点关闭（见 §3 第 16 行），补全策略同 §2.3 |

---

## 3. fork `//UCLASS(Meta = (ScriptMixin = "..."))` 锚点全景表

每条锚点对照 Hazelight 上游 active 状态，给出 P5.4 / P4.x 处置建议。

| # | fork 文件 | fork 锚点（注释行原文） | Haze 上游对应 | P5.4 处置 | P4.x 重启目标 |
|---|---|---|---|---|---|
| 1 | `AngelscriptHitResultLibrary.h` | **已启用** `UCLASS(Meta = (ScriptMixin = "FHitResult"))` | active ✓ | cleanup note 已删除 | ✅ P4.2 试点重启 |
| 2 | `AngelscriptMathLibrary.h` | ⛔ **保留禁用** `//UCLASS(Meta = (ScriptMixin = "FVector"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退 — fork 测试 `AngelscriptMathFunctionLibraryTests.cpp:412-424` 依赖 `AngelscriptFVectorMixin::xxx` namespace 静态形式 |
| 3 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FVector3f"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退（同上类型，`AngelscriptFVector3fMixin::xxx` 依赖）|
| 4 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FRotator", ScriptName = "FRotator"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退 — `AngelscriptMathOrientationFunctionLibraryTests.cpp:164/169/174/181` 依赖 `FRotator::GetForwardVector(rot)` 等 namespace 静态形式 |
| 5 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FRotator3f", ScriptName = "FRotator3f"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退（同上类型）|
| 6 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FQuat", ScriptName = "FQuat"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退 |
| 7 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FQuat4f", ScriptName = "FQuat4f"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退 |
| 8 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FTransform", ScriptName = "FTransform"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退 |
| 9 | `AngelscriptMathLibrary.h` | ⛔ 保留禁用 `//UCLASS(Meta = (ScriptMixin = "FTransform3f", ScriptName = "FTransform3f"))` | active ✓ | 锚点保留 | ⛔ P4.3 试启回退 |
| 10 | `AngelscriptWorldLibrary.h` | ~~`//UCLASS(Meta = (ScriptMixin = "UWorld"))`~~ → `UCLASS(Meta = (ScriptMixin = "UWorld"))` | active ✓ | **已重启**（P4.4 完成，cleanup parity note 已删除）| **原类 1，2026-04-28 已迁移**：`Bind_UWorld.cpp:79-82` 手工 lambda 删除 + ScriptMixin 启用，反射路径产物兼容 AS 端用法（2 个 WorldStreaming 测试 PASS）|
| 11 | `GameplayTagContainerMixinLibrary.h` | **已启用** `UCLASS(Meta = (ScriptMixin = "FGameplayTagContainer"))` | active ✓ | cleanup note 已删除 | ✅ P4.3 重启 |
| 12 | `GameplayTagMixinLibrary.h` | **已启用** `UCLASS(Meta = (ScriptMixin = "FGameplayTag"))` | active ✓ | cleanup note 已删除 | ✅ P4.3 重启 |
| 13 | `InputComponentScriptMixinLibrary.h` | **已启用** `UCLASS(Meta = (ScriptMixin = "UInputComponent"))` | active ✓ | cleanup note 已删除 | ✅ P4.3 重启（类 1.5，`Bind_InputComponentScriptMixins.cpp` UHT 重载消歧 helper 与 mixin 注入并存）|
| 14 | `InputComponentScriptMixinLibrary.h` | **已启用** `UCLASS(Meta = (ScriptMixin = "APlayerController"))` | active ✓ | cleanup note 已删除 | ✅ P4.3 重启 |
| 15 | `InputComponentScriptMixinLibrary.h` | **已启用** `UCLASS(Meta = (ScriptMixin = "UPlayerInput"))` | active ✓ | cleanup note 已删除 | ✅ P4.3 重启 |
| 16 | `UAssetManagerMixinLibrary.h` | **已启用** `UCLASS(MinimalAPI, Meta = (ScriptMixin = "UAssetManager"))` | active ✓ | cleanup note 已删除 | ✅ P4.3 重启 |

**结论**：16 处锚点 100% 是 parity gap。P4.x 实施结果：**8 处已重启 / 8 处保留禁用**。

- §3 锚点 #1（HitResult）/ #10（World）/ #11–#16（Tag / TagContainer / AssetMgr / Input × 3）—— 共 8 处已通过 P4.2 / P4.3 / P4.4 重启 ScriptMixin，cleanup parity note 同步删除。
- §3 锚点 #2–#9（MathLibrary 8 处）—— P4.3 试启检测到 namespace-regression 后保留禁用；锚点保留作为"未来 AS 脚本现代化迁移"的 TODO 标记。MathLibrary 文件头从未加过 cleanup note，P5.4 在 MathLibrary 上无工作量。

---

## 4. `AngelscriptActorLibrary.h` 专项（**Phase 2 已完成**）

### 4.1 P2.2 处置结果（2026-04-28）

采用选项 B'（混合方案）：保留 9 fork 独有签名 + 删 21 冗余 + 全部升级到 `UFUNCTION(BlueprintCallable, Meta = (...))`。

| 维度 | Hazelight 上游 | fork（P2.2 前）| fork（P2.2 后）|
|---|---|---|---|
| `UCLASS` 数 | 1 | 1 | 1 |
| `UFUNCTION` 数 | 29 | 30 | 9 |
| `UFUNCTION` 形态 | `UFUNCTION(ScriptCallable, Meta = (...))` | 裸 `UFUNCTION()` × 27 + 例外 3 | `UFUNCTION(BlueprintCallable, Meta = (...))` × 9 |
| 是否进入反射绑定 | ✓ | ✗ 全 dead | ✓ 全 active |
| 文件行数 | 220 | 169 | 81 |

### 4.2 P2.2 后保留的 9 个函数

| # | 函数 | Meta | 价值依据 |
|---|---|---|---|
| 1 | `SetActorRelativeRotationQuat` | `ScriptName="SetActorRelativeRotation", NotAngelscriptProperty` | UE native AActor 仅有 FRotator 版本 |
| 2 | `SetActorRotationQuat` | `ScriptName="SetActorRotation", NotAngelscriptProperty` | 同上 |
| 3 | `SetActorLocationAndRotationQuat` | `ScriptName="SetActorLocationAndRotation"` | 同上 |
| 4 | `SetActorQuat` | `ScriptTrivial` | 独立 ScriptName，trivial inline 优化 |
| 5 | `AddActorLocalRotationQuat` | `ScriptName="AddActorLocalRotation", NotAngelscriptProperty` | UE native 仅有 FRotator 版本 |
| 6 | `AddActorWorldRotationQuat` | `ScriptName="AddActorWorldRotation"` | 同上 |
| 7 | `SetActorLocationAdvanced` | `ScriptName="SetActorLocation", NotAngelscriptProperty` | 带 `bSweep + FHitResult& + bTeleport` 签名（fork 独有，Hazelight 上游也无）|
| 8 | `SetbRunConstructionScriptOnDrag` | (无) | EDITOR-only 字段写入接口 |
| 9 | `RerunConstructionScripts` | (无) | EDITOR-only utility |

### 4.3 P2.2 后删除的 21 个函数

`SetActorRelativeLocation` / `GetActorRelativeLocation` / `SetActorRelativeRotation`(FRotator) / `GetActorRelativeRotation` / `SetActorRelativeTransform` / `GetActorRelativeTransform` / `SetActorLocation` / `GetActorLocation` / `SetActorRotation`(FRotator) / `GetActorRotation` / `SetActorLocationAndRotation`(FRotator) / `SetActorTransform` / `GetActorQuat` / `AddActorLocalOffset` / `AddActorLocalRotation`(FRotator) / `AddActorLocalTransform` / `AddActorWorldOffset` / `AddActorWorldRotation`(FRotator) / `AddActorWorldTransform` / `AttachToComponent` / `AttachToActor`

均与 UE native AActor 同名 BlueprintCallable/BlueprintPure 等价，AS 脚本调用通过 UE native 反射路径正常 work，删除零行为变化。

### 4.4 fork 与 Hazelight 仍存差异（待 P5.2 处理）

| 方向 | 函数 | 备注 |
|---|---|---|
| fork 多 | `SetActorLocationAdvanced` | Hazelight 上游无对应签名，fork 独有的 sweep+hit+teleport 完整 K2 签名包装。**保留** |
| Hazelight 多 | `GetAttachedActors(bRecursive=false)` | 返回 `TArray<AActor*>` 而非 OutActors 引用参数；`Meta = (ScriptTrivial, NotAngelscriptProperty)`。**P5.2 待补** |
| Hazelight 多 | `GetAttachedActorsOfClass(TSubclassOf<AActor>, bRecursive)` | 按 class 过滤的版本；`Meta = (ScriptTrivial, DeterminesOutputType="ActorClass", NotAngelscriptProperty)`。**P5.2 待补** |

P5.1 矩阵高层数据从 30/30 函数 parity 修正为 29/9 → P2.2 后差额 = `Hazelight 29 - fork 9 + Hazelight 多 2 - fork 多 1 = 22 净差` 但实际只有 2 个真"缺漏"；其余 20 个差额是"我们主动删除的 UE native 已覆盖冗余"，不是 parity gap。

---

## 5. P5.x 执行映射

| Phase 任务 | 本矩阵驱动数据 | 执行规模 |
|---|---|---|
| P5.2（补 helper 函数） | §2.1.3 (16 函数) + §2.2 / §2.3 / §2.4 (各 1 函数) | 19 个函数，分散在 4 个文件，建议 4 个 commit（按文件） |
| P5.3（补 mixin 子类） | §2.1.1 (3 Static 子类) | 3 个新 UCLASS，全部在 MathLibrary，1 个 commit |
| P5.4（注释清理） | §3 锚点全景表 | **0 删除**，仅在 P4.1 完成后修整 6 处 cleanup note 描述准确性 |

P5.x 与其他 Phase 的协同：

- **P5.2 与 P3.1 / P3.2 合并**：补回函数时同时携带 Hazelight 完整 Meta（含 `ScriptTrivial / NotAngelscriptProperty / ScriptName 重载`），避免对同一函数改两次。
- **P5.3 直接以 enabled 状态合入**，不进 Phase 4 P4.2 / P4.3 的"重启锚点"流程。
- **P5.4 等 P4.1 完成后做**，避免 cleanup note 描述与 P4.1 三类分类不一致。

---

## 6. 数据采集命令记录

```powershell
# 高层数据
$haze = "K:\UnrealEngine\UEAS\Engine\Plugins\Angelscript\Source\AngelscriptCode\Public\FunctionLibraries"
$ours = "Plugins\Angelscript\Source\AngelscriptRuntime\FunctionLibraries"
Get-ChildItem $haze -Filter "*.h" | ForEach-Object {
    $h = $_.FullName; $o = Join-Path $ours $_.Name
    $hf = (Select-String -Path $h -Pattern "^\s*UFUNCTION" | Measure-Object).Count
    $of = (Select-String -Path $o -Pattern "^\s*UFUNCTION" | Measure-Object).Count
    "$($_.Name): Haze=$hf Fork=$of Diff=$($hf - $of)"
}

# 函数级 diff（以 MathLibrary 为例）
function Get-FuncNames($p) {
    $c = Get-Content $p -Raw
    [regex]::Matches($c, '(?m)^\s*UFUNCTION\([^)]*\)[^\r\n]*\r?\n\s*static\s+\S+(?:\s*[\*&])?\s+(\w+)\s*\(') |
        ForEach-Object { $_.Groups[1].Value }
}
$h = Get-FuncNames "$haze\AngelscriptMathLibrary.h"
$o = Get-FuncNames "$ours\AngelscriptMathLibrary.h"
Compare-Object $h $o | Group-Object SideIndicator, InputObject

# 缺漏函数完整签名抽取
foreach ($n in @("ApplyDelta","GetSafeNormal2D",...)) {
    Select-String -Path "$haze\AngelscriptMathLibrary.h" -Pattern "static\s+\S+\s+$n\s*\(" -Context 1,0
}

# fork 锚点全景
Get-ChildItem $ours -Filter *.h | ForEach-Object {
    Select-String -Path $_.FullName -Pattern "^//UCLASS"
}
```

后续如需复现矩阵，按以上命令即可重生。
