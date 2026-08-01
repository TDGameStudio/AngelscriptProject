# 源码注解位置实验设计

## 目的

在不改变现有 P02–P10、L01–L02 页面和生产组件默认行为的前提下，新增一组可移除的 TiddlyWiki Lab 页面，比较长 C++ 源码周围的四种注解位置策略。实验统一使用 `AS/Showcase/Source/P04-ScriptGameInstanceSubsystem`，使维护者只比较布局、遮挡、连接线与披露状态，而不受源码内容差异干扰。

本轮属于 `docs-wiki-content-and-expression-overhaul` 的实验分支，不把任何布局直接声明为稳定作者 API。

## 不变量

- `<pre>/<code>` 中的源码文本、缩进、换行、显示行号、复制结果和行几何不得因 note 状态改变。
- 现有组件未传实验参数时，DOM、布局选择、视觉状态和窄屏/打印行为保持不变。
- 实验页面不新增 Showcase catalog ID，不使用 `ASWiki/Docs/showcase-lab` 正式文档标签，不改变 42 项 Showcase catalog 和正式中文读者文档数量。
- 四个主实验都读取同一个 P04 C++ 源码 tiddler，不复制源码正文。
- 实验 note 不显示视觉序号；源码流程、VM 前后步等真正具有顺序语义的控件不在本轮全局修改。
- 未激活 note 的视觉强度接近编辑器辅助注释：透明或近透明底色、低对比边框与文字；hover/focus 只轻度增强；click/Enter/Space 固定当前关系并打开详情。
- connector 默认位于源码墨迹下层；固定详情时仅当前关系线提升。与 note 接口相连的末端不得被 note 轨背景遮断。
- 窄屏不能压缩或覆盖源码；实验布局统一退化为源码后的顺序注解。
- 支持键盘聚焦、`Escape` 关闭、reduced-motion、打印静态语义和 widget 销毁清理。

## 承载方式

### 选择：生产组件内的显式实验参数

在现有 `<$annotated-code>` / `<$angelscript-code>` 基座中加入只由 Lab 页面传入的实验布局参数。没有参数时继续走现有生产路径；实验参数只选择 note 容器、碰撞判定与样式变体，继续复用既有源码解析、DOM `Range`、SVG connector、Popover/Anchor fallback、键盘交互与 teardown。

这样得到的视觉结论可以直接验证在真实 Wiki widget 中是否可行，又不会让四个页面各自复制连接线和披露状态机。参数在实验结束前不进入稳定作者文档；若全部方案被放弃，可连同实验页面和分支代码一起删除。

实验属性固定为 `experimentalLayout="auto|top|reserved|after"`。属性缺失、空白或值无效时必须走现有默认路径；只有四个有效值才添加 `angelscript-code--layout-lab` 和对应布局类。组件在 `data-annotation-placement` 暴露本次实际选择的 `right`、`top`、`reserved` 或 `after`，只供 Lab 说明和自动化验证读取。有效实验布局统一隐藏 note 视觉序号并把 `aria-label` 改为不含序号的“注解：{label}”；本轮不增加第二个“是否显示编号”属性。

### 未选择：复制实验 widget

隔离性更强，但会复制范围定位、Popover/fallback 与清理逻辑。实验结论回迁生产组件时仍需第二次集成验证，因此不采用。

### 未选择：页面内手写 HTML/CSS

适合静态视觉稿，但无法验证真实 Wiki widget 的源码复制、动态重排、详情披露和销毁行为，因此不作为本轮交付。

## 页面信息架构

新增一个临时索引和四个独立实验 tiddler：

- `AS/Showcase/Lab/AnnotationPlacement`：实验说明、共享约束、四页导航和“可删除”警告。
- `AS/Showcase/Lab/AnnotationPlacement/E01-AutoDock`
- `AS/Showcase/Lab/AnnotationPlacement/E02-TopNotes`
- `AS/Showcase/Lab/AnnotationPlacement/E03-ReservedRail`
- `AS/Showcase/Lab/AnnotationPlacement/E04-AfterCode`

`AS/Showcase/Lab` 在现有 11 项 catalog 之后增加一段独立的“临时源码注解位置实验”入口。新页不声明 `as-showcase-id`、`as-doc-kind` 或正式文档标签。

每页都应明确显示：

- 当前布局策略和适用场景；
- 固定源码路径、revision 与显示范围；
- 相同的四条 note 内容；
- 宽屏行为、窄屏回退和已知取舍；
- 返回实验索引与 P04 正式页的链接。

## 四种实验

### E01 Auto Dock

在桌面宽度下测量真实源码墨迹最右边界，而不是只检查组件宽度。只有当源码墨迹与候选右侧 note 轨之间保留至少 `16px` 安全间隔时才选择右侧轨；否则整组 note 移到源码顶部。容器进入窄屏阈值后切换为 After Code。

P04 第 31 行

```cpp
FAngelscriptEngine* CurrentEngine = FAngelscriptEngine::TryGetCurrentEngine();
```

是明确的碰撞判据：在当前 Wiki 内容宽度中不得被 note 背景或标签覆盖。

自动判定在一次布局周期内只输出一个组件级 placement，避免逐 note 跳动和连接线交叉。作者可以在 Lab 中显示最终判定结果，方便比较，但该诊断不进入正式读者 API。

### E02 Top Notes

note 以可换行的轻量标签带排列在源码上方，源码使用完整可用宽度。标签带属于代码组件内部，但不进入 `<pre>/<code>`。选择标签后，精确源码范围和当前关系线增强，详情从标签附近展开。

顶部布局必须把标签带高度纳入 gutter、range 和 connector 的实际几何测量，不允许通过改变源码行高或向源码插入占位元素来对齐。

### E03 Reserved Rail

源码视口与窄 note 轨作为代码表面的两个兄弟区域。note 轨拥有独立背景且永不覆盖源码；横向滚动只作用于源码视口，note 轨保持稳定。它是代码组件内部的辅助轨，不是页面级正文双栏。

当组件宽度不足以同时容纳可读源码宽度和 note 轨时，直接切换为 After Code，不把源码压成狭窄列。

### E04 After Code

源码使用完整宽度，note 按源码位置顺序排列在代码块之后。默认不显示常驻 connector；hover/focus/click 某条 note 时才显示临时关系线或精确范围提示。它是最稳定的对照组，也是其他布局没有安全空间时的最终回退。

## 交互与视觉

配色继续使用 Wiki 当前亮色主题的灰蓝体系，不创建新的高饱和强调色。源码是主视觉层；note 只在交互时获得清晰边界。

- Idle：透明背景、无阴影、弱边框或仅文字；连接线低层且接近不可见。
- Hover/focus：当前 note、端口、源码范围和关系线轻度增强；focus 必须有可见轮廓。
- Pinned/open：当前 note 使用中等灰蓝边框，详情卡可读；当前 connector 提升，其余 connector 隐藏或保持低层。
- Close：恢复 Idle，不保留错误的 active 状态。
- Reduced motion：取消过渡与位移动画。

所有 note 均使用文字标签而非 `01/02/03/04`。`aria-label` 直接描述标签，例如“注解：验证当前 VM”，不朗读视觉序号。

## 连接线末端

右侧轨存在不透明背景时，完整 connector 仍默认位于源码下层；同时在 note 轨内部绘制一段被轨边界裁剪的 terminal overlay，覆盖从轨边界到 note port 的最后短段，使线在视觉上真正接到端口。

当关系被固定并提升完整 connector 时，terminal overlay 隐藏，避免两条线叠加。顶部和 After Code 若不需要穿过不透明轨，则不创建 terminal overlay。

## 数据流

1. 父 widget 解析共享 P04 源码、显示范围和四个 `<$code-note>`。
2. Highlight 管线生成原有源码 DOM。
3. 范围解析器从源码文本节点建立 `Range`，得到逐行源码墨迹矩形。
4. 实验布局策略读取组件宽度、源码墨迹边界和 note 尺寸，选择 `right`、`top`、`reserved` 或 `after`。
5. 布局稳定后绘制 range mark、低层 connector 和必要的 terminal overlay。
6. note 交互沿用现有披露状态机；placement 变化不重建源码 DOM。
7. resize、字体就绪、滚动和 TiddlyWiki refresh 触发节流重算；销毁时取消 RAF、断开 observer、关闭详情并移除 listener。

## 验证设计

### 组件回归

- 未传实验参数的 P02/P04 保持当前默认布局和行为。
- 四种参数只在实验页面生效。
- P04 长行的源码墨迹矩形不与 note 背景或 note 标签相交。
- 代码复制结果与 P04 源码 tiddler 完全一致。
- 打开/关闭 note 前后，每一行源码的 `x/y/width/height` 不变。

### 实验行为

- E01 在 P04 当前桌面宽度选择 Top，并在有足够空白的短片段测试夹具中选择 Right。
- E02 note 位于源码首行上方，gutter 与源码首行仍对齐。
- E03 note 轨与源码视口无重叠，源码横向滚动不会移动 note 轨。
- E04 note 位于源码之后，Idle 无常驻 connector。
- 四页无视觉序号，click/Enter/Space 打开详情，`Escape` 关闭。
- 右侧轨 connector 的可见终点与 note port 中心误差不大于 `1px`，且没有被背景遮出的末端空白。
- `390px` 宽度统一退化为 After Code，不产生文档级横向溢出。
- 打印、reduced-motion、两个组件同页隔离和 refresh/destroy 清理继续通过。

### 内容与目录契约

- Showcase catalog 仍为 42 项，Lab catalog 仍为 11 项。
- 正式中文读者文档数量不变。
- `AS/Showcase/Lab` 可以打开临时实验索引，索引可以分别打开四个实验页。

## 范围外

- 不选择最终生产布局。
- 不全局移除 P02–P10、L01–L02 已有编号或流程顺序标识。
- 不修改 P04 正式页的 note 内容、位置或默认参数。
- 不增加第三方运行时依赖。
- 不更新或删除既有 01–19 独立 HTML 实验。
- 不提交或推送 Wiki 子模块与父仓库；除非维护者后续明确要求。

## 移除与晋升

若实验被放弃，删除四个页面、临时索引、Lab 临时入口、实验参数分支和对应测试即可，正式组件默认行为不受影响。

若某一方案被选中，先把选中行为重写为稳定的组件合同和 OpenSpec requirement，再迁移正式页面；未选方案和诊断 UI 随实验一起移除。实验参数名不得未经这一步直接写入正式作者文档。
