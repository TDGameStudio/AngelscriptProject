## Establish intent before internal choices

- Understand the user's concrete desired outcome, audience/use, scope and exclusions, known constraints and what success looks like.
- Separate independently deliverable outcomes when needed, but do not prematurely turn a topic into a list of Changes.
- An explicit direction can still leave consequential behavior unsettled. Keep already-confirmed intent rather than reopening it out of habit.

## Explore affected decisions

- Inspect scope, behavior, interfaces, data/ownership, lifecycle, dependencies, compatibility, failures and acceptance where the proposed change affects them.
- Carry valid decisions forward with reasons. Reopen only those invalidated by evidence or the user's new direction.
- Compare viable approaches before asking detailed implementation-dependent choices. Explain why a familiar repository pattern does or does not fit.
- Probe meaningful counterexamples: why a plausible alternative is not chosen, a relevant failure, a costly boundary or how the design could be reversed.
- Tests and proof remain part of design/implementation planning. Do not turn test framework, RED/GREEN procedure or every acceptance detail into a mandatory user question.
- Investigate uncertainties that cannot be settled by preference. A source inspection or bounded experiment is better than asking the user to guess technical facts.

## Recognize poor rounds

- Questions whose prerequisites are unanswered should wait.
- Facts available in source should be investigated rather than asked.
- Short labels without consequences leave the user unable to decide.
- “I do not know” exposes an unresolved choice or investigation; it is not design completion.
- Agreement without evidence or trade-offs is not helpful collaboration.
- A completed round or empty frontier must not trigger a creation/Replan offer before user convergence.
- A record update without a visible updated architecture/terminology explanation does not complete answer processing.
