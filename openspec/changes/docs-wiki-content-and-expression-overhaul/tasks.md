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
