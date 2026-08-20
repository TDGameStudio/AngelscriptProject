# OpenSpec 怎么自定义规则

来源：官方 [customization.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md)（2026-08-19 查阅）。本仓库当时没有 `openspec/config.yaml`。

## 三层定制（从轻到重）

### 1. `openspec/config.yaml`

官方说大多数团队这一层就够。agent 写制品时注入：

- `context`：所有制品都能看到（技术栈、测试入口、命名）
- `rules.<artifact>`：只对应该制品（proposal / specs / design / tasks）
- `operations.apply.guidance` / `operations.archive.guidance`：管怎么干活，不管文件里写什么

这些是**提示词级建议**，`openspec validate` 不会因为 task 没路径而失败。

Schema 解析顺序：CLI `--schema` → 该 change 的 `.openspec.yaml` → `openspec/config.yaml` → 默认 `spec-driven`。

示意（未落盘，实施时再写）：

```yaml
schema: spec-driven
context: |
  Unreal + Hazelight AngelScript。验证只走
  Tools\RunBuild.ps1 / RunTests.ps1 / RunTestSuite.ps1。
  新测试文件必须 Angelscript 前缀。
rules:
  tasks:
    - 每条 checkbox 必须有精确路径
    - 必须能追溯到 requirement / capability
    - 必须有 TDD 或 Non-TDD 标记和验证命令
    - 禁止 Implement X / Add tests / Handle edge cases
operations:
  apply:
    guidance:
      - feature/fix/refactor/improve/test 一次只做一组，做完停
```

### 2. 项目 schema

```powershell
openspec schema fork spec-driven angelscript
openspec schema validate angelscript
```

产出 `openspec/schemas/angelscript/`：`schema.yaml` + `templates/`。`instruction` 改“怎么写”，`template` 改骨架，`requires` 是依赖不是门禁。

设计默认：先只用 config；规则仍被忽略再 fork。

### 3. 用户级 schema

`~/.local/share/openspec/schemas/`。官方更推荐放项目里进 git。本仓库不采用这一层做默认。

## 官方 customization 收录的社区 schema

都是拷进 `openspec/schemas/<name>/`，不是 npm 依赖。只改“要哪些文件、instruction 怎么写”，不自动保证写得好。

| Schema | 仓库 | 多出来的东西 | 对本仓库 |
|---|---|---|---|
| intent-driven | intent-driven-dev/openspec-schemas | Gherkin + 长期 ADR | 和已有 design/research 可能重复 |
| superpowers-bridge | JiangWay/openspec-schemas | brainstorm → … → plan.md → verify → retrospective；apply 强制 Superpowers | 最接近意图，但比当前合并 skill 硬得多 |
| nanopm | nmrtn/nanopm | 产品审计 / PRD 上游 | 不太适用 |
| e2e-runbooks | Lukk17/openspec-schemas | capability 级 e2e 跑法记录 | 验收模型对不上 |
| anvil | jikkujoyce/openspec-schemas | adversarial review + test-plan | 对 TDD 有用，全量会重 |

同批还有未单独进那张表的：minimalist（specs+tasks）、behaviour-driven、event-driven、research-first 示例。

**当前决定：不整包安装社区 schema。** 需要的规则自己写进 config + `openspec-work`。
