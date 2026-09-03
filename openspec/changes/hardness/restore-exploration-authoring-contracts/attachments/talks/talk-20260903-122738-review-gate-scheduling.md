# Review Gate Scheduling

## Context

The marker/carryover increment was implemented and tested quickly, but an immediate second broad Review became the largest elapsed-time component while the user was still refining scope. The problem was Review timing and snapshot organization, not the amount of useful detail in the Review file.

## Evidence

- 📌 Pinned fact: The marker implementation took about four to five minutes and its focused tests about six seconds in this session.
- 📌 Pinned fact: The second reviewer dispatch and wait took about ten to eleven minutes and began before scope was stable.
- 📌 Pinned fact: Both Review files contain useful scope, evidence, reasoning, and historical closure information; their length is not itself a defect.
- ❗ Risk: A reviewer reading the shared live workspace asynchronously can unknowingly review content added after assignment.

## Options

1. Review every task or small increment. Rejected because review overhead becomes the workflow cadence.
2. Review every Change only at the end. Rejected because verified low-impact work does not always justify a reviewer and major incidents may need an earlier independent gate.
3. Use exceptional Incident Review, impact-gated Final Review, and explicit External Review. Accepted because trigger and authority remain clear while detailed evidence is preserved.

## Settled Decision

- ✅ Settled: Start Incident Review only after evidence demonstrates a major problem crossing a safety, compatibility, cross-repository, or prior-evidence boundary.
- ✅ Settled: At scope freeze, require Final Review only for broad impact; verified small low-impact work records `Final Review: not required` with rationale.
- ✅ Settled: Accept user/agent-started External Reviews at any time, but reproduce and triage findings before they affect planning.
- ✅ Settled: Run reviewer subagents asynchronously against immutable snapshots. The main thread may continue disjoint work but cannot close or integrate the affected Change before the applicable gate.
- ✅ Settled: Preserve detailed Review records without a line cap. Reduce repeated scans and premature dispatch, not evidence quality.

## Consequences and Flip Condition

```text
demonstrated major incident ----------------> Incident Review
scope freeze -> broad impact --------------> Final Review
scope freeze -> verified low impact --------> Final Review: not required
user / other agent starts review ----------> External Review intake

fixed snapshot -> async reviewer
moving main workspace -> disjoint work only
reviewed final scope changes -> batch -> one incremental Final Review
```

Revisit this policy only if measured missed defects show that the impact classifier routinely skips necessary independent review, or if immutable asynchronous snapshots cannot be reproduced reliably.

## Sources

- User decisions in the current conversation.
- `.agents/skills/hardness/references/review.md`.
- Closed marker Review: `attachments/reviews/review-20260903-120000-marker-carryover-independent.md`.
