---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

<!-- Choose each command through .agents/skills/harness/references/verification.md. Start with the smallest impact-related verification that directly proves the node. When Broader verification is required, state the concrete reason in ordinary Markdown rather than adding a parser field. -->

## 1. <!-- Deliverable group -->

- [ ] 1.1 <!-- Task title --> — verify: `<exact command or observable outcome>`
  > Files: `<exact/path-a>`, `<exact/path-b>`

  1. <!-- Add the failing behavior test and observe the expected failure. -->
  2. <!-- Implement the smallest complete change. -->
  3. <!-- Run the exact verification command. -->

## 2. <!-- Next group -->

- [ ] 2.1 <!-- Task title --> — verify: `<exact command or observable outcome>`
  > Files: `<exact/path-c>`

  1. <!-- One executable action. -->
  2. <!-- Exact verification. -->
