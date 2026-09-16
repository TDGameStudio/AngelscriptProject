# One Host test method proves one scene

## Reusable Insight

A Host test that builds a graph, injects two engines, calls natives, and accounts sites in one method is a serial-proof leftover, not a template. Arrange, act, and assert stay visible. Prefer `ASTEST_AS` for the post-inject script surface.

## Evidence

User 2026-09-16 rejected the packed predecessor Host tests. [host-test-style.md](../drafts/findings/host-test-style.md) lists the current files and the replacement rules. `ASTEST_AS` is the existing inline-source helper in AngelscriptTestMacros.h.

## Boundaries

Disposition: candidate. Do not rewrite archived Host files unless a migrating task splits them. ABI cases may still use raw Prepare buffers.

## Application

When adding `HostScheme` / `HostPerf` or migrating a family file, split freeze, inject, call, failure, and accounting into separate methods. Do not copy Store one-line multi-assert style.

## Sources

Confirmed carryover from host-bind-completion. Canonical truth is the Change tasks.
