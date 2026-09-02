# AngelScript 目标无关源码与 AOT 调研

## Why

当前 AngelScript 可以通过 `#if EDITOR`、`#if TEST`、`#if RELEASE` 等条件在预处理阶段生成不同源码，AST AOT 又分别面向 `EditorDevelopment`、`GameDevelopment`、`GameShipping` 生成代码。这里需要先弄清 UE 及其他脚本语言如何组织 Editor、Development、Runtime 源码，以及 daScript 的 `static_if` 是否真正解决了多目标 AOT 变体问题。

## What Changes

- 只建立一份研究记录，保存讨论结论、源码入口和待验证问题。
- 对比 UE Python、Editor Utility、Reference 中其他脚本插件、daScript `static_if`、AngelScript 预处理和 StaticJIT/AOT。
- 记录曾讨论的 Runtime / Development / Editor Source Scope，并保留后来形成的修正：目录不承担编译语义，直接对比多 Profile sealed Canonical AST，再按实际语义相等性合并 AOT Body。
- 不修改插件代码，不创建正式 delta spec，不创建实施任务，也不把候选方案视为已批准设计。

## Capabilities

本次没有新增或修改正式 capability。若后续决定实施，再从本附件中拆出独立、可验证的 OpenSpec。

## Impact

本次仅影响本 OpenSpec 下的研究文档：

- `design.md`：当前研究状态和未定案边界；
- `attachments/ue-script-hosting-and-aot-research.md`：完整源码证据和讨论记录。
