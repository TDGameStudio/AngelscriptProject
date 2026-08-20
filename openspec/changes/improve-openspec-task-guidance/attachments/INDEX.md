# Attachments — 读什么

两套附录**隔离**。讨论过程要记全；**实现时默认不读讨论区**，卡住再按条打开。

| 阶段 | 必读 | 不要打开 |
|---|---|---|
| 讨论 / 规划 | `proposal.md`、`design.md`、`specs/`、`planning/` | 无 |
| 实现 / apply | `proposal.md`、`design.md`、`specs/`、`tasks.md`、`implementation/` | **`planning/`**，除非当前 task 卡住 |
| 卡住了 | 先写 `implementation/issues.md`，再按卡点打开 `planning/` 里**一份**专题文件 | 不要整目录灌进上下文 |

`planning/` 和 `implementation/` 各自有 `issues.md` 与 `progress.md`，不要混写。

实现中若改了 OpenSpec 自己的结构（拆附录、改 task 格式、改 skill/config），追加 `implementation/openspec-refactors.md`，并回写主制品。
