# AngelScript Coverage 测试覆盖矩阵（主索引）

> 本文是 `AngelscriptTest/Coverage/` 测试覆盖的**唯一权威记录入口**，取代 `Documents/Coverage/` 下全部散乱文档。
> 详细矩阵已按 **AS 类型 / 功能** 拆分到 `matrices/` 下的多个文件；本文只保留**统一图例、列说明、领域索引与全局汇总**。
>
> - **权威来源**：实际测试代码（`Plugins/Angelscript/Source/AngelscriptTest/Coverage/*.cpp`），而非历史规划文档。
> - **扫描基线日期**：2026-06-29
> - **规模**：89 个测试文件 · 90 个 Automation 主题 · 约 980 个 `TEST_METHOD`
> - **测试形态**：CQTest `TEST_CLASS_WITH_FLAGS` + `TEST_METHOD`，Automation 前缀统一为 `Angelscript.TestModule.Coverage.<Theme>`。
> - **待覆盖项与 fork 不支持边界**：统一记录在 `coverage-gaps.md`。

## 图例（统一，所有子矩阵共用）

| 标记 | 含义 |
|------|------|
| ✅ | 已覆盖（有专属测试文件且方法较完整） |
| 🟡 | 部分覆盖（已有基础，存在已知待增强子项，见 `coverage-gaps.md`） |
| ⬜ | 待覆盖（尚无对应测试） |
| 🚫 | 当前 fork 不支持 / 不适用（已作为边界测试记录或不纳入计划） |

## 列说明（统一，所有子矩阵共用）

| 列 | 含义 |
|----|------|
| 主题 | Automation 前缀末段 `Angelscript.TestModule.Coverage.<主题>` |
| 测试文件 | `AngelscriptTest/Coverage/` 下的 `.cpp` 文件名 |
| 方法数 | 该文件内 `TEST_METHOD` 数量 |
| 状态 | 见上方图例 |
| 覆盖要点 / 备注 | 关键覆盖点或已知边界 |

---

## 领域矩阵索引（matrices/）

> 每个领域矩阵对应一组测试文件；大型功能系统各自独立成文。

### 类型与语言结构

| 矩阵文件 | 范围 | 文件数 | 方法数 |
|---------|------|-------|-------|
| [01-basic-types.md](matrices/01-basic-types.md) | int / float / bool / FString（属性·表达式·函数·方法） | 13 | 151 |
| [02-math-structs.md](matrices/02-math-structs.md) | FVector / FRotator / FQuat / FTransform / FLinearColor / FVector2D + Math 命名空间/几何结构 | 20 | 139 |
| [03-containers.md](matrices/03-containers.md) | TArray / TMap / TSet 及容器参数/嵌套 | 6 | 58 |
| [04-object-references.md](matrices/04-object-references.md) | handle / 弱引用 / 软引用 / TSubclassOf / GC | 5 | 57 |
| [05-uclass.md](matrices/05-uclass.md) | UCLASS / 类系统 / 生命周期 / 类特性 / 默认组件 | 5 | 79 |
| [06-ustruct.md](matrices/06-ustruct.md) | USTRUCT 及成员 | 2 | 47 |
| [07-macros-enum-function-interface.md](matrices/07-macros-enum-function-interface.md) | UENUM / UFUNCTION / UINTERFACE / 综合宏 / meta 说明符 | 5 | 84 |
| [08-delegates-events.md](matrices/08-delegates-events.md) | 单播/多播/动态委托 + 事件 | 4 | 52 |
| [09-control-flow-language.md](matrices/09-control-flow-language.md) | 控制流 / 命名空间 / 预处理 / 类型转换 / mixin / const / 运算符重载 | 11 | 62 |
| [10-components.md](matrices/10-components.md) | Component / Scene / Primitive / 特化组件 | 4 | 55 |

### 功能系统（各自独立）

| 矩阵文件 | 范围 | 文件数 | 方法数 |
|---------|------|-------|-------|
| [11-timer-async.md](matrices/11-timer-async.md) | 定时器 / 延迟 / Latent 边界 | 1 | 31 |
| [12-input.md](matrices/12-input.md) | 传统输入 + Enhanced Input | 1 | 21 |
| [13-physics-collision.md](matrices/13-physics-collision.md) | 物理 / 碰撞 / Trace / 约束 / 角色移动 | 1 | 25 |
| [14-widget-ui.md](matrices/14-widget-ui.md) | Widget / UMG（含 Widget.RuntimeApi 前缀） | 1 | 24 |
| [15-networking.md](matrices/15-networking.md) | 复制 / RPC / 网络角色 | 1 | 28 |

### 支撑与杂项

| 矩阵文件 | 范围 | 文件数 | 方法数 |
|---------|------|-------|-------|
| [16-assets-and-save.md](matrices/16-assets-and-save.md) | 资源加载 / 字面量资源 / 材质 / SaveGame | 4 | 19 |
| [17-debug-logging.md](matrices/17-debug-logging.md) | 调试 / 日志 / 错误处理 | 3 | 35 |
| [18-misc-systems.md](matrices/18-misc-systems.md) | CVar / AnimInstance | 2 | 13 |

---

## 全局汇总

| 维度 | 数值 |
|------|------|
| 领域矩阵文件 | 18 |
| 测试 `.cpp` 文件 | 89 |
| Automation 主题 | 90（Widget 含 `Widget.RuntimeApi` 第二前缀） |
| `TEST_METHOD` 总数 | 约 980 |

> 校验：18 个领域矩阵的文件数小计相加 = 89；方法数小计相加 = 980。新增/删除 Coverage 测试文件时，先更新所属领域矩阵，再回填本表。
