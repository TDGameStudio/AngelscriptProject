# Detached Class 积极清理优化

## 背景与目标

### 现状

当测试套件在单进程中运行 793 个测试时，每次 SHARE_FRESH 测试创建/销毁 Full 引擎都会产生 detached UASClass/UASFunction 对象（重命名为 `_REPLACED_N`）。这些对象不再持有脚本引擎引用（`ScriptTypePtr == nullptr`），但仍作为 UObject 残留在堆中，仅靠 `CollectGarbage(RF_NoFlags, true)` 回收。

实测数据（793 测试全量运行）：
- 测试 #177 时已累积 93 个 DetachedASClasses、154 个 DetachedASFunctions
- 进程工作集从启动时 ~3GB 膨胀到 16GB
- `ResetSharedCloneEngine()` 末尾的 `CollectGarbage(RF_NoFlags, true)` 在 9.5GB 堆上曾导致 `IsolatedModuleRegistries` 测试挂死 10+ 分钟
- UE 关闭阶段的 `Compacting FUObjectHashTables` 需要数分钟才能完成

### 根因链路

```
ClassGenerator 创建新类 → 旧类 Rename 为 _REPLACED_N
→ ScriptTypePtr 置 nullptr, RemoveFromRoot, ClearFlags(RF_Standalone)
→ 对象变为 unreachable 但仍留在 UObject 堆和哈希表中
→ 仅在 CollectGarbage(full purge) 时才真正回收
→ 随测试数增加，堆持续膨胀，GC 开销非线性增长
```

### 目标

1. 将 detached class/function 的清理从"全量 GC 被动回收"改为"引擎销毁后主动定向回收"
2. 控制单进程全量测试运行中的工作集增长，使其不再随测试数线性膨胀
3. 保持 `ResetSharedCloneEngine()` 的正确性和与 UE GC 系统的兼容性
4. 不改变运行时生产代码的行为（优化范围限定在测试基础设施和引擎清理路径）

## 当前事实状态快照

### detached 对象产生位置

`AngelscriptClassGenerator.cpp`:
- **Class**: `FindObject<UASClass>` → `Rename(*OldClassName_REPLACED_N)` → `CLASS_NewerVersionExists`（~L2696）
- **Struct**: `FindObject<UASStruct>` → `Rename(*OldClassName_REPLACED_N)`（~L2746）
- **DelegateFunction**: `FindObject<UDelegateFunction>` → `Rename(*OldFunctionName_REPLACED_N)`（~L2800）

### detached 对象解除引用位置

`AngelscriptClassGenerator.cpp` `CleanupRemovedClass()`（~L5004）:
- `ScriptTypePtr = nullptr` / `ScriptType = nullptr`
- `RemoveFromRoot()`
- `ClearFlags(RF_Standalone)`

同文件 reload 路径（~L2526）:
- `ReplacedClass->ScriptTypePtr = nullptr`
- `ReplacedClass->OwnerScriptEngine = nullptr`

### 当前测试侧清理

`AngelscriptTestUtilities.h` `ResetSharedCloneEngine()`（~L219）:
1. 丢弃所有活跃 AS 模块
2. 删除 AS 引擎中的已丢弃模块
3. 遍历 `TObjectIterator<UASClass>` 对 `ScriptTypePtr == nullptr` 的对象做 `RemoveFromRoot` + `ClearFlags(RF_Standalone)`
4. `CollectGarbage(RF_NoFlags, true)` ← 瓶颈

### 关键文件清单

| 文件 | 角色 |
|------|------|
| `AngelscriptClassGenerator.cpp` | 产生 detached 对象（rename + nullify） |
| `AngelscriptTestUtilities.h` | 测试侧清理（ResetSharedCloneEngine） |
| `AngelscriptEngine.cpp` | 引擎生命周期（Create/Destroy） |
| `ASClass.h` | `UASClass` 定义（ScriptTypePtr 等成员） |

## 分阶段执行计划

### Phase 1：度量基线与诊断工具

> 在优化前建立可量化的度量基线，让后续每个优化步骤都有 before/after 对照。

- [ ] **P1.1** 在 `ResetSharedCloneEngine()` 中添加 GC 耗时度量
  - 在 `CollectGarbage` 调用前后用 `FPlatformTime::Seconds()` 计时
  - 输出 `[TestEngine] GC took {N}ms, detached classes={M}, WS={K}MB` 到 `Angelscript` 日志
  - 仅在 `Verbose` 级别输出，不影响正常测试
- [ ] **P1.1** 📦 Git 提交：`[Test] Chore: add GC duration and detached object metrics to ResetSharedCloneEngine`

- [ ] **P1.2** 在 `LogSharedEngineDebugState()` 中增加 `UASFunction` 和 `UASStruct` 的 detached 计数
  - 当前仅统计 `UASClass` 和 `UASFunction`，缺少 `UASStruct` 和 `UDelegateFunction`
  - 补全四类对象的 detached 计数，为后续针对性清理提供依据
- [ ] **P1.2** 📦 Git 提交：`[Test] Chore: extend detached object diagnostics to cover UASStruct and UDelegateFunction`

- [ ] **P1.3** 收集全量测试运行的度量基线
  - 运行 793 测试，记录：每 100 个测试间隔的 detached 对象数、GC 耗时、进程工作集
  - 记录为 `Documents/Plans/Plan_DetachedClassEagerCleanup/Baseline.md`

### Phase 2：定向对象销毁替代全量 GC

> 核心优化：将 `CollectGarbage(RF_NoFlags, true)` 替换为对已知 detached 对象的定向 `MarkAsGarbage()` + 增量 GC。

- [ ] **P2.1** 实现 `PurgeDetachedAngelscriptObjects()` 辅助函数
  - 遍历 `TObjectIterator<UASClass>`、`TObjectIterator<UASStruct>`、`TObjectIterator<UASFunction>`、`TObjectIterator<UDelegateFunction>` 四类
  - 对 `ScriptTypePtr == nullptr`（或 `ScriptType == nullptr` / `ScriptFunction == nullptr`）的对象：
    - `RemoveFromRoot()`（如果仍 rooted）
    - `ClearFlags(RF_Standalone)`
    - `MarkAsGarbage()`（标记为可立即回收，UE 5.x 支持）
  - 统计并返回被标记的对象数
  - 放置于 `AngelscriptTestUtilities.h`，仅测试模块可见
- [ ] **P2.1** 📦 Git 提交：`[Test] Feat: add PurgeDetachedAngelscriptObjects for targeted object cleanup`

- [ ] **P2.2** 在 `ResetSharedCloneEngine()` 中用定向清理替代全量 GC
  - 将末尾的 `CollectGarbage(RF_NoFlags, true)` 替换为：
    1. 调用 `PurgeDetachedAngelscriptObjects()` 标记所有 detached 对象
    2. 调用 `CollectGarbage(RF_NoFlags, false)`（增量 GC，非 full purge）
  - `false` 参数使 GC 只做一轮增量回收而非完整 mark-sweep，大幅降低耗时
  - 验证：对比 Phase 1 基线，确认 detached 对象数在 reset 后归零或大幅减少
- [ ] **P2.2** 📦 Git 提交：`[Test] Fix: replace full GC purge with targeted detached object cleanup in ResetSharedCloneEngine`

- [ ] **P2.3** 验证全量测试仍然全部通过
  - 运行 793 测试全量套件
  - 确认：0 failures、无新增 warnings、无 crash
  - 对比 Phase 1 基线记录 GC 耗时和工作集变化
- [ ] **P2.3** 📦 Git 提交（如有修正）

### Phase 3：引擎销毁路径的清理增强

> 将清理能力从测试工具层下沉到引擎生命周期层，使任何销毁路径都能高效回收 detached 对象。

- [ ] **P3.1** 在 `FAngelscriptEngine` 析构器中添加 detached 对象标记
  - 当 `bOwnsEngine == true` 且引擎正在销毁时，遍历 `AngelscriptPackage` 内所有 `UASClass`/`UASStruct` 子对象
  - 对 `ScriptTypePtr == nullptr` 的对象调用 `MarkAsGarbage()`
  - 这使得即使不调用 `PurgeDetachedAngelscriptObjects()`，引擎销毁后的下一次 UE 自然 GC 也能快速回收
  - 注意：不在析构器中调用 `CollectGarbage()`，仅做标记
- [ ] **P3.1** 📦 Git 提交：`[Runtime] Feat: mark detached script objects as garbage during engine teardown`

- [ ] **P3.2** 评估 `ClassGenerator::CleanupRemovedClass()` 中直接调用 `MarkAsGarbage()` 的可行性
  - 当前 `CleanupRemovedClass()` 已经做了 `RemoveFromRoot` + `ClearFlags(RF_Standalone)`
  - 评估在此处增加 `MarkAsGarbage()` 是否安全（考虑 hot reload 场景中旧类可能仍被蓝图引用）
  - 如果安全，则在 reload 完成后的 finalize 阶段统一标记
  - 如果不安全，记录原因并标记为"仅测试路径可做"
- [ ] **P3.2** 📦 Git 提交（如可行）：`[Runtime] Feat: mark replaced classes as garbage after reload finalization`

### Phase 4：度量验证与文档更新

- [ ] **P4.1** 运行优化后的全量测试并收集最终度量
  - 记录：detached 对象峰值数、GC 单次最大耗时、进程工作集峰值
  - 与 Phase 1 基线对比，确认改善幅度
  - 更新 `Documents/Plans/Plan_DetachedClassEagerCleanup/Baseline.md` 追加 after 数据
- [ ] **P4.1** 📦 Git 提交：`[Docs] Chore: record detached class cleanup optimization results`

- [ ] **P4.2** 更新相关文档
  - 更新 `Documents/Guides/TechnicalDebtInventory.md` 移除或标注已解决的 GC 性能条目
  - 更新 `Plan_OpportunityIndex.md` 追加本 Plan 条目到测试增强章节
  - 更新 `AGENTS.md` / `AGENTS_ZH.md` 如果涉及基线数字变更
- [ ] **P4.2** 📦 Git 提交：`[Docs] Chore: update technical debt and opportunity index after detached cleanup optimization`

## 验收标准

1. 全量 793 测试在单进程中全部通过（0 failures）
2. 单次 `ResetSharedCloneEngine()` 中的 GC 耗时从秒级降至毫秒级（目标 <50ms）
3. 全量测试运行的进程工作集峰值相比基线下降显著（目标降低 30%+）
4. detached 对象在每次引擎 reset 后归零或接近归零，不再跨测试累积
5. 不引入新的测试失败或运行时行为变化

## 风险与注意事项

### 风险

1. **`MarkAsGarbage()` 与蓝图引用的兼容性**：被标记为 garbage 的 UASClass 如果仍被蓝图 CDO 或 UProperty 引用，可能导致悬空指针
   - **缓解**：Phase 2 仅在测试工具层使用，此时已确认 `ScriptTypePtr == nullptr` 且已 `RemoveFromRoot`；Phase 3 需要额外验证蓝图引用图
2. **增量 GC 回收不完全**：`CollectGarbage(RF_NoFlags, false)` 可能不会在一次调用中回收所有已标记对象
   - **缓解**：`MarkAsGarbage()` 确保对象在下一次 GC 无论增量/全量都会被回收；如果增量不够可尝试 `IncrementalPurgeGarbage(true)` 强制一轮完整增量
3. **非测试路径的副作用**：Phase 3 改动触及运行时代码，需确保生产环境中 hot reload 不受影响
   - **缓解**：仅在 `bOwnsEngine == true` 的 Full 引擎析构路径中做标记；Clone 引擎不触发

### 已知行为变化

1. **GC 时机提前**：优化后 detached 对象不再等到关闭阶段才回收，而是在引擎 reset 时立即回收。这是期望的行为变化。
2. **`TObjectIterator` 遍历开销**：`PurgeDetachedAngelscriptObjects()` 需要遍历所有 UASClass/UASStruct/UASFunction/UDelegateFunction 实例。在对象数较少时（优化生效后），这个遍历本身是轻量的。
