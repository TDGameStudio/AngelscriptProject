# Grilling Rounds

Load this reference when running interactive brainstorming. Every unconfirmed user-owned decision is recorded, and **every question to the user is a grill round**: a round may include several related independent decisions. Adapt presentation to host rules without losing necessary explanation. Cursor and Codex share the sequence: investigate, send the situation brief in chat, ask, receive answers, acknowledge the updated state, and record what actually happened. Each question owns one clear decision; round size does not limit explanation depth.

## Situation brief before every round

Before calling any question tool, send the situation brief as an assistant message in the conversation so the user can answer without re-reading the history or opening a file. Include the following information; adapt headings to the host's presentation rules:

1. **What I looked at** — the files, records, references, or experiments investigated since the last round, with paths.
2. **How it works today** — when the round touches code, explain the current system as if to someone who has never seen it (see below).
3. **Where we are** — the settled decisions that this round builds on (one line each, `✅ Settled:`), and anything reopened or held.
4. **Why these questions now** — which branch of the design tree just unblocked, and what stays blocked until it is answered.
5. **What I recommend overall** — the shape of the answer set you would choose if the user said "all recommendations".

Sending the brief is a separate action from saving it. A `log.md` entry, shell output containing the text, a link to `design.md`, or a bare form never counts as the chat brief. Items 1 and 3–5 stay compact; the system explanation is as detailed as necessary for a reader unfamiliar with it. Save that explanation in `findings/` too, but retain the decision-critical parts in chat, including code, diagrams or option comparisons when needed. Do not shorten it merely to meet a paragraph quota. Later rounds can focus on changes once the relevant background has actually been explained to the user.

Before sending, identify the topic and selected design or research focus, settled/open decisions, evidence, and what each answer changes. This preparation is not a separate approval step. Deliver state and rationale in chat, not private reasoning. After answers, acknowledge each settled decision and what remains. Answer a direct user question before resuming the round. Do not bundle unresolved organization, naming and behavior choices into one omnibus approval question; host restrictions on approval collection do not excuse skipping the discussion.

### How it works today

Write for a reader who does not know this system. For a technical decision, cover the following in order wherever they apply to the decision. A class-naming question may require a full responsibility, ownership and lifecycle explanation before the names are meaningful. Do not invent code for a non-code question or pad the brief with unrelated mechanisms:

- **Purpose** — what the component is for, in one or two sentences, and who owns it.
- **Lifecycle** — when it is created, initialized, used, torn down; what triggers each step.
- **Call chains** — who calls it (callers, up to the entry point that matters) and what it calls (callees, down to the boundary that matters), drawn as the annotated tree described under "Chain trees" below.
- **Data formats** — the structs, records, messages, or files that flow through it, with field names and the invariants that matter for the decision.
- **Simplified code** — the real control flow condensed into a code block, with the explanation embedded as comments at the exact line it applies to. Keep real identifiers; drop error handling and noise that the questions do not touch.

```cpp
// Simplified from <path/to/File.cpp>:<first>-<last>
<Return> <Subject>::<Method>(<key args>)        // <who calls this and how often; what state it assumes on entry>
{
    for (<Item> : <Collection>)                 // <what the collection is and where it comes from>
    {
        if (<filter>) continue;                 // <what the filter excludes and why; which question could widen or narrow it>
        <Result> r = <Helper>(<Item>);          // <what Result contains and the invariant on its contents>
        <Store>.Add(<key>, r);                  // <who reads Store later and what a missing entry means to them>
    }
}
```

#### Chain trees

Call chains, ownership, and type relationships are drawn as indented trees, never as boxed ASCII diagrams. Each node is one line: the edge label in brackets, the name with the signature that matters, then a `//` comment that explains the node in a full clause — what it does, when it runs, what it carries — written for a reader who has never seen the code. No file names or line numbers in the tree; put those in the simplified code banner instead. The subject of the round is marked `◆`.

Caller tree (entry point down to the subject), then callee tree (subject down to the boundary):

```text
<entry point or trigger>                                   // <what starts this chain and how often>
└─[calls] <Caller>::<Method>(<key args>)                   // <why this frame exists and what it decides before delegating>
   └─[calls] <Subject>::<Method>(<key args>)  ◆            // <the thing this round is about; what it is responsible for>
      ├─[calls] <Helper>(<arg>) → <Result>                 // <what it computes, per what unit, and any filter it applies>
      │  └─[calls] <Leaf>(<arg>) → <Value>                 // <the lowest frame that matters; the invariant it guarantees>
      └─[writes] <Store>.<Op>(<key>, <value>)              // <the data structure written, its shape, and who reads it later>

<Consumer>::<Method>(<key args>)                           // <when the consumer runs and what it needs from the store>
└─[reads] <Store>                                          // <how it looks things up and what happens on a miss>
```

Type or ownership tree:

```text
<PublicType><TemplateParams>                               // <what user code holds and what it promises>
└─[inherits] <BaseType>                                    // <the responsibility the base carries for the derived type>
   ├─[member] <StorageType><Params>                        // <what is stored, its size or capacity, and the fallback path>
   │  └─[inherits protected] <RawStorage>                  // <the lowest layer and what it deliberately does not know>
   └─[member] <Manager>* <name>                            // <what the pointer dispatches and what a null value means>
```

Two fixed rules, the rest is judgement:

- No boxes or frames — indented tree glyphs (`└─`, `├─`, `│`) only.
- Every node gets a `//` comment that actually explains it — a clause or sentence about what it does, when it runs, or what it carries — not a one-word tag, and no file:line.

Everything else adapts to what the reader needs: which edge labels to use (`[calls]`, `[reads]`, `[member]`, `[inherits]`, … or a plain word when clearer), how much of a signature to show, whether callers and callees sit in one tree or two, how deep to go, and whether to split a long chain. Add or drop detail based on what the questions depend on; when a comment outgrows its line, either wrap it under the node or carry the detail into the simplified code block.

Use the [visual-explain](../../visual-explain/SKILL.md) conventions for any other diagram and for code-shape sketches, with the same no-box rule. Every question that follows should point back to a line or item in this explanation, so the user can see exactly what each option would change.

## Design tree and frontier

Map the plan as a design tree: each decision branches into those that depend on it. The **frontier** contains decisions whose prerequisites are settled. Group related independent frontier questions when useful, following the user's pace and actual tool limits; use one question when it needs deep explanation or the others depend on its answer. Do not force a one-question cap, pad a form to its maximum or impose one host's numeric limit on another. Dependent questions wait. Keep remaining decisions in the draft and track replies by question identity, including partial or out-of-order answers.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock dependent questions. Recompute the frontier and ask the next round. Stop when the frontier is empty and the user confirms shared understanding.

## Before a round

- Investigate repository facts first. A running investigation is an unsettled prerequisite: questions downstream of it wait; another unblocked key question may be asked first.
- Separate user-owned product and naming choices from engineering choices the agent can settle with evidence.
- Present a heavyweight or unfamiliar option before asking the user to choose it.
- Ask only questions whose answers can change design, scope, or naming.

## Round shape

Number questions, give the recommended answer and its consequence, and accept numbered, partial, out-of-order, or "all recommendations" replies without forcing the user to restate settled answers. Use the [marker vocabulary](markers.md) and compact structure below. Preserve the situation, evidence, option meanings, recommendation and any material flip condition; host channel restrictions only change how the question itself is presented.

Use compact Markdown: one round heading, situation and current-system explanation, then each decision with its alternatives, recommendation and material flip condition. Headings and explanations default to the user's conversation language, unless the user explicitly requests another language for discussion/drafts. Explain shared background once, while each question keeps its consequences and answer boundary. Explanations may be substantial; compact layout is not a brevity requirement. Explain options in chat before the form. In Codex, pre-form commentary is declarative and actual questions go in the tool. Cursor may show written questions before AskQuestion when permitted. Do not omit comparisons to avoid repeated short labels.

For a focused round, use the shared situation and Q<m> block below. A grouped round also includes Q<n> only when its prerequisites are settled independently; omit the second block otherwise. For example, diagnostic-example formatting and identifier stability may share a round, but ownership and an unresolved ownership-dependent lifetime choice may not.

```markdown
## Round <N> — <topic>

**Situation**

📌 Pinned fact: <what was inspected and what it showed> 🔗 Source: `<path:line>`
📌 Pinned fact: <...>
✅ Settled: Q<i> — <accepted decision>
❌ Dropped: Q<j> — <rejected path, reason>
🔁 Reopened: Q<k> as Q<m> — <which premise the new evidence broke>
⏳ Held: <decision> — <what it waits on>
Why now: <branch that just unblocked>. Still blocked: <branches waiting on this round>.

**How it works today** — explain purpose, lifecycle, caller/callee relationships, data formats and commented simplified code where the decision depends on them; preserve the full explanation in `findings/<topic>.md` too.

**Overall recommendation**: <the answer set if the user says "all recommendations">.

❔ Open decision: **Q<m> — <title>** ⭐ Heavyweight

- **A.** <option — trade-off>
- **B.** <option — trade-off>
- **C.** <option — trade-off>

👉 Recommendation: **A** — <reason>.
❗ Flip condition: <evidence that would reverse it>.

❔ Open decision: **Q<n> — <title>** ✨ New: <what just unblocked it>

- **A.** <option>
- **B.** <option>

👉 Recommendation: **A** — <reason>.
```

Rules that keep it scannable:

- Every marker keeps a plain-text label with the meaning in markers.md; local discussion may translate labels, while Change output uses English. Emoji are presentation only; one marker per line.
- Each question is one `❔ Open decision:` paragraph with the bold `Q<n> — <title>`; the `⭐ Heavyweight` / `✨ New:` marker sits at the end of that line, never inline in prose.
- Options are `- **A.**` bullets, one line each. Consequences that need more than a clause go under the option as an indented sub-bullet. Never indent option lines with four spaces: chat renders that as a code block.
- Recommendation and flip condition are two separate lines directly under the options, so the eye finds them in the same place every time.
- Situation lines stay short; "How it works today" may be long. If the pinned facts exceed five lines, summarize to three and link a `findings/` file. A decision matrix with more than about six rows also goes to `findings/`, and the round lists only the rows the user is likely to change.
- Chat rendering collapses single newlines: always leave a blank line between blocks.

## Collect the answers

Use the current session's actual tool declarations, mode restrictions, and channel rules. The Skill describes the conversation; it cannot enable tools or guarantee how a client renders them.

| Host | After sending the chat brief |
| --- | --- |
| Cursor | Call `AskQuestion` when the host exposes it and permits the question; follow its actual schema. |
| Codex | Send the declarative brief in commentary, then call `request_user_input` when its declaration permits the active mode. Default mode is allowed only when the session exposes that capability; never assume all installations have it enabled. |
| No usable form | Give the brief and ask one concise direct text question in the host-permitted channel. In Codex when commentary questions are forbidden, ask the text question in final. |

For Codex form collection, do not send final before calling the tool: final ends the turn. Keep the question self-contained, with the recommended option first, suffixed `(Recommended)` when the schema calls for it, and short consequences in the option descriptions. A form alone is never a round: the system explanation and option comparison must already have been delivered in chat. Follow the schema's limits and built-in free-text support; do not copy Cursor-specific fields or option formatting into Codex arguments. Host restrictions on required input and approval take precedence: use a plain-text approval when the host requires it, and do not ask again for an already authorized action.

Do not substitute `request_user_input_async` merely because Default mode is active. It sends an asynchronous question message; a tool acknowledgement is not proof of a visible selectable form. Use it only when the current host supports that interaction and asynchronous clarification fits the task. The confirmed Codex form path for this workflow is `request_user_input` when available.

If a form is unavailable, fails, is cancelled, or the user reports that it is invisible, briefly explain and use the text fallback. Do not repeatedly probe the same tool or leave questions only in files. A preselected option, acknowledgement, cancellation, silence or elapsed time is not an answer or approval. Follow host policy for optional clarification and keep any permitted working assumption distinct from a user-confirmed decision. Required input stays pending. With asynchronous questions, continue only work independent of the answer and process the reply when it arrives.

Record the actual brief, submitted question/options, and returned answer verbatim in `log.md`; record asynchronous answers delivered as new user messages the same way. If a blocking call is pending, its tool history holds the question until logging can resume. Never record prepared but unsent text as a presented round. After receiving an answer, reflect the settled choice and any remaining uncertainty in the conversation, update the draft, and recompute the next question.

## Grilling around a proposal draft

In proposal mode, prepare or update the selected designs/<scope>/design.md, then explain evidence, recommendation and unresolved choices in chat. The document preserves the proposal; it does not replace the brief. Topic README owns current focus/mode, while the selected design README owns approval status. Do not re-ask settled decisions or treat recommendations as approval. Fold replies into the owning design and append the shared log.

## The carryover round

For an OpenSpec-selected handoff, the carryover round identifies what this design's Change should keep. List every candidate's source (shared log round or findings file), target (talk for decision rationale; knowledge for reusable insight) and reason. The user confirms, adds or drops candidates; only confirmed entries enter designs/<scope>/handoff.md. Sibling approval and research do not carry over implicitly. Explicit direct work without a Change does not require a Change carryover round.

## Record every round

Append each round to the draft `log.md` **verbatim**: paste the reply exactly as shown to the user — brief, questions, diagrams, proposal text — and paste the user's message exactly as written. Do not summarize, translate, or tidy either side; a summary costs tokens and loses the wording that later rounds refer back to. Record agent findings that answered a held question in `findings/` with their source, again as produced. Settled names go to `glossary.md`. The log is the durable owner of the conversation; the decision-complete handoff carries only settled decisions and classified carryover.

## Rounds need a present user

Never run rounds for task-local implementation uncertainty, and never run them unattended. Unattended continuation does not open brainstorming; a user-owned decision it uncovers goes to `openspec-update-change` replan as a parked open decision and is answered in the next attended round. See the Skill's "Brainstorming needs a present user".
