# 源码注解布局规则

本文是 `<$annotated-code>`、`<$angelscript-code>` 与直系 `<$code-note>` 的维护者规则。作者向的简版说明由插件内 `$:/plugins/TDGameStudio/angelscript-tools/documentation/source-annotation-layout-rules` 提供。

## 不可破坏的源码边界

- TiddlyWiki Highlight 继续独占 `<pre>/<code>`；note、range、port、connector 和 detail 都是兄弟覆盖层。
- 激活、打开、关闭、resize 和滚动不得改变源码文本、DOM 顺序、换行、行矩形、自然宽度或复制结果。
- 不预留、遮罩或恢复右侧 note rail。源码拥有完整可用宽度和自己的内部横向滚动。

## 固定视觉层级

| z-index | 层 | 规则 |
|---:|---|---|
| 0 | connector SVG | idle、hover、focus、open 永久低于源码；允许几何穿过代码区域 |
| 1 | Highlight `<pre>/<code>` | 始终是核心视觉层，字形绘制在线条之上 |
| 2 | range mark / source port | idle 极弱，只有当前关系在交互时清晰可见 |
| 5 | short note | 只能占用测量得到的源码空白或顶部 shelf |
| top layer / fixed | detail | 读者主动打开后出现，不参与源码布局 |

Idle range 使用 `rgba(66, 113, 174, 0.025)`，下划线透明；hover、focus 或 open 使用 `rgba(66, 113, 174, 0.10)` 并显示 focus 色下划线。source port idle 隐藏，交互时显示。connector idle 使用低对比灰蓝，当前关系只增强颜色和透明度，不改变 z-index。

## Note placement

关系按显示起始行处理，同一起始行保留作者顺序，依次尝试：

1. `line-tail`：评估目标范围内的非空源码行，把 note 放在整行墨迹右侧 `12px`；与源码墨迹保留 `4px`，与其他 note 保留 `6px`。精确 match 优先其所在行，多行范围优先靠近首行且连接更短的合法候选。
2. `blank-line`：只使用文本确实为空的行，从目标范围向外最多搜索 `6` 行；按距离、下方优先、行号排序，note 左边与源码内容起点对齐。
3. `top`：前两步都失败时进入顶部 shelf，按源码顺序排列，水平间隔 `6px`、换行纵向间隔 `4px`。小于 `720px` 的容器优先使用 shelf。

任何 placement 都不得让 note 矩形与源码墨迹或已有 note 相交。shelf 只能增加组件顶部空间，不能向 `<pre>/<code>` 插入占位内容。

## Source mark、端口与路径

- `line-tail` 从实际承载 note 的源码行对应 mark 的右侧中心出线，路径起点就在 mark 真实边界，不预留隐形间隙。
- `blank-line` 从到 note 边界曼哈顿距离最短的 mark 和边出线。
- `top` 从离 note 最近的 mark 顶部中心出线，并进入 note 底部中心。
- note 在 source 左侧时连接 note 右边；否则连接左边。note port 位于真实边界，SVG 终点与边界误差不得超过 `1px`。
- 横向路径的两个控制点共享端点之间的 `midX`；顶部路径共享 `midY`。控制点不得越出起终点包围区间，不使用强制向右的最小弯折。
- 路径可以从精确 match 下方穿过同一行剩余 token，也可以跨越多行，但 connector 永远在源码下层，因此不得降低字形可读性。

## 交互与关闭

- Idle：所有短 note 可见；范围仅有极浅填充；source port 隐藏；connector 低对比。
- Hover/focus：只增强对应 note、range、source port 和 connector。
- Open：保持同一关系 active，展开 compact/reading/rich detail；connector 仍位于源码下层。
- Close：再次激活当前 note、点击外部、按 `Escape` 或激活另一条 note。没有独立 `×`；`Escape` 后焦点回到触发 note。
- 同一源码块一次只打开一个 detail，`aria-expanded` 与 Popover/fallback 状态同步。

## 响应式与验证

- 横向滚动时 note、range 和 connector 使用源码坐标共同移动；滚动不得重新选择 placement。
- 打印隐藏 connector、port 和交互 chrome，静态保留说明语义。
- `prefers-reduced-motion` 关闭过渡，不隐藏 focus 或 active 状态。
- Playwright 必须覆盖 P02/P03/P04、line-tail/blank-line/top fixture、`1440x1000`、`1280x900` 与 `390x844`。
- 自动验收包括：note 不覆盖墨迹、connector 永久低层、端点误差不超过 `1px`、无 `NaN`/Infinity/控制点 overshoot、源码 DOM/行矩形/复制不变，以及详情无 `×` 且四种关闭路径等价。

任务 2.21 在这套落位规则之上增加了一个受限的正交避障层：安全同排关系仍直接绘制严格水平线；其余关系才执行预打包的 `obstacle-router@0.1.2` library 模块。依赖只返回矩形障碍之间的路径点，源码测量、note 落位、端点出口、圆角路径、SVG、缓存、idle 延迟与 fallback 仍由产品组件拥有。无有效结果或绕行超出端点包围框时保留原低层曲线；固定层级继续作为最后一道源码可读性保护。
