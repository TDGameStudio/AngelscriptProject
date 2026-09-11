# Grilling Rounds

Load this reference when running interactive brainstorming. It replaces the retired threshold that asked questions only when three or more dependent decisions remained: every unconfirmed user-owned decision is asked, and **every question to the user is a grill round** — one question, a naming choice, or a whole frontier all use the same shape. Never ask an ad-hoc yes/no question outside a round, and never let a bare `AskQuestion` form replace the round's written brief.

## Situation brief before every round

Open each round with a short brief so the user can answer without re-reading the history:

1. **What I looked at** — the files, records, references, or experiments investigated since the last round, with paths.
2. **How it works today** — when the round touches code, explain the current system as if to someone who has never seen it (see below).
3. **Where we are** — the settled decisions that this round builds on (one line each, `✅ Settled:`), and anything reopened or held.
4. **Why these questions now** — which branch of the design tree just unblocked, and what stays blocked until it is answered.
5. **What I recommend overall** — the shape of the answer set you would choose if the user said "all recommendations".

The brief is written into `log.md` together with the questions. Items 1, 3–5 stay short; item 2 is as long as it needs to be, and its full text is also saved as `findings/<topic>.md` so later rounds can link instead of repeat.

### How it works today

Write for a reader who does not know this system. Cover, in this order, whatever the questions depend on:

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

Map the plan as a design tree: each decision branches into the decisions that hang off it. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask now without guessing at answers you have not heard. Ask the whole frontier in one round. A question whose answer depends on another question still open in this round belongs to a later round.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock dependent questions. Recompute the frontier and ask the next round. Stop when the frontier is empty and the user confirms shared understanding.

## Before a round

- Investigate repository facts first. A running investigation is an unsettled prerequisite: only the questions downstream of it wait; ask the rest of the frontier now.
- Separate user-owned product and naming choices from engineering choices the agent can settle with evidence.
- Present a heavyweight or unfamiliar option before asking the user to choose it.
- Ask only questions whose answers can change design, scope, or naming.

## Round shape

Number the questions, give the recommended answer and its consequence for each, and accept numbered, partial, out-of-order, or "all recommendations" replies without forcing the user to restate settled answers. Use the [marker vocabulary](markers.md) labels.

Write the round as compact Markdown: one `##` heading for the round, a `**Situation**` block of marker lines, the overall recommendation, then one `❔ Open decision:` paragraph per question with its option bullets and two marker lines. No `###` per question. Keep each line to one or two sentences and move longer evidence into `findings/`.

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

**How it works today** — only when the round touches code; full text in `findings/<topic>.md`, the round keeps purpose, chain tree and simplified code.

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

- Every marker keeps its plain-text label (`Pinned fact:`, `Settled:`, `Recommendation:`, `Flip condition:`) per [markers.md](markers.md); the emoji is presentation only; one marker per line.
- Each question is one `❔ Open decision:` paragraph with the bold `Q<n> — <title>`; the `⭐ Heavyweight` / `✨ New:` marker sits at the end of that line, never inline in prose.
- Options are `- **A.**` bullets, one line each. Consequences that need more than a clause go under the option as an indented sub-bullet. Never indent option lines with four spaces: chat renders that as a code block.
- Recommendation and flip condition are two separate lines directly under the options, so the eye finds them in the same place every time.
- Situation lines stay short; "How it works today" may be long. If the pinned facts exceed five lines, summarize to three and link a `findings/` file. A decision matrix with more than about six rows also goes to `findings/`, and the round lists only the rows the user is likely to change.
- Chat rendering collapses single newlines: always leave a blank line between blocks.

## Collect the answers

After the written round is sent, issue the same questions through the host's structured answer form (`AskQuestion` in Cursor): one form question per `❔ Open decision:`, the same letters and titles, the recommended option first and suffixed `(Recommended)`, multiple selection only when the question allows several picks. The written round is the brief the form points at; a form alone is never a round. If the form is cancelled or the host has no form, accept the answers as text and continue. Record form answers in `log.md` exactly as returned.

## Grilling around a proposal draft

In `proposal` mode the document comes first. Write the `design.md` draft, then run rounds whose questions each name the section they would change ("§3 Data flow — A keep the cache per module (recommended) / B global"). The situation brief is the draft itself plus what you are unsure of; do not re-ask what the draft already states. Settled answers are folded into the draft in place and logged as usual.

## The carryover round

The last round before `handoff.md` asks what the Change should keep from the draft. Its situation brief lists every candidate with source (`log.md` round heading or `findings/<file>`), target (`talk` when the rationale would otherwise be re-decided — the decision was hard to reverse, surprising without context, and a real trade-off; `knowledge` when the insight is reusable beyond this work and has evidence and a boundary), and reason; recommend a selection and let the user confirm, add, or drop. Only confirmed entries go into `Exploration Carryover`; `openspec-create-change` materializes exactly those.

## Record every round

Append each round to the draft `log.md` **verbatim**: paste the reply exactly as shown to the user — brief, questions, diagrams, proposal text — and paste the user's message exactly as written. Do not summarize, translate, or tidy either side; a summary costs tokens and loses the wording that later rounds refer back to. Record agent findings that answered a held question in `findings/` with their source, again as produced. Settled names go to `glossary.md`. The log is the durable owner of the conversation; the decision-complete handoff carries only settled decisions and classified carryover.

## Rounds need a present user

Never run rounds for task-local implementation uncertainty, and never run them unattended. Unattended continuation does not open brainstorming; a user-owned decision it uncovers goes to `openspec-update-change` replan as a parked open decision and is answered in the next attended round. See the Skill's "Brainstorming needs a present user".
