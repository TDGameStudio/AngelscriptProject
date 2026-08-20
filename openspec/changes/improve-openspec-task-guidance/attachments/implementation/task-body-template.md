# 每条 task 的多行正文

用户要求：不要再把一条 task 挤成一行。checkbox 第一行只写动作标题；**改哪些文件、影响面、做完要不要测** 写在下面的缩进列表。OpenSpec apply 仍然只认 `- [ ]` / `- [x]`，所以正文必须缩进在该 checkbox 下面，不能另起一个未缩进的 `- [ ]`。

对照：本仓库不少厚 change（如 `feature-as-multithreaded-type-registration`）其实已经把路径和命令塞进**同一行**，读起来像一段散文。用户要的是拆开的多行字段，不是更长的一行。

## 行为变更（feature / fix / refactor / improve / test）

```markdown
- [ ] 1.1 一两句动作标题 <!-- TDD -->
  - Files:
    - Create: `exact/path/NewFile.cpp`
    - Modify: `exact/path/Existing.cpp`
    - Test: `exact/path/AngelscriptFooTests.cpp`
  - Impact: 会影响哪些模块/调用方；明确不会动什么
  - Tests: Yes — 必须跑的前缀/套件；或 No — 为什么（纯文档、纯注释）
  - Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "..." -Label ...`
  - Requirement: `<spec requirement or capability>`
```

字段：

| 字段 | 必填 | 写什么 |
|---|---|---|
| 第一行标题 | 是 | 短动作 + `<!-- TDD -->` 或 `<!-- Non-TDD -->` |
| Files | 是 | Create / Modify / Test，精确路径 |
| Impact | 是 | 影响面：谁会读到这次改动、热重载/绑定/测试层有没有连带 |
| Tests | 是 | Yes + 测什么，或 No + 理由。不能省略 |
| Verify | 是 | 做完这条就跑的那条命令 |
| Requirement | 是 | 对上 delta spec 的 requirement / capability |

可选：`Depends`、`[P]`（仍标在第一行标题里，含义不变：不同文件、无未完成依赖）。

## chore / docs（允许瘦，但仍多行）

```markdown
- [ ] 2.1 删掉过时注释 <!-- Non-TDD -->
  - Files: Modify `Documents/Foo.md`
  - Impact: 仅文档
  - Tests: No — 无行为变化
```

## 禁止

- 只有一行：`Implement X` / `Add tests` / `Update docs`
- 把 Files/Impact/Tests 全塞进 checkbox 同一行
- 在 checkbox 下写调查日志、命令输出（那些进 `issues.md` / `implementation-progress.md`）
- 另起未缩进的 `- [ ]` 当“子步骤”（apply 会当成新 task）

子步骤用普通缩进破折号，不要 checkbox。

## 本 change 自用

`../../tasks.md` 组 2 起按此格式写。组 1 已完成的一行记录可保持原样。
