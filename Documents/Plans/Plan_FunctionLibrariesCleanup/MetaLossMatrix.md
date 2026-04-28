# Fork Meta Loss Matrix（fork 内 active 行 vs 清理前死注释）

> 本矩阵是 `Plan_FunctionLibrariesCleanup.md` Phase 1 的 P1.1 产出，作为 P3.1 / P3.2 实施的精确输入。
>
> 数据采集时点：基线提交 `cc764db^`（清理前死注释完整状态）vs `HEAD`（清理后 + 当前 active 行）。15 个文件，270+ 行死注释。
>
> **2026-04-28 P3.2 实施时发现初版公式 bug**：原"`dead_count - active_count`"算法统计的是 meta 字符串在死注释/active 行中的**出现次数差**，不是按函数配对的真正损失数（dead 注释总数远大于 active 函数总数本身就是文件级噪声）。**重新按函数配对后真实损失大幅缩小**——具体见下方"实际真损失（按函数配对）"章节，原"§1 文件级 meta 损失统计"表格保留作历史叙事。

## 实际真损失（按函数配对，2026-04-28 重测）

| meta 类型 | 原估算 | 真实损失 | 真实位置 | 处理状态 |
|---|---:|---:|---|---|
| `ScriptTrivial` | 94 | **4** | MathLibrary 2 (`SinCos_32` / `SinCos_64`) + ComponentLibrary 2 (`IsAttachedTo_Actor` / `GetShapeCenter`) | ✅ P3.2 完成 |
| `ScriptNoDiscard` | 35 | **0** | 无（所有死注释带 ScriptNoDiscard 的函数 active 行都已携带）| ✅ 无需处理 |
| `ScriptName 重载` | 4 | **4** | ActorLibrary 4 处（FQuat 重载别名）| ✅ P2.2 完成 |
| `NotAngelscriptProperty` | 7 | **7** | ActorLibrary 4 + ComponentLibrary 2 + ScriptLibrary 3 | ✅ P2.2 + P3.1 完成 |
| **合计** | **140** | **15** | 4 个文件 | **15/15 全部恢复** |

公式修正算法（按函数配对的真损失检测）：

```powershell
function Get-RealMetaLoss($file, $metaName) {
    $diff = git show cc764db -- $file
    $lines = $diff -split "`n"
    $hits = 0
    for ($i = 0; $i -lt $lines.Length - 1; $i++) {
        # 必须 dead 注释行带 metaName + 紧跟 active 行不带 metaName
        if ($lines[$i] -match "^-\s*//UFUNCTION\(ScriptCallable.*$metaName") {
            $next = $lines[$i+1]
            if ($next -match "^\s\s*UFUNCTION\(BlueprintCallable" -and $next -notmatch $metaName) {
                $hits++
            }
        }
    }
    return $hits
}
```

## 三个汇总数（原版，保留作历史叙事）

| 汇总维度 | 原估算 | 真实数据 | 落点 |
|---|---:|---:|---|
| ① 真实 meta 损失总数 | 130 → 119 | **15**（P3.2 修正） | 全部已完成 |
| ② 涉及损失的文件数 | 4 | **4** | Phase 3 实施范围 |
| ③ 涉及损失的 meta 类型 | 4 | **3 类**（`ScriptNoDiscard` 实际无损失）| Phase 3 操作类型映射 |

原详细分布（含 false positive 估算）：

- `ScriptTrivial`：~~94 处~~ → **真实 4 处** ✅ P3.2 完成
- `ScriptNoDiscard`：~~35 处~~ → **真实 0 处**（虚假估算）
- `ScriptName 重载`：4 处 ✅ P2.2 完成
- `NotAngelscriptProperty`：7 处 ✅ P2.2 + P3.1 完成

## 1. 文件级 meta 损失统计

`+N` 表示死注释携带但 active 行缺失（**真实损失**）；`-N` 表示 active 行携带而死注释没有（fork 改造时**主动新增**，不算损失）；`0` 表示 active 已 100% 保留。

| 文件 | 死注释总数 | `ScriptTrivial` | `NotAngelscriptProperty` | `ScriptName 重载` | `ScriptNoDiscard` | `ScriptGlobalScope` | `ScriptAllowDiscard` | `DeprecatedFunction` |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `AngelscriptActorLibrary.h` | 27 | **+5** | **+2** | **+4** | 0 | 0 | 0 | 0 |
| `AngelscriptComponentLibrary.h` | 35 | **+11** | **+2** | 0 | 0 | 0 | 0 | 0 |
| `AngelscriptHitResultLibrary.h` | 0 | -11 | 0 | 0 | 0 | 0 | 0 | -1 |
| `AngelscriptMathLibrary.h` | 88 | **+78** | +1 | -6 | **+35** | 0 | 0 | +1 |
| `AngelscriptScriptLibrary.h` | 3 | 0 | **+3** | -1 | 0 | 0 | 0 | 0 |
| `AngelscriptWorldLibrary.h` | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `GameplayLibrary.h` | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `GameplayTagContainerMixinLibrary.h` | 20 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `GameplayTagMixinLibrary.h` | 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `GameplayTagQueryMixinLibrary.h` | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `InputComponentScriptMixinLibrary.h` | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `RuntimeFloatCurveMixinLibrary.h` | 27 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `SubsystemLibrary.h` | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `UAssetManagerMixinLibrary.h` | 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `WidgetBlueprintStatics.h` | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **合计真实损失** | 254 | **+94** | **+7** | **+4** | **+35** | 0 | 0 | 0 |

**关键观察**：

1. **真实 meta 损失只集中在 4 个文件**（Math / Component / Actor / Script），其余 11 个文件死注释里携带的 meta 在 active 行已 100% 保留，死注释纯属可视噪音 → cc764db 清理对这 11 个文件是**纯收益**。
2. **MathLibrary 是损失重灾区**：113 处（ScriptTrivial 78 + ScriptNoDiscard 35），占总损失 87%。
3. **HitResultLibrary 死注释为 0**：之前 cc764db 里它只有 1 处 `Meta = ()` 空占位被清，没有真正的死注释；同时 active 行 `ScriptTrivial=11 / DeprecatedFunction=1` 是改造时**新增**，无损失。
4. **MathLibrary 的 6 处 ScriptName 是改造时新增**（active=43 / dead=37），不是损失；ScriptLibrary 的 1 处 ScriptName 同理。

---

## 2. 文件级精细列表（仅 4 个有损失文件）

每条列出"应该恢复但 active 缺失"的具体证据：从 `git show cc764db -- <file>` 的 `-` 行抽取，对应的 `+` 行（如有）作为 active 现状。

### 2.1 `AngelscriptActorLibrary.h`（11 处损失，且整文件是 dead code 嫌疑——见 Phase 2）

| 函数 | 死注释 Meta（应有）| active Meta（现状）| 缺失 |
|---|---|---|---|
| `SetActorRelativeRotationQuat` | `ScriptCallable, Meta = (ScriptName = "SetActorRelativeRotation", NotAngelscriptProperty)` | `UFUNCTION()` | `ScriptName 重载 + NotAngelscriptProperty` |
| `AddActorLocalRotationQuat` | `ScriptCallable, Meta = (ScriptName = "AddActorLocalRotation", NotAngelscriptProperty)` | `UFUNCTION()` | 同上 |
| `AddActorWorldRotationQuat` | `ScriptCallable, Meta = (ScriptName = "AddActorWorldRotation", NotAngelscriptProperty)` | `UFUNCTION()` | 同上 |
| `SetActorRotationQuat` | `ScriptCallable, Meta = (ScriptName = "SetActorRotation", NotAngelscriptProperty)` | `UFUNCTION()` | 同上 |
| (5 处带 `ScriptTrivial`) | `ScriptCallable, Meta = (ScriptTrivial)` | `UFUNCTION()` | `ScriptTrivial` |

**注**：Phase 2 决策若选 P2.2 选项 A（整删），本节自动归零；若选 B/C，本节是补全模板。具体每条的 fork 函数名、参数列表，以 `git show cc764db^:Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptActorLibrary.h` 为准。

### 2.2 `AngelscriptComponentLibrary.h`（13 处损失，ScriptMixin 已启用）

`ScriptTrivial` 11 处 + `NotAngelscriptProperty` 2 处。前者多分布在 `Get*` / `Set*` 简单 getter/setter；后者在 Quat 重载（`SetRelativeRotationQuat / AddLocalRotationQuat` 等）：

| 函数（典型样本）| 死注释 | active | 缺失 |
|---|---|---|---|
| `SetRelativeRotationQuat` | `ScriptCallable, Meta = (ScriptName = "SetRelativeRotation", NotAngelscriptProperty)` | `BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation")` | `NotAngelscriptProperty` |
| `AddLocalRotationQuat` | 同模式 | 同 | `NotAngelscriptProperty` |
| 11 处 `Get*` / `Set*` getter | `ScriptCallable, Meta = (ScriptTrivial)` | `BlueprintCallable, Meta = ()` | `ScriptTrivial` |

完整清单从 `git show cc764db -- Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptComponentLibrary.h` 的 `-` 行直接抽取。

### 2.3 `AngelscriptMathLibrary.h`（113 处损失，最大重灾区）

| 损失类型 | 处数 | 子类分布 |
|---|---:|---|
| `ScriptTrivial` | 78 | 跨 Math 全局 + 8 个 mixin 子类（FVector / FRotator / FQuat / FTransform / 及其 3f 变体）|
| `ScriptNoDiscard` | 35 | 集中在 transform 操作类函数（返回值不应丢弃，如 Lerp / Slerp / Inverse）|

**典型 ScriptTrivial 损失样本**（每条都有相同模式）：

```cpp
// 死注释（应有）
//UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptName = "SinCos"))
// active（现状）
UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SinCos"))
```

**典型 ScriptNoDiscard 损失样本**：

```cpp
// 死注释（应有）
//UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
// active（现状）
UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial))
```

P3.2 实施时建议用 sed 等脚本式批量替换："Meta = (X)" → "Meta = (ScriptTrivial, X)"（按死注释驱动），但每条变更要在 commit body 列出具体 active 行号。

### 2.4 `AngelscriptScriptLibrary.h`（3 处损失，ScriptMixin 已启用）

| 函数 | 死注释 | active | 缺失 |
|---|---|---|---|
| 3 处 `*Script*` helper | `ScriptCallable, Meta = (NotAngelscriptProperty)` | `BlueprintCallable, Meta = ()` | `NotAngelscriptProperty` |

具体函数名 / 参数列表从 `git show cc764db -- Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptScriptLibrary.h` 抽取。

---

## 3. P1.1 与 P5.1 矩阵的交叉验证

P1.1（fork 内对比）与 P5.1（fork vs Hazelight）应该相互印证：fork 死注释里携带的 meta = Hazelight 上游 active 行的 meta。如果两者 diff 不一致，说明：

- 要么 fork 死注释承载的是 Hazelight **更早期**版本的 meta，Hazelight 上游已经更新（→ Phase 3 应以 P5.1 矩阵为最终来源）
- 要么 fork 死注释里有 Hazelight 从未存在过的"中间状态" meta（→ 直接丢弃，不做恢复）

抽样验证（MathLibrary 的 SinCos）：

| 来源 | Meta 内容 |
|---|---|
| fork 死注释 | `ScriptCallable, Meta = (ScriptTrivial, ScriptName = "SinCos")` |
| Hazelight 上游 | （由 P5.2 实施时取，预期一致）|
| fork active 现状 | `BlueprintCallable, Meta = (ScriptName = "SinCos")` |
| 损失 | `ScriptTrivial` |

预期 P1.1 与 P5.1 在 4 个有损失的文件上数据完全吻合；如有不一致，以 P5.1 为准（Hazelight 是 source of truth）。

---

## 4. P3.x 执行映射

| Phase 任务 | 本矩阵驱动数据 | 执行规模 |
|---|---|---|
| P3.1（恢复 `ScriptName 重载` + `NotAngelscriptProperty`）| §2.1（Actor 4+2）+ §2.2（Component 2）+ §2.4（Script 3）| 11 处，分散在 3 个文件，建议合并到 1 个 commit |
| P3.2（恢复 `ScriptTrivial`）| §2.1（Actor 5）+ §2.2（Component 11）+ §2.3（Math 78）| 94 处，分散在 3 个文件，建议**按文件分 3 个 commit**便于回滚 |
| P3.3（新增）恢复 `ScriptNoDiscard` | §2.3（Math 35）| 35 处全在 Math，1 个 commit |

P3.x 与 P5.2 的协同：

- 如果 P5.2 先执行（按 Hazelight 上游补 16 个缺漏函数），新补的函数可直接携带完整 Meta，P3.x 不再需要处理这些函数
- 如果 P3.x 先执行，新加 meta 的 ScriptTrivial / ScriptNoDiscard 会与 P5.2 补回函数的 meta 一致，无冲突
- **建议执行顺序**：先 P5.2（补函数），再 P3.x（补现有函数 meta）—— 这样 P3.x 矩阵会自动对齐 Hazelight 上游

---

## 5. 验证方法

每条 meta 恢复后的预期落点（参考 `Helper_FunctionSignature.h:316-317`）：

| Meta | 触发的字段 | `ModifyScriptFunction` 行为 |
|---|---|---|
| `ScriptTrivial` | `bTrivial = true` | 落到 `FAngelscriptMethodBind::bTrivial`，参与 StaticJIT inline 决策 |
| `NotAngelscriptProperty` | `bNotAngelscriptProperty = true` | `ScriptFunction->SetProperty(false)` 抑制 angelscript property 自动识别 |
| `ScriptName` | `ScriptName = "..."` | 替换默认 `Function->GetName()` 作为 AS 暴露名 |
| `ScriptNoDiscard` | Declaration 追加 ` no_discard` 后缀 | AS 编译器对返回值未使用的调用报警 |

P3.x 实施后，跑 `as.DumpEngineState` 导 `BindDatabase.csv`，按文件抽样 30 处验证 `bTrivial / bNotAngelscriptProperty` 列已变为 true。

---

## 6. 数据采集命令记录

```powershell
# 死注释总量与按 meta 类型分布（per-file）
$ours = "Plugins\Angelscript\Source\AngelscriptRuntime\FunctionLibraries"
$files = git diff --name-only cc764db^ cc764db -- "$ours/"
$metaKeys = @("ScriptTrivial","NotAngelscriptProperty","ScriptName","ScriptNoDiscard","ScriptGlobalScope","ScriptAllowDiscard","DeprecatedFunction")
foreach ($f in $files) {
    $diff = git show cc764db -- $f
    $dead = $diff | Select-String -Pattern "^-\s*//UFUNCTION\(ScriptCallable" | ForEach-Object { $_.Line }
    $active = Get-Content "$ours\$(Split-Path $f -Leaf)"
    foreach ($k in $metaKeys) {
        $dc = ($dead | Select-String -Pattern $k | Measure-Object).Count
        $ac = ($active | Select-String -Pattern $k | Where-Object { $_.Line -notmatch "^\s*//" } | Measure-Object).Count
        # diff = $dc - $ac，正值 = 损失
    }
}

# 单文件具体死注释抽取（以 MathLibrary 为例）
git show cc764db -- Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h |
    Select-String -Pattern "^-\s*//UFUNCTION\(ScriptCallable"

# 跟随死注释的 active 行抽取（用于 P3.x 实施时定位）
git show cc764db^ -- <path> | Select-String -Pattern "//UFUNCTION\(ScriptCallable" -Context 0,1
```
