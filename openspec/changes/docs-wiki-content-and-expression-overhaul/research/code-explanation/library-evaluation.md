# 源码内嵌 note：JavaScript 库评估

记录日期：2026-07-30

## 目标与约束

本轮不是寻找一个“自动解释源码”的大而全框架，而是沿 `13-as-embedded-note-chips.html` 拆解三个小问题：

1. 怎样在不改源码 DOM 和行几何的前提下，把短 note 放进代码纸张内部的空白；
2. 怎样在滚动、缩放和字体完成加载后，让轻量关系线仍贴住源码 token/range 与 note；
3. 怎样让 hover / focus / click 展开的长解释自动避开代码纸边缘。

共同约束：每页是可直接打开的单文件 HTML；源码来自当前仓库并保持原顺序；note、锚点和 connector 都是源码根节点的兄弟覆盖层；常态无箭头、不表达执行方向；依赖完整内联且加载时零外部请求。

## 已实现对照

| 编号 | 语言 / 真实源码 | 被评估职责 | 运行时 | 内联字节 | 当前判断 |
|---|---|---|---|---:|---|
| 14 | AS / `Script/Examples/EnhancedInput/Example_EI_Component.as:17-41` | 动态 lane、DOM Range 锚点、原生 SVG 连接 | Web Platform | 0 | 零依赖生产基线；控制力最好 |
| 15 | C++ / `AngelscriptBinds.cpp:234-271` | 滚动容器内的正交连接与重定位 | LinkerLine 1.6.1 | 108,262 | 行为完整但体积偏重；保留为连接器生命周期参考 |
| 16 | AS / `Example_InterfaceDispatch.as:63-74` | 点到点曲线控制点 | Perfect Arrows 0.3.7 | 6,239 | 很轻，但只解决几何；不负责布局、生命周期或浮层 |
| 17 | C++ / `AngelscriptSubsystem.cpp:72-101` | 长解释的 flip / shift / 自动重定位 | `@floating-ui/dom` 1.8.0 | 22,237 | 最有价值的可选依赖；职责应只限详情浮层 |

字节数是本轮用 esbuild 生成并实际内联到 HTML 的 IIFE 文本大小，包含各自被打包进入的传递依赖；不是 gzip 网络体积。

## 库级判断

### 原生 DOM Range + SVG

- 优点：没有依赖；可以精确测量 token 文本而不往源码节点插 marker；连线颜色、层级、无箭头语义和 teardown 都完全可控。
- 局限：正交/曲线路径、ResizeObserver 调度、锚点重建和碰撞逻辑需要自行维护。
- 结论：正式 TW 组件应从这条基线开始。源码测量和短 note 布局不应交给通用连线库。

### LinkerLine 1.6.1

- 直接来源：[AhmedAyachi/LinkerLine](https://github.com/AhmedAyachi/LinkerLine)
- 许可证：MIT；实验固定版本：1.6.1。
- 官方仓库明确增加了 `parent`、滚动定位、绝对定位、实例 `element` 和 `minGridLength`，正好覆盖“连接线必须留在代码纸内部并随滚动重排”的实验问题。
- 优点：连接器生命周期、正交路径、父容器归属和 `.position()` 都是现成能力。
- 局限：本轮单页内联 108,262 bytes；它仍基于 LeaderLine 体系。原始 [LeaderLine](https://github.com/anseki/leader-line) 已于 2025-04-11 归档为只读，因此生产采用前需要单独评估维护风险。
- 结论：不建议作为轻注释的默认生产依赖；保留其“先销毁旧实例，再为新锚点重建”的生命周期模式。

### Perfect Arrows 0.3.7

- 直接来源：[steveruizok/perfect-arrows](https://github.com/steveruizok/perfect-arrows)
- 许可证：MIT；实验固定版本：0.3.7。
- 优点：本轮内联仅 6,239 bytes；输入端点即可得到曲线控制点，适合快速比较直线与柔和曲线。
- 局限：它不创建或维护 DOM，不处理滚动、ResizeObserver、碰撞、详情浮层或 teardown；库名和常见输出都强调 arrow，但源码解释的关系线不应暗示执行方向。
- 结论：实验只使用控制点并刻意省略箭头头部。相较几行原生 SVG 二次曲线代码，它带来的生产价值有限。

### `@floating-ui/dom` 1.8.0

- 直接来源：[Floating UI `computePosition`](https://floating-ui.com/docs/computeposition) 与 [`autoUpdate`](https://floating-ui.com/docs/autoupdate)
- 许可证：MIT；实验固定版本：1.8.0。
- 优点：`flip`、`shift`、`offset` 把长解释限制在代码纸边界内；`autoUpdate` 覆盖祖先滚动、窗口/元素尺寸变化和 layout shift。职责与“详情浮层避边”高度吻合。
- 局限：本轮内联 22,237 bytes；`autoUpdate` 必须在不再需要时执行 cleanup，不能为大量永久隐藏的浮层无限保留监听器。
- 结论：如果正式组件确实需要富详情浮层，这是当前唯一值得继续进入 TW 插件原型的依赖候选。短 note 布局和关系线仍应保持原生。

## 未采用但保留的参考

- [LeaderLine](https://github.com/anseki/leader-line)：功能经典，但仓库已归档；本轮不直接采用。
- [jsPlumb Community Edition](https://github.com/jsplumb/community-edition)：面向完整连接图/节点编辑器，且仓库说明已不再更新；对五条轻量源码关系线明显过度。
- [SVG.js](https://github.com/svgdotjs/svg.js)：活跃、MIT、适合通用 SVG 操作，但它不替我们决定锚点、碰撞或路径路由；当前原生 SVG 已足够清楚。

## 从截图与验证得到的布局结论

- note lane 应按“桌面初始可视代码纸宽度”分配，而不是按被长 C++ 行撑大的完整纸张宽度分配；否则标签会跟着超宽源码跑出首屏。
- 源码纸仍可在自身容器内横向滚动，源码行不换行、不裁切；note 可以在别的纵向空白处占据可视 lane，只要碰撞审计证明不覆盖源码文字。
- note 摘要使用真正的 button 语义；不能用关闭状态的原生 `<details>` 承载 hover 详情，因为浏览器会把 `<summary>` 后的内容视为不可见。
- `prefers-reduced-motion` 应使用 `transition: none` / `animation: none`，不能只给所有元素写极短 `transition-duration`，后者会反而给原本无过渡的 visibility 创建异步过渡。
- 锚点层重建会断开旧端点；任何持有端点元素的连接库都必须在重建前 teardown，并在新端点出现后重新实例化。

## 暂定生产方向

若下一轮获准修改 TW AngelScript 插件，优先原型应是：

1. 原生 DOM Range 测量真实源码 token/range；
2. 原生三 lane + 碰撞检测放置常驻短 note；
3. 原生 SVG 低对比、无箭头关系线；
4. 只有当详情确实需要复杂避边时，才可选引入 Floating UI；
5. LinkerLine 与 Perfect Arrows 不随默认组件一起打包。

这仍是研究结论，不把任何实验登记为 `components-catalog.md` 的 `built` 或 `tested`。
