# AngelScript 定时器和异步系统全覆盖矩阵

> 本文覆盖 AngelScript 中 **定时器和异步执行**的所有用法。
> 包括 Timer、Latent Actions、延迟执行、循环任务等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 定时器基础 | `AngelscriptTest/Coverage/AngelscriptCoverageTimerTests.cpp` | ⬜ 计划 |
| Latent Actions | `AngelscriptTest/Coverage/AngelscriptCoverageLatentTests.cpp` | ⬜ 计划 |
| 协程和延迟 | `AngelscriptTest/Coverage/AngelscriptCoverageCoroutineTests.cpp` | ⬜ 计划 |

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：FTimerHandle 和 FTimerManager

### 1.1 定时器基础

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 设置定时器 | `SetTimer(Handle, Function, Time, Loop)` | ⬜ | |
| 设置定时器（Lambda） | `SetTimer(Handle, [](){...}, Time, Loop)` | ⬜ | |
| 清除定时器 | `ClearTimer(Handle)` | ⬜ | |
| 暂停定时器 | `PauseTimer(Handle)` | ⬜ | |
| 恢复定时器 | `UnPauseTimer(Handle)` | ⬜ | |
| 检查激活 | `IsTimerActive(Handle)` | ⬜ | |
| 检查暂停 | `IsTimerPaused(Handle)` | ⬜ | |
| 获取剩余时间 | `GetTimerRemaining(Handle)` | ⬜ | |
| 获取已用时间 | `GetTimerElapsed(Handle)` | ⬜ | |

### 1.2 定时器参数

| 参数 | 类型 | 状态 | 说明 |
|------|------|------|------|
| Handle | FTimerHandle | ⬜ | 定时器句柄 |
| Function | 函数名/Lambda | ⬜ | 回调函数 |
| Time | float | ⬜ | 延迟时间（秒） |
| Loop | bool | ⬜ | 是否循环 |
| FirstDelay | float | ⬜ | 首次延迟 |

### 1.3 定时器模式

| 模式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 单次延迟执行 | `SetTimer(H, F, 1.0f, false)` | ⬜ | 1 秒后执行一次 |
| 循环执行 | `SetTimer(H, F, 0.5f, true)` | ⬜ | 每 0.5 秒执行 |
| 立即执行一次 | `SetTimer(H, F, 0.0f, false)` | ⬜ | 下一帧执行 |
| 首次延迟+循环 | `SetTimer(H, F, 1.0f, true, 2.0f)` | ⬜ | 2 秒后首次，然后每 1 秒 |

### 1.4 定时器作用域

| 作用域 | 获取方式 | 状态 | 说明 |
|-------|---------|------|------|
| Actor 定时器 | `GetWorldTimerManager()` | ⬜ | Actor 方法 |
| World 定时器 | `GetWorld()->GetTimerManager()` | ⬜ | 全局访问 |
| Component 定时器 | 组件内使用 | ⬜ | |

---

## 子矩阵 2：延迟执行

### 2.1 Delay 节点

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| System::Delay | `System::Delay(Seconds)` | ⬜ | 协程式延迟 |
| SetTimerByFunctionName | 字符串函数名 | ⬜ | 动态调用 |

### 2.2 NextTick

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 下一帧执行 | `SetTimer(H, F, 0.0f, false)` | ⬜ | |
| 延迟到帧末 | （无直接 API） | 🚫 | |

---

## 子矩阵 3：Latent Actions

### 3.1 常见 Latent 函数

| 函数 | 状态 | 说明 |
|------|------|------|
| `Delay(float)` | ⬜ | 延迟 N 秒 |
| `MoveComponentTo` | ⬜ | 移动组件到目标 |
| `RotatorTo` | ⬜ | 旋转到目标 |

### 3.2 Latent 特性

| 特性 | 状态 | 说明 |
|------|------|------|
| 协程式语法 | ⬜ | 看起来像同步代码 |
| 跨帧执行 | ⬜ | 不阻塞主线程 |
| 自动清理 | ⬜ | Actor 销毁时取消 |

---

## 子矩阵 4：定时器使用场景

### 4.1 游戏逻辑

| 场景 | 状态 | 示例 |
|------|------|------|
| 技能冷却 | ⬜ | 技能使用后 N 秒才能再用 |
| 周期性检查 | ⬜ | 每秒检查一次生命值 |
| 延迟生成 | ⬜ | 3 秒后生成敌人 |
| 自动保存 | ⬜ | 每 5 分钟自动保存 |
| Buff 持续时间 | ⬜ | Buff 10 秒后消失 |
| 重生计时 | ⬜ | 死亡 5 秒后重生 |

### 4.2 UI 动画

| 场景 | 状态 | 示例 |
|------|------|------|
| 淡入淡出 | ⬜ | 渐变透明度 |
| 提示消息 | ⬜ | 3 秒后自动关闭 |
| 倒计时 | ⬜ | 显示剩余时间 |

### 4.3 AI 行为

| 场景 | 状态 | 示例 |
|------|------|------|
| 巡逻等待 | ⬜ | 到达点后等待 2 秒 |
| 攻击间隔 | ⬜ | 攻击后 1 秒才能再攻击 |
| 状态切换 | ⬜ | 5 秒后切换到警戒状态 |

---

## 子矩阵 5：定时器生命周期

### 5.1 定时器清理

| 场景 | 状态 | 说明 |
|------|------|------|
| 手动清除 | ⬜ | ClearTimer(Handle) |
| Actor 销毁自动清除 | ⬜ | 自动清理 |
| 关卡切换清除 | ⬜ | 世界销毁时清理 |

### 5.2 定时器持久性

| 场景 | 状态 | 说明 |
|------|------|------|
| 跨关卡定时器 | 🚫 | 不支持 |
| 保存定时器状态 | 🚫 | 不自动保存 |

---

## 子矩阵 6：协程（如果支持）

### 6.1 协程基础

| 特性 | 状态 | 说明 |
|------|------|------|
| yield | 🚫 | AS 可能不支持 |
| async/await | 🚫 | |

---

## 子矩阵 7：性能和注意事项

### 7.1 性能考虑

| 场景 | 建议 | 状态 |
|------|------|------|
| 大量定时器 | 使用对象池 | ⬜ |
| 高频定时器 | 考虑 Tick 替代 | ⬜ |
| 精确计时 | 定时器有误差 | ⬜ |

### 7.2 常见陷阱

| 陷阱 | 状态 | 说明 |
|------|------|------|
| Lambda 捕获 this | ⬜ | this 可能被销毁 |
| 忘记清除定时器 | ⬜ | 内存泄漏 |
| 重复设置同一句柄 | ⬜ | 覆盖旧定时器 |

---

## 计划测试方法清单

### AngelscriptCoverageTimerTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `TimerBasics` | SetTimer/ClearTimer/IsActive |
| `TimerSingleShot` | 单次延迟执行 |
| `TimerLooping` | 循环定时器 |
| `TimerPauseResume` | 暂停和恢复 |
| `TimerRemaining` | 获取剩余/已用时间 |
| `TimerLambda` | Lambda 回调 |
| `TimerCleanup` | Actor 销毁时清理 |
| `TimerFirstDelay` | 首次延迟+循环 |

### AngelscriptCoverageLatentTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `LatentDelay` | System::Delay |
| `LatentMoveComponent` | MoveComponentTo |
| `LatentInterruption` | Latent 中断 |

---

## 待补充清单

### 🔴 高优先级

1. **定时器基础**（Set/Clear/Pause）
2. **单次和循环定时器**
3. **Lambda 回调**

### 🟡 中优先级

4. **定时器生命周期**（清理）
5. **Latent Actions**
6. **剩余时间查询**

### 🟢 低优先级

7. **性能优化场景**
8. **高级定时器模式**

---

## 总结

定时器是 **游戏逻辑的基础**：
- 技能冷却
- 延迟生成
- 周期性任务
- Buff 持续时间

**估计工作量**：3 个测试文件，约 15-20 个测试方法
**优先级**：🔴🔴🔴 极高（游戏逻辑核心）





