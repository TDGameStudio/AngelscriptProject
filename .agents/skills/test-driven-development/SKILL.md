---
name: test-driven-development
description: Use when implementing a feature, behavior change, refactor, or bugfix; prove bounded feature groups through observed RED/GREEN before completing work.
---

# Test-Driven Development (TDD)

Prepare the tests for one bounded feature group. Observe their expected failures together. Implement that group, verify it together, then refactor while green.

The invariant is a real behavioral failure before the new behavior, not one test or one process launch per iteration. Batching amortizes execution cost; it does not mean co-developing unlimited code and tests before their first run.

## Select the group before editing

Use the accepted task's concrete outcome, interfaces, test inputs, expected results and completion boundary. A group may include normal, negative and boundary cases needed to prove the same feature. Keep each test focused; several tests can belong to one group. Do not size groups by test count, lines of code, file count or fixed minutes.

If the task says only "finish the parser" or "add complete tests", resolve its boundary before implementation. Independent deliverables or hidden prerequisites need a task-boundary correction; an ordinary failing assertion does not. In this project, follow the [Task authoring contract](../openspec/references/tasks.md) and Harness [verification policy](../harness/references/verification.md).

Before writing tests, read [writing-good-tests.md](writing-good-tests.md). Derive expectations independently, exercise real behavior and name the break each test catches. Do not test private structure, trivial forwarding or source wording just to increase the count.

In this project the card's `**Cases**` block decides the group: group by role, shape by kind, per the [case catalog](../openspec/references/cases.md). Every `new RED` case is written first and observed red in one run; `existing control` runs alongside and stays green; `boundary` is judged as a limit; a `deferred RED until X.Y` case is observed red here, excluded from this card's GREEN set, and cited green by task `X.Y`; a custom role follows the definition its card gives. Kind decides the test's inner shape: a `sequence` is one test with several assertions, an `example-table` is normally one parameterized test whose rows red and green together, a `measurement` compares against its checked-in baseline and is normally a boundary (as a card's only `new RED`, red means the bound is currently exceeded), a `golden` case is red while the expected file is absent or differs, an `absence` case compiles or looks up the listed symbols.

## RED: prove the group's missing behavior

1. Write the related tests before implementing their new behavior. Include useful existing regression controls without calling those controls new RED evidence.
2. Run the smallest reliable selection covering the group. Confirm each claimed RED case actually ran and failed because its required behavior is missing or wrong.
3. Record the command, relevant case identities and expected failures. One execution can establish RED for several cases; one failed case does not prove all others ran or failed correctly.

Compilation errors, fixture crashes, undiscovered cases, timeouts and incomplete reports are setup or execution failures, not behavioral RED. Repair that boundary first. When a new C++ interface prevents execution, introduce only the minimal compilable interface skeleton needed to run the tests; do not implement the tested behavior inside it.

An immediately passing test may be useful characterization or a regression control. Label it honestly; do not change a correct expectation or manufacture a failure to count it as new-behavior RED. If the requested behavior already exists, investigate the premise rather than rewriting it for ceremony.

## GREEN: complete this group

Implement the smallest complete change satisfying the declared group, including necessary interface and consumer wiring. "Smallest" limits scope, not useful implementation volume.

Rerun the same proving selection. All required cases must execute and pass; inspect adjacent failures before declaring the outcome complete. Diagnose local failures, fix the demonstrated cause, and repeat the group's proof. Do not weaken accepted behavior or assertions to obtain green.

Refactor after GREEN, then rerun affected proof. Begin the next group after this outcome is verified; do not postpone feedback to fill a code or test quota. Compatible Ready tasks can share a batch, but each still requires its own acceptance mapping.

## Expensive runners and shared evidence

Separate behavior selection from process scheduling. Related cases can share a RED launch and a GREEN launch; one group is not promised only one total run. Prefer an existing low-cost real-behavior test when it proves the change, but source scans cannot substitute for required C++/UE execution.

For UE, use project Harness routes and one coordinator. Freeze source writers during both build and Automation. A shared run can prove several compatible Ready tasks only when its documented selection covers their cases on the same source/binary snapshot. Record exact task-to-case results; aggregate counts or successful dispatch are insufficient. Do not rerun identical subsets solely for ceremony after valid shared proof.

Scope escalation, completion reuse and post-archive checks belong to the [verification policy](../harness/references/verification.md), not an automatic full-suite gate in this Skill.

## Existing code and explicit exceptions

Preserve pre-existing implementation and user changes. Never automatically delete code because it predates tests, and never claim retroactive RED. Add independent characterization/regression coverage, record the verification gap and validate actual code. Newly discovered defects and subsequent new behavior use grouped RED/GREEN.

A user may explicitly authorize a delayed first run or another exception. Apply it only to the stated scope and record that observed preimplementation RED is absent; it is not strict TDD evidence. A request merely to "batch tests" does not grant that exception. A later user instruction replacing it governs subsequent work without rewriting history.

Throwaway experiments, generated code and configuration-only changes use the accepted task's appropriate proof; do not silently exempt behavior hidden in them. Guidance changes use realistic consumer exercises when behavior matters, plus relevant structural checks. Explain exceptions rather than asserting tests ran when they did not.

## Completion check

- The group has a bounded outcome and concrete behavioral cases, not an open-ended subsystem label.
- Expected RED was observed for new behavior, or the exact authorized exception / pre-existing-code limit is recorded.
- GREEN covers every required case and relevant adjacent contract on the actual verified snapshot.
- Expectations do not reuse production logic; assertions test behavior rather than mocks or wording.
- Commands, case mapping and report state support completion; no missing or incomplete case is treated as passing.

These are proof checks, not extra task state. Keep completion in the project's canonical tasks.md.
