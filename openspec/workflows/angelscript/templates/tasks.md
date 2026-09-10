---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

<!-- Replace the scaffold with actual inspected interfaces and literal cases.
     Read .agents/skills/openspec/references/tasks.md in this project.
     Keep related tests, implementation and wiring in one bounded outcome.
     Add more permanent IDs and exact dependency entries when needed. -->

## 1. <!-- Deliverable group -->

- [ ] 1.1 <!-- Short outcome title -->

    **Outcome**

    <!-- State the accepted behavior, current gap and explicit exclusions. -->

    **Context and interfaces**

    <!-- Name consumed/produced symbols, signatures and artifact shapes.
    Explain relevant identity, lifetime, ownership, errors and prerequisite
    handoffs. Include a concrete API or data example when it settles a decision. -->

    **Cases**

    <!-- Give literal normal, failure and boundary inputs and expected outputs.
    Distinguish new missing-behavior RED cases from existing regression controls.
    Use prose, a table, fenced fixtures, or a useful combination; remove unused
    forms rather than filling a field matrix. -->

    **Implementation**

    1. <!-- Prepare the related cases; run the selection together and observe
       expected RED for the missing behavior. -->
    2. <!-- Implement the bounded behavior and necessary consumer wiring. -->
    3. <!-- Run the same cases together for GREEN; refactor and reverify if needed. -->

    **Files**

    - `path/to/implementation`
    - `path/to/tests`

    **Verification**

    <!-- State exact working directory and setup. Choose the smallest proving
    scope through the project's impact policy; explain any broader selection. -->

    ```sh
    <exact executable proving command>
    ```

    <!-- State concrete completion conditions and required case coverage.
    Add Evidence only after real execution, with actual results and any shared
    run's task-to-case mapping. All direct detail blocks use four spaces.
    Useful detail may be extensive; no word-count or compactness target. -->
