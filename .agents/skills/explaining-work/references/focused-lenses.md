## Ownership and lifecycle

- Use when validity, resource management or responsibility affects the question.
- Identify core class/module, collaborators, resource owners and scheduling responsibilities. Distinguish ownership from a non-owning reference, handle, lookup or cached pointer.
- Connect creation, initialization, use, update/rebuild and destruction to actual functions/events.
- Explain when values may be absent, stale or replaced, who ensures validity and which consumer assumes it. Include thread affinity when relevant and supported.
- Select fields that reveal the mechanism; explain meanings and transitions rather than imposing a fixed field count.

## Data and memory

- Explain represented information, origin, transformations/encoding, caching/indexing, invariants and the next reader.
- Show a skeleton type, representative record or layout when it clarifies behavior. Keep real fields; distinguish declared/measured layout from a conceptual sketch.
- Include states, enums, counters or flags when they make a transition observable. Normal/abnormal comparisons need evidence.
- Use the same example data through the path so results are traceable to inputs.

## Threads, devices and networks

- Show execution ownership and handoff across relevant threads, CPU/GPU, processes or server/client boundaries.
- Separate enqueueing from execution and submission from completion. Explain synchronization, lifetime protection and data crossing boundaries.
- Include shader inputs/outputs or serialization when part of the question, not as a compulsory UE section.
- A timeline needs lifetimes and relevant state changes, not just arrows between function names.

## Controls and observation

- Inspect relevant CVar, configuration, macro, flag, logging, Stats or Trace controls when they select behavior or enable observation.
- For each included control, give its exact name, purpose, supported value/condition, affected path, how to confirm effect and relevant lifetime/thread restrictions supported by source.
- State verified defaults as defaults; label suggested diagnostic values as suggestions. Do not invent a CVar because the topic is Unreal.
- Explain controls beside the code branch or phase they govern, with a comparison or lookup table when useful.
- Describing a control does not execute it. Use selected-workspace Harness routes for authorized Unreal activity; do not copy old build commands from reference prompts.

## Debug walkthrough

- Use when the user wants to observe a mechanism or a claim needs runtime confirmation.
- Give function/file/module, thread, trigger, breakpoint/observation point, values to inspect and next step.
- Explain necessary diagnostic switches and how to verify activation. Conditional breakpoints require real fields/conditions.
- Tie each observation to a claim. For unexpected failures, use systematic-debugging rather than presenting a plausible story as proof.
- A complete debugging handbook or cheat sheet is a requested artifact, not a default.

## Algorithms and mathematical models

- Carry a bounded concrete example through meaningful steps or frames.
- Explain state changes and causes, invariants, termination and relevant trade-offs. Define symbols and assumptions in formulas.
- Distinguish an illustrative model from the production algorithm. A simulation is not evidence of production execution.
- Reuse existing views; a new subject does not require a new diagram category.
