## Why

Recent Changes technically complied with the optional Scenario Card grammar while repeatedly omitting useful clause-owned detail. The authoring reference and workflow prompt framed rich detail as something mainly for a "complex" clause and told authors to keep simple clauses compact, while regression tests checked only that the supported Markdown vocabulary existed. That combination made omission the default even when inputs, observables, boundaries, examples, or rule order would help a zero-context reader.

## What Changes

- Make active evaluation of every `GIVEN`, `WHEN`, `THEN`, `AND`, and `BUT` clause the high-priority authoring default.
- Prefer the smallest useful combination of quoted notes, prose, ordered or unordered lists, examples, and tables whenever those forms add durable information.
- Keep all detail optional ordinary Markdown: omit a detail form only when it adds no information, and never add empty or boilerplate placeholders.
- Keep every detail block immediately indented beneath the exact behavior clause it qualifies.
- Align the OpenSpec entry, lifecycle Skills, authoring reference, live generated-instruction configuration, workflow instruction, template, maintained overview mirrors, durable Harness contract, and regression tests with the same policy.
- Enrich the current durable Scenario Cards introduced by the affected recent Changes where meaningful detail is presently missing; archived records remain immutable.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Raise useful clause-owned Scenario detail from an exceptional authoring option to an actively evaluated, preferred default while preserving optionality and ownership boundaries.
- `harness/unreal`: Preserve useful inputs, observables, boundaries, examples, and verification context in the current durable Unreal execution scenarios.
- `angelscript/runtime/startup`: Clarify the current disabled-by-default startup behaviors with clause-owned durable detail.
- `angelscript/testing/baseline`: Clarify the quarantined legacy-test and NewVersion baseline behaviors with clause-owned durable detail.

## Impact

This is a parent-repository authoring-contract change. It updates project-local OpenSpec Skills and references, `openspec/config.yaml`, maintained OpenSpec overview text, the `angelscript` workflow prompt/template, static authoring tests, and current durable specs. It does not change the portable OpenSpec parser or executable, validation profiles, task schemas, Unreal or plugin code, archived Change history, or any public Harness route.
