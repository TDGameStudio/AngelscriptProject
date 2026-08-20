# `/opsx:explore` 是什么

官方文档：`explore.md` / `commands.md`。核心 profile 自带，和 propose / apply / archive 并列。

## 官方定义

它是 **thinking partner，不是生成器**。

做：读代码、比方案、画图、把糊需求磨成可做范围。  
不做：不建 change 目录、不写 proposal/specs/design/tasks、不改代码。

路径：

```text
模糊担心 → /opsx:explore（只聊天）→ 根因 + 2–3 方案 + 推荐
                              → 你点头
                              → /opsx:propose（这时才落盘）
```

官方经验：越糊越该 explore，已经清楚就直接 propose。explore 比直接 propose 慢，清楚的活上它是税。

## 为什么有人评价高

1. 卡在模型最爱“自信填坑”的点上。SINAPTIA：直接 propose “加认证”，模型会自己编登录方式。explore 在还没文件时把填坑权收回来。
2. 比各家 Plan Mode 更会先查再问。Dan Clarke 用一个月后认为这是 killer feature，甚至说 OpenSpec 其实不是 spec-driven，起点是这场对话，spec 是产物。
3. 允许白探索：三条死路不会留下三份垃圾 proposal。

## 本仓库现状

`.agents/skills/openspec-work/SKILL.md` 把官方 explore / propose / apply / archive **合成一个入口**，explore 变成五种用法之一，用 `superpowers:brainstorming`，同一入口还可以“边记边做 / start lean”。

网上吹的开关是：**模糊问题时强制进入只读对话。**  
仓库里的 explore 是：**也可以只想一想。** 弹性更大，约束更弱。

后续改 skill 时：`feature` / `fix` / `refactor` / `improve` / `test` 在需求不清时默认先 explore（不落盘），再写可执行 tasks；不要再把 explore 和 start-lean 混成一条路。
