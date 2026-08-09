# Chapter 1 架构图（archify 设计语言）

第 1 章（`Wiki/wiki/tiddlers/docs/zh-Hans/start/*`）里的架构/流程图，采用
[archify skill](../../.agents/skills/archify) 的**设计语言**，以**自包含的静态内联 SVG**
直接嵌在 tiddler 正文里。

## 为什么是内联静态 SVG，而不是 archify 的 HTML 输出

archify `render` 产出的是 ~530KB 的**交互式独立 HTML 应用**（平移缩放、主题切换、脚本运行时）。
本 Wiki 的需求是「一图流、不需要动效」，且图必须内嵌在受内容契约校验的 tiddler 中。
因此采用 archify SKILL 明确认可的「无运行时」降级方式：**按其 Design System 手写静态 SVG**。

优点：
- 完全自包含（内联 `fill`/`stroke` 呈现属性，无 `<style>` 泄漏、无脚本）——通过内容契约。
- 单一固定深色配色，无论 Wiki 处于亮/暗主题都稳定显示。
- 经 `document-content-contract` / `document-resolution` 测试与 TiddlyWiki CLI 渲染验证。

## 用到的 archify 设计 token（深色 classic 预设）

| 语义 | fill | stroke |
|---|---|---|
| frontend（客户端/脚本） | `rgba(8,51,68,0.4)` | `#22d3ee` cyan |
| backend（服务/引擎侧） | `rgba(6,78,59,0.4)` | `#34d399` emerald |
| database（存储/引用） | `rgba(76,29,149,0.4)` | `#a78bfa` violet |
| cloud（判定/编译反馈） | `rgba(120,53,15,0.3)` | `#fbbf24` amber |
| security（否分支/告警） | `rgba(136,19,55,0.4)` | `#fb7185` rose |
| external（中性/仅脚本） | `rgba(30,41,59,0.5)` | `#94a3b8` gray |

- 背景板 / node mask：`#0f172a`，边框 `#1e293b`。
- 文本：主 `#ffffff`，次要 `#94a3b8`/`#cbd5e1`，弱 `#64748b`。
- 箭头：默认 `#64748b`，强调 `#34d399`，虚线（异步/回环）`#a78bfa` `stroke-dasharray="4,4"`。
- 字体：`JetBrains Mono, ui-monospace, monospace`。
- 两矩形模式：先画不透明 mask 矩形，再画半透明语义矩形，防止箭头透出。

## 图清单

| tiddler | 图 |
|---|---|
| `start/index` | 三步路线（准备边界 → 第一个脚本 → 验证与迭代） |
| `start/plugin-and-boundaries` | 脚本与插件职责分工（本目录 `plugin-responsibilities.architecture.json` 为对应 archify 源） |
| `start/first-script` | 成员是否加 UPROPERTY/UFUNCTION 的可见性判定 |
| `start/verify-and-iterate` | 迭代循环 + 类不出现的排查流程 |

## 需要交互版 / 重新生成

如需 archify 的完整交互式 HTML（平移缩放、主题切换、导出），用本目录的 JSON 源：

```bash
cd .agents/skills/archify
node bin/archify.mjs render architecture ../../../Docs/Diagrams/archify/plugin-responsibilities.architecture.json out.html
```

修改内联 SVG 时保持：仅呈现属性、无 `<script>`、无 `<style>`、无空行打断 SVG 块，
改完重跑 `Wiki` 下的 `document-content-contract` 与 `document-resolution` 测试。
