## Establish the question and evidence

- Identify the concrete thing the user wants to understand: a function, responsibility, data representation, transition, workflow or proposed change. Connect it to the problem it solves and its consumers.
- Inspect owning source and nearby entry points before drawing conclusions. Follow relevant references outward to establish boundaries, then use exact symbols and paths to resolve details.
- Read the relevant current specification and owning capability's `knowledges/INDEX.md`, then the matching entry. An absent entry is a possible knowledge gap; an existing unread entry is a retrieval gap. Neither changes source truth. Narrow searches to the owning capability before expanding to external reference material.
- Reuse current evidence rather than repeatedly surveying the repository. Expand when an unanswered causal link or conflicting evidence requires it.
- Distinguish code facts, runtime observations, documentation, historical notes and inference. Prefer the requested version's actual source when historical articles or snippets disagree.
- Separate a step's demonstrated effect from the historical reason someone chose it. Source can establish how a guard protects state; a design record may establish the original trade-off. Without that record, present a plausible rationale as analysis, not the author's documented intent.
- Preserve exact type, function, field, CVar and route names. Do not invent missing callers, defaults, thread affinity or lifetime guarantees.
- Mark uncertainty and give a concrete check: a source symbol, search term, observation point or relevant test. Explain what current evidence already establishes.

## Build one coherent explanation

- Assume no prior familiarity with this system, even when the user is an experienced engineer. Establish the prerequisite concepts that this explanation actually uses; introduce each unfamiliar term or acronym with its plain meaning, responsibility and concrete example before relying on shorthand.
- Explain purpose first: what the component provides, what consumes it and why the mechanism exists.
- Introduce architectural roles before internal detail. Connect each important role to its actual class, module, function or record, explaining what that concrete thing does. Clarify ownership, references and boundaries so later names have meaning; a list of identifiers is not an architecture explanation.
- Trace a representative path from trigger to entry, through important phases, to output and its next consumer. State inputs, outputs, side effects and relevant conditions at each phase.
- Explain caller and callee relationships in both directions around the subject. Include branches that establish behavior or affect the choice, without truncating an important chain at an arbitrary depth.
- Connect the path to object and resource validity: creation, initialization, use, update or rebuild, and release. Show where a path assumes an existing object and who ensures that assumption.
- Define data by what it represents, where it comes from and who reads it next. A list of type names is not a data-flow explanation.
- For code, follow [source walkthroughs](source-walkthrough.md). For controls, threading, memory and runtime observation, select the relevant [focused lens](focused-lenses.md).
- Carry the same example values or objects through stages so the reader can see consequences instead of reconnecting unrelated mini-examples.
- Preserve the causal links between stages: what triggers this step, why it is needed, what it changes and why the next step can proceed. An analogy can introduce a concept, but follow it with the actual mechanism and state where the analogy stops applying.

## Make the design concrete in conversation

- Present enough of the current relevant architecture that the user can understand the question without opening a file or reconstructing earlier messages.
- Explain the current behavior and problem before the proposed change. Mark proposed functions or fields as proposed; use verified names for implemented behavior.
- Compare meaningful options against common criteria: responsibility, behavior, data/ownership, compatibility, cost, failures and reversibility where relevant.
- Attach each option to the relationship, phase or code it changes. Explain unfamiliar alternatives before asking someone to select them.
- After an answer, show the updated relevant architecture, names and relationships. Include what changed, why the chosen behavior follows and which questions remain open.
- A rename changes explanation vocabulary too. Where ambiguity remains, show former term, chosen term and stable responsibility; consistently use the chosen term afterwards.
- Keep current reality and accepted future design distinct. Do not redraw an accepted proposal as already implemented.
- Update key conclusions and provenance in the existing context/design record. Do not require the visible explanation to be copied verbatim into a draft.

## Improve a missing connection for the reader

- When the user says the explanation is unclear, identify the missing distinction from their words and the current example. Investigate discoverable facts yourself; ask a focused clarification only if different interpretations would materially change the explanation.
- Give the confusing term an observable meaning: the actual field, object, event, branch or result that represents it. For example, distinguish recording a cancellation request from a worker receiving it and from evidence that the operation ended; use only the states present in the subject.
- Walk the same small input or object through the relevant transitions. Show a contrasting outcome when it reveals the distinction, then reconnect the example to the complete relevant architecture and real names. A smaller example must not silently replace the user's system with a different design.
- Correct a false premise using source or observations. The user chooses desired behavior, not what the current code already does. Keep a remaining preference separate from an unresolved fact.
- Use the [worked example](worked-example.md) when a concrete model helps. Avoid a compulsory comprehension quiz or another approval step; during Grill return to its actual pending choice after explaining.
- Follow [the improvement loop](improvement.md) to retain the actual signal, classify the owner from evidence, and distinguish factual supplementation from a desired behavior change. Do not require a code regression for a factual article or mark a question resolved just because it was archived.

## Explain a prepared Create or Replan

- Use the presentation contract in Harness's [handoff Gate](../../harness/references/handoff-gate.md); do not create another approval sequence here. A gate question needs the explanation in the conversation before it is asked, even when the draft contains the detail.
- Re-establish the relevant background, present problem and reason for this change so someone can evaluate it without remembering earlier rounds. Follow one representative trigger, input or object through the current architecture and the proposed architecture, showing which responsibilities, relationships, data or behavior change and how that produces the intended result.
- For Replan, distinguish implemented behavior, the previously accepted design and the proposed revision wherever they differ. Explain what evidence invalidated the old expectation and how existing work is affected; a before/after filename list does not explain this.
- Ground unfamiliar names in the concrete roles and call/data paths already introduced. Use annotated ASCII views and faithful code where they carry the explanation; preserve enough surrounding context to understand a changed branch or boundary.
- A reader should be able to explain what happens today, why it needs to change, what will happen afterwards and what the requested decision covers. If the preview cannot support those answers, complete its explanation before asking. Do not replace missing understanding with an “understood?” checkpoint or compress it to a word, paragraph or diagram quota.

## Choose the view after understanding the mechanism

- A call tree explains navigation; annotated code explains actual conditions and operations. Use them together when both are needed.
- Use a data shape when representation matters, a lifecycle or timeline when validity/order matters, and a comparison when a decision changes relationships.
- Keep diagrams adjacent to their explanation. Explain edges and consequences; decorative arrows without semantics add no understanding.
- State what a view depicts: structure, a possible execution path, observed execution, data movement or a proposed change. Mark meaningful ordering and edge types; placement in a structure tree does not prove runtime order, and a state label alone does not prove its external effect completed.
- Prefer unboxed ASCII trees in ordinary conversation. Use the [visual catalog](visual-catalog.md) to select a relevant fragment, never load all categories by default.
- Use focused HTML when navigation, interaction or export improves the result. Preserve readable explanation in chat even when a larger artifact helps.
- Do not automatically produce an article collection, cheat sheet, Draw.io file or second explanation document for a chat question.
