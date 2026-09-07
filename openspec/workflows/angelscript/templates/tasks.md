---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

<!-- Choose each command through .agents/skills/harness/references/verification.md. Start with the smallest impact-related verification that directly proves the node. When Broader verification is required, state the concrete reason in ordinary Markdown rather than adding a parser field. -->

<!-- Read .agents/skills/openspec/references/tasks.md before filling this template. One node owns an independently testable feature group: keep its related tests, implementation and necessary wiring together. Do not create a node per test/command/commit or leave an unbounded subsystem under one checkbox. Before Ready, supply concrete inputs and expected results, expected missing-behavior RED, interface handoffs and completion evidence. Use only helpful prose, quoted notes, lists or examples; these are not fixed labels. Files must contain the real bounded ownership. -->

## 1. <!-- Deliverable group -->

- [ ] 1.1 <!-- Task title --> — verify: `<exact command or observable outcome>`
  > Files: `<exact/path-a>`, `<exact/path-b>`

  <!-- State the feature outcome/exclusions and actual consumed/produced interfaces. Give literal normal, failure and boundary fixtures with expected outputs/errors as relevant; do not write only "add complete tests". -->

  1. <!-- Prepare related tests first; run the group's selection together and observe the expected missing-behavior RED. Identify existing regression controls separately. -->
  2. <!-- Implement this bounded feature group, including necessary consumer wiring. -->
  3. <!-- Rerun the same selection together for GREEN. All required cases must execute and pass; map cases/results to the task if a documented shared run supplies the proof. Refactor and reverify where needed. -->

## 2. <!-- Next group -->

- [ ] 2.1 <!-- Task title --> — verify: `<exact command or observable outcome>`
  > Files: `<exact/path-c>`

  <!-- Define this independently acceptable outcome and its actual interface dependency. Simple cards may remain short; delete unused commentary. -->

  1. <!-- Concrete test inputs/results and grouped RED when new behavior is required. -->
  2. <!-- Bounded implementation and grouped GREEN with exact completion proof. -->
