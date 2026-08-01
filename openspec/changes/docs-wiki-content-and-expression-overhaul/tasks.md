# 任务清单（长期 record-while-implementing）

> 本 change 是**长期伞形**工作，非一次性交付。以下分节可随维护者优先级**随时重排/重写**。
> 活文档：`doc-status-matrix.md`（内容看板）、`components-catalog.md`（组件登记）。
> 硬约束与提交流程见 `design.md`；每批内容/组件改动在 `Wiki/` 下用 `pnpm run test:fast` + 对应 `test:feature` 收口。

## 1. 盘点与治理基线

- [x] 1.1 用只读命令盘点全部 90 篇中文文档的 status/depth/kind/nav-group
- [x] 1.2 建立 `doc-status-matrix.md`（首轮：39 placeholder / 47 draft / 4 reviewed / 0 published）
- [x] 1.3 建立 `components-catalog.md`（登记已有可复用件 + 拟沉淀组件）
- [x] 1.4 记录内容契约、表现力边界、Git/Host 分离提交与验证入口（见 `design.md`）
- [ ] 1.5 维护者在矩阵中指定首批内容优先级（按 nav-group 或 reviewed 缺口最大 topic）

## 2. 表现力组件沉淀

> 按 `components-catalog.md` 的 planned 列分批实现，遵循形式选择优先级（内容 > procedure/function > 最小 widget）。

- [ ] 2.1 实现「能力对比表」`\procedure` 并在一个示例页验证
- [ ] 2.2 实现「API 签名表模板」`\procedure`（覆盖 reference 类页面）
- [ ] 2.3 实现「可折叠 源码入口/深入 块」`\procedure`（服务 internals 页）
- [ ] 2.4 实现「状态/深度徽章行」与「图标 callout 卡片」`\procedure`
- [ ] 2.5 约定「showcase 引用块」与「draw.io 图表嵌入」（允许列表 + 离线回退）
- [ ] 2.6 为带浏览器行为的组件补最小测试 tiddler + `test:feature -- <domain>`，并在目录标 `tested`
- [x] 2.7 <!-- Non-TDD --> 在 `comparison-artifacts/code-explanation/` 制作四个完全独立的源码解释 HTML（AS 行桥接、AS 执行收据、C++ 初始化路由、AS→C++ 反射边界），完成离线/桌面/窄屏/reduced-motion 验证；选型前不登记为 built/tested 组件
- [x] 2.8 在 `comparison-artifacts/code-explanation/` 制作四个单列源码内注释 HTML（AS 行间讲解、AS 表达式脚注、C++ 代码段批注、AS 执行值批注），所有主要解释默认展开，并完成纯源码复制、离线、桌面、窄屏、键盘与 reduced-motion 验证；选型前不登记为 built/tested 组件
- [x] 2.9 使用只读 subagent 调研并核实优秀源码解释展示，在 `research/code-explanation/` 建立参考目录、结构化总结和离线截图画廊，记录每项参考的优点、局限及对后续实验的采纳结论
- [x] 2.10 在 `comparison-artifacts/code-explanation/` 追加五个源码结构保护型 HTML（09–13：3 个 AS、2 个 C++；2 个窄侧轨、2 个无侧栏、1 个亮色代码块内嵌 note；CSS 连接 3 个、SVG 连接 2 个），保持 01–08 哈希不变，并完成源码连续性、连接定位、纯源码复制、桌面、390px 内部横向滚动、键盘与 reduced-motion 验证
- [x] 2.11 沿 `13` 的亮色代码块内嵌 note 方向追加四个依赖对照 HTML（14 原生 SVG/AS、15 LinkerLine/C++、16 Perfect Arrows/AS、17 Floating UI/C++），内联固定版本与许可证/来源/体积审计；保持 01–13 哈希不变，并完成真实仓库源码一致性、源码 DOM 纯净、五个短 note 首屏可见、碰撞与端点、长解释定位、纯源码复制、桌面、390px 内部横向滚动、键盘、reduced-motion、无外部请求和 teardown 验证
- [x] 2.12 <!-- Non-TDD --> 追加两个原生平台能力 HTML（18 CSS Custom Highlight + 原生 SVG/AS；19 CSS Anchor Positioning + Popover/C++，两者均含不污染源码 DOM 的兼容回退），保持 01–17 不变，并完成真实源码一致性、源码根结构纯净、交互前后行几何稳定、纯源码复制、桌面、390px 内部横向滚动、键盘、reduced-motion、离线和 capability/fallback 审计
- [x] 2.13 <!-- TDD --> 将 experiment 19 的交互方向落地为零外部依赖的 `<$annotated-code>` / 兼容 `<$angelscript-code>` / 直系 `<$code-note>` 生产组件，完成 code-domain 测试、P02–P04 Pattern 页面与目录/导航、document-content 与 document-domain 测试，并同步作者文档和 `components-catalog.md`
- [x] 2.14 <!-- TDD --> 恢复 experiment 19 的功能性编号、至少 44px 热区、低强调可点击表面、披露符号和阅读提示；保持源码 DOM/几何/复制不变并补 code-domain 回归
- [x] 2.15 <!-- TDD --> 实现生命周期、状态、序列、数据流、AST、VM 专用解释组件族与 `schemaVersion: 1` 数据合同，复用源码定位/Popover/Anchor/fallback/teardown 基础，不增加外部运行时依赖
- [x] 2.16 <!-- TDD --> 新增 P07–P10 mapped Pattern 与 L01–L02 experiment Lab、revisioned 源码/数据夹具、目录/作者文档和 document/code 测试；完成窄屏、打印、reduced-motion、离线、构建与 artifact 验证（见 `verification-source-explanations-2026-07-31.md`）
- [x] 2.17 <!-- TDD --> 将无 `match` 的行范围逐行裁剪到实际源码字符，并让 connector 默认位于源码下层、仅在 click/Enter/Space 固定详情时提升当前关系线；保持精确 `match`、空行语义、源码 DOM/复制/几何、窄屏与打印回退不变
- [x] 2.18 <!-- TDD --> 新增四个可移除的 P04 源码注解位置 Lab（Auto Dock / Top Notes / Reserved Rail / After Code），只通过 `experimentalLayout` 显式启用；保持正式页默认、42 项 Showcase catalog 和正式文档数量不变，并完成长行避让、无序号、connector terminal、窄屏回退与清理回归验证（见 `verification-source-note-placement-lab-2026-07-31.md`）
- [x] 2.19 <!-- TDD --> 将正式源码注解替换为无右轨的 whitespace-aware flow（行尾 → 邻近空白行 → 上方 shelf），默认隐藏行号与 note 序号/箭头，保持连接线默认在源码下层并随源码横向滚动；增加 `comment` / `muted` / `ink` 三种 Wiki 匹配样式、`detailTiddler` 独立详情与 compact/reading/rich 自适应详情面，迁移 P02–P04 并保留 2.18 的四个旧 Lab（见 `verification-source-annotation-flow-2026-07-31.md`）
- [x] 2.20 <!-- TDD --> 将 connector 固定在源码下层，idle 范围改为极浅填充且无下划线，移除详情 `×`；让 note placement、source mark、端口方向和逐 note 路径共享几何决策，修复多行/精确 match/top shelf/反向曲线，并沉淀源码注解布局规则与桌面/390px 截图验证（见 `verification-source-annotation-layer-and-geometry-2026-08-01.md`）
- [x] 2.21 <!-- TDD --> 为正式源码注解引入精确锁定的 `obstacle-router@0.1.2` 路由求解模块：同排且通道安全时生成严格水平直线，符合有界求解条件的 displaced 关系批量避让源码墨迹与 note 后平滑为低对比 SVG 曲线，无效/过度绕行/top-shelf 保留低层 fallback；按几何签名缓存并为大规模块延迟求解。同时显式区分内联短详情与带淡化 `Wiki` 标记的 `detailTiddler` 预览/独立跳转，完善 P04、许可证记录、code-domain/离线/release 验证与性能基线（见 `verification-source-annotation-obstacle-routing-2026-08-01.md`；完整 release 仍受记录中的既有非本轮失败阻塞）。

## 3. 结构重构

- [x] 3.0 修复 `AS/Docs` 知识体系视图一级主题展开后的同名重复：`<summary>` 主题名改为指向该 topic `/index` 的链接（点标题直达 landing），`<ul>` 用 `-[<landingTitle>]` 排除同名 index 条目；同步 `reader-capability-directory.spec.ts` 断言。（reader 场景视图受 90 条契约锁定、侧栏为任务型分组且测试要求 landing 可见，故不在本项范围）
- [ ] 3.1 复核 15 topics × 7 nav-group × L0–L5 归属是否合理（不新增第三级、不恢复退役 tag）
- [ ] 3.2 调整需要迁移的文档 `as-nav-group`/`as-nav-order`/`as-depth`/topic 归属
- [ ] 3.3 校验每篇正式中文文档在两级主路径中恰好出现一次
- [ ] 3.4 同步更新 `doc-status-matrix.md` 分组

## 4. 内容分批补全与重写

> 按 §1.5 指定的优先级逐批推进 placeholder→draft→reviewed；每篇满足契约证据后才升状态并回填矩阵。

- [ ] 4.1 补齐各 topic `index` landing 的六段结构（placeholder→draft）〔进行中：9 个有实际子文档的 landing 已用卡片网格+callout 重写并转 draft（language/unreal-language/unreal-core/hot-reload/runtime-jit-vm/type-object-reflection/compile-module-preprocessor/testing-diagnostics-release/reference-differences-version）；topics-integrations 加 callout 保持 placeholder；editor-ide-debugging/architecture-maintenance/showcase-lab 待有子文档后再推进〕
- [ ] 4.2 推进 language-basics 批次（补示例+复核）
- [ ] 4.3 推进 script-features（unreal-language reference 表格化+示例）
- [ ] 4.4 推进 unreal-development / bindings-extensions 批次
- [ ] 4.5 推进 workflow-validation 批次
- [ ] 4.6 推进 internals-reference（L4/L5 补可复核证据链，勿把计划文字标 reviewed）
- [ ] 4.7 hazelight-* 页按 revisioned 证据要求处理（缺证据保持 placeholder）
- [ ] 4.8 每批完成后回填矩阵状态与统计

## 5. 验证与集成

- [ ] 5.1 每批在 `Wiki/` 下跑 `pnpm run test:fast` 与相关 `pnpm run test:feature -- document|code|i18n`
- [ ] 5.2 在 `Wiki/` 内提交并推送到 `TDGameStudio/AngelscriptWiki`
- [ ] 5.3 回父仓库用 `git diff --submodule=log` 复核，仅暂存 `Wiki` gitlink 与相关 host 文档，单独提交
- [ ] 5.4 阶段性交付前跑 `pnpm run test:release`
- [ ] 5.5 阶段收口时更新本 change 记录（proposal/design/矩阵/目录），维护者决定是否归档或继续
