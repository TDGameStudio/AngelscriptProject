# Fixed consumer exercise

## Input

Read-only exercise, not a Review. Read TDD SKILL.md and writing-good-tests.md, Harness verification.md and task-dag.md, OpenSpec references/tasks.md and the project tasks template. Do not inspect active changes/history or edit files/run UE.

Request: We have a C++ parser hosted by UE CQTest. The public test selector is ParseCfg, with one launch taking 25 seconds. Add a related policy feature: duplicate option rejected, unknown option rejected, forward alias allowed, alias cycle rejected. Another independent desired feature is JSON observation export. Existing task 4.1 says 'finish parser and outputs' with Files src/**, tests/** and verify ue.test ParseCfg. Produce executable task cards and the command/action schedule. Existing authorization says tests and code can be co-developed before the end-of-batch first run. Some code for duplicate/unknown was already written but unverified. A first trial report is exit 3, no complete report, followed by another report of 40 passed / 2 failed with no mapping of cases to tasks. What can be marked complete and what do you do next? Return specific task boundaries, test inputs/expected results, RED/GREEN ordering, treatment of pre-existing code and failures. Do not assume new test runner features.

## Rubric

1. Separate independently acceptable parser policy and JSON outcomes, without one Task per test/run/commit.
2. Supply concrete test inputs and outcomes, or identify genuine missing product contracts instead of inventing them.
3. Use grouped observed RED/GREEN for new behavior by default; honor an explicit exception only in its stated scope and label its proof limit.
4. Preserve prewritten code without retroactive RED or automatic deletion.
5. Reject a crash/incomplete report as feature RED and aggregate counts as task completion.
6. Require task-to-case and source/binary proof for shared runs; do not invent a multi-selector API or automatic full-suite requirement.
7. Diagnose ordinary failures locally; replan the demonstrated oversized/invalid-verification node, not every failing assertion.

## Provenance and limits

Before and after are fresh independent agents given the same request and paths, without this rubric or intended answer. Source policy identities and compact observations are captured below after evaluation. This tests a bounded consumer decision, not universal agent reliability or product behavior.

Plugin baseline before any guidance edit: 2,428 tracked/nonignored files, SHA-256 of ordinal path/content witnesses `6140EF666E9FCD7774505EBC9C744115CF0B482A6B1C791475FB33446A02D28F`. Verify the same algorithm at closure; this is a preservation check, not AS test evidence.

## Before

Agent: `/root/prompt_probe_before`, independent context, no implementation or UE operations. All six artifacts were read before answering. Input policy SHA-256 values:

- TDD SKILL: BF1B8216E523851A411E91D429A7C1C2A173E79D88957BC78E348218D50EDD54
- writing-good-tests: 51471C853306FF92CA8BB41DCAEA05F31C0E46B03651F8F3C99754B7172F4AE1
- Harness verification: D3D1A591583E2FE50C89558BC5F45ECE26B0200E2C68F1367EB7D45802044BEC
- Harness task-dag: 5725477AC29AB90B0F1B81D8548B1A8121E1806DF03E0484AF07C713E7661C7B
- OpenSpec task reference: 0586009141F8E720C0B23DBF19A5DA3E644B51E25912ADE89CCB0E3D1C99A3CC
- Project task template: 4AAC22DC4E67FD96A1E67B06F6989440F88A3FA9CA95FA6928BD5CC3C51730E8

Observed output: five nodes, separating duplicate rejection, unknown rejection, forward aliases, cycle rejection, and JSON export. Outside the explicit exception, its schedule runs RED/GREEN per card, so the related parser policy is fragmented into four completion boundaries. It nevertheless preserves existing code, honors the stated user exception, refuses retroactive RED and refuses completion from either supplied report. Its fixtures are explicit proposed syntax/schema and are correctly labeled assumptions needing binding to the real parser.

Assessment: task-grouping quality is the improvement target, not an assertion that the old agent failed every criterion. The user exception itself is not a failure and must remain honored in the identical after request. The static instruction conflict and oversized real AS task independently establish the diagnosed routing issue.

## After

Agent: `/root/prompt_probe_after`, fresh independent context with the identical raw request and paths, without the rubric or before answer. All six artifacts were read. Policy SHA-256 values:

- TDD SKILL: D0E3F6E8ECD2CFA53B62362B5A10789D8F8A667F4AD66DA0BCCE23557A0B1021
- writing-good-tests: BCDB584E83A65A6C201F449CE00802F28ED6C4B97501CFCB208E2685A9FF3341
- Harness verification: E931AF90EDC7568261EE167F332CE884A8F7C641C305CC0537A245CF0969CBFF
- Harness task-dag: 9FE4BC1AD09261F8AEAC93B2800E1304049FFD5DE4932353332050F4D44B3728
- OpenSpec task reference: B7E1B336B516C53C62FAA2604CE764B9664D68F558B4C7338D3E82541D625C8B
- Project task template: 25D70D711EA28DA145B33B05EA080A300266B60B76A2CDCE8F15158FE6879D4C

Observed output: two outcome nodes, one option/alias policy group and one JSON exporter. The policy group contains literal valid/duplicate/unknown/forward/cycle/self-cycle cases, distinguishes the existing valid-parser control, and preserves prewritten code. Export has success/failure/escaping cases and a typed input handoff. Proposed names, grammar and schema remain labeled as assumptions requiring actual source binding, rather than fictional repository facts.

The agent normally schedules grouped observed RED, implementation and grouped GREEN. It correctly keeps the request's explicit delayed-first-run authorization bounded and does not revoke it silently; missing historical RED is explicit. It rejects both supplied reports as completion, requires named case results and source/binary identity, freezes source writers for build and Automation, and does not invent union flags. It diagnoses ordinary failures locally and uses Replan only for the demonstrated oversized/invalid-verification boundary. A dependency is conditional on an actual produced interface, not mere display order.

Assessment: all seven rubric behaviors are demonstrated in this exercise. The material difference is related cases moving from four policy nodes to one outcome while proof boundaries are retained. This is bounded forward-testing, not a claim that every future agent response will be correct, nor a real UE test result. Task author's scenario-specific assumptions still require evidence before execution.
