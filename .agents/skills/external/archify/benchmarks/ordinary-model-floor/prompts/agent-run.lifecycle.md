# Agent-run lifecycle

Use the Archify skill in this repository to create a lifecycle diagram for an agent run. Show the main ordered phases from queued through planning, execution, review, and completion. Execution may pause for human approval or fail recoverably. Review may block while waiting for input. A blocked run may expire, and a waiting approval may be cancelled by the user. Terminal exits must remain distinct from active and waiting states.

Author a fresh typed JSON diagram specification targeting the `showcase` quality profile. Choose your own stable internal IDs and layout. Keep active work, interruptions, recovery, and terminal outcomes legible. Use the bundled Archify CLI to validate and repair the candidate when shell access is available. The external harness will independently validate the frozen candidate.

Write the final candidate to exactly `benchmark-candidate.json` in the repository root. Do not edit any other file. The candidate file, not the prose response, is the attempt 1 artifact. Do not copy a checked-in example. Do not claim that validation passed.
