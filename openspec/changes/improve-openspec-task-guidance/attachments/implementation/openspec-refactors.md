# OpenSpec 自身重构日志（实施中）

实施过程中可能随时改 OpenSpec：task 格式、附录分桶、`config.yaml`、`openspec-work`、schema。每次改动追加一条。**先改主制品**（proposal/design/specs/tasks），再写本文件。不要把这类改动只留在聊天里。

## 条目模板

```markdown
## <日期> — <一句话>

- Trigger: 实施中碰到什么，才改 OpenSpec
- Changed: 哪些 OpenSpec 文件/附录
- Why: 不改会怎样
- Contract: specs/tasks 是否已回写
```

## 2026-08-19 — 附录分成 planning / implementation

- Trigger: 用户要求记录讨论过程，但实现时不读讨论，省 token；实施中还可能随时重构 OpenSpec，也要记账。
- Changed: `attachments/planning/`、`attachments/implementation/`、本文件、`INDEX.md` 路由表。
- Why: 讨论附件继续变厚的话，apply 会把整包规划笔记灌进上下文。
- Contract: spec 增加 Attachment isolation 与 Mid-change OpenSpec refactor；`tasks.md` 组 2 起用多行正文。
