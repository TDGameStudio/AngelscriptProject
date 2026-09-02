---
name: requesting-code-review
description: "在完成任务、实现重大功能之后，或在合并之前使用，用于验证工作是否满足需求"
---

# 请求代码审查（Requesting Code Review）

派发一个代码审查者子代理（subagent），在问题级联扩散之前把它们抓出来。审查者得到的是为评估而精确构造的上下文——绝不是你会话的历史记录。

**核心原则：** 尽早审查，频繁审查。

## 何时请求审查

**强制：**
- 在子代理驱动开发（subagent-driven development）中的每个任务之后
- 完成重大功能之后
- 合并到 main 之前

**可选但有价值：**
- 卡住时（换个新视角）
- 重构之前（基线检查）
- 修复复杂 bug 之后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派发代码审查者子代理：**

派发一个 `general-purpose` 子代理，填写 [code-reviewer.md](code-reviewer.md) 中的模板

**占位符：**
- `{DESCRIPTION}` - 你所构建内容的简要总结
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- 立即修复"严重"（Critical）问题
- 在继续之前修复"重要"（Important）问题
- 把"轻微"（Minor）问题记下来以后处理
- 如果审查者错了，要反驳（附上理由）

## 示例

```
[刚完成任务 2：添加校验函数]

你：在继续之前，让我先请求代码审查。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[派发代码审查者子代理]
  DESCRIPTION: 添加了 verifyIndex() 和 repairIndex()，覆盖 4 种问题类型
  PLAN_OR_REQUIREMENTS: docs/superpowers/plans/deployment-plan.md 中的任务 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]:
  优点: 架构干净，测试是真实的
  问题:
    重要: 缺少进度指示器
    轻微: 报告间隔使用了魔法数字（100）
  评估: 可以继续

你：[修复进度指示器]
[继续任务 3]
```

## 常见的自我合理化

| 借口 | 现实 |
|------|------|
| "我自己看一下 diff 就行了，不用派发审查者" | 你是协调者——在自己上下文里逐行审查 diff 会烧掉你继续推进工作所需的上下文窗口。派发一个审查者子代理：diff 和评估都留在它的上下文里，只有结论会回到你这里。 |
| "审查者需要我完整的会话历史才能理解这次改动" | 交给它精确构造的上下文，绝不给它你会话的历史。这能让审查者聚焦在工作成果上，而不是你的思考过程上。 |

## 危险信号（Red Flags）

**绝不：**
- 因为"这很简单"就跳过审查
- 忽视"严重"问题
- 带着未修复的"重要"问题继续前进
- 与有效的技术反馈争辩

**如果审查者错了：**
- 用技术理由反驳
- 拿出证明其可行的代码/测试
- 请求澄清

模板见：[code-reviewer.md](code-reviewer.md)
