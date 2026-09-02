---
name: systematic-debugging
description: Evidence-first diagnosis for unexpected behavior, failing verification, flaky automation, or repeated implementation failure. Use before proposing a fix when the root cause is not already demonstrated.
---

# Systematic Debugging

1. Reproduce the smallest failing case and preserve the exact command, environment, output, and first bad boundary.
2. Separate facts from hypotheses. Trace inputs and state across the boundary; compare with a known-good path when available.
3. Rank a small set of falsifiable hypotheses. Change one variable and run the cheapest discriminating check.
4. State the demonstrated root cause before changing production behavior.
5. Add a failing regression test, implement the smallest root-cause fix, then rerun focused and relevant broader verification.

After three failed fixes, stop patching symptoms: discard unsupported hypotheses, re-read the boundary evidence, and reconstruct the model. Record a material technical problem in the change's implementation attachments.

Debug evidence triggers Replan only when it proves a requirement, design boundary, dependency edge, verification contract, or required artifact is wrong. Otherwise create a local follow-up task and continue.
