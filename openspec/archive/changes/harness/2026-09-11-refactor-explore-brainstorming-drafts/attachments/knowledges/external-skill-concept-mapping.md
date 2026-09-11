# Knowledge candidate: mapping external skill concepts onto project records

Disposition: candidate.

## Reusable Insight

When adopting a skill from an external repository, do not copy its file layout; map each of its concepts onto the project record that already owns that responsibility, and keep only the interaction pattern. The two sources adapted in this Change mapped as follows:

| External concept | Source | Project record or rule |
| --- | --- | --- |
| Grilling frontier, numbered questions, recommended answers | mattpocock `grilling` | `brainstorming/references/grilling.md`; every user question is a round |
| `CONTEXT.md` glossary maintained inline | mattpocock `domain-modeling` | draft-local `glossary.md`; names then flow to tasks "Context and interfaces" |
| ADR only when hard to reverse, surprising, real trade-off | mattpocock `domain-modeling` | admission test for `attachments/talks/` |
| HARD-GATE, "too simple" anti-pattern, section-by-section design approval, self-review, single terminal skill | superpowers `brainstorming` | `brainstorming/SKILL.md` skeleton; terminal skill is `openspec-create-change` |
| Stateless `grill-me` / `grill-with-docs` wrappers | mattpocock | not adopted — the draft is the state |

## Evidence

- `Reference/mattpocock-skills` @ `3cca18b368ae95cdbdebbff572ccafa662551015` and `Reference/superpowers` @ `b36e0829c6d0140e93cfef2ca599b1b07d4a7797`, both MIT, pinned in `Tools/PullReference/PullReference.bat`.
- The resulting Skills pass `quick_validate.py` and the scoped `OpenSpecSkill.Tests.ps1` (task 1.1, 3.1, 4.1 Evidence).

## Boundaries

- Applies to process or workflow skills. Tooling skills with scripts (for example the superpowers visual companion server) need a separate decision about vendoring code.
- The mapping is only valid while the project records named in the table exist with the same ownership.

## Application

Before adapting another external skill: read its SKILL.md, list its concepts in a `findings/external-references.md` inside the brainstorming draft, fill the right-hand column with the owning project record, and treat any empty cell as a grill question rather than a reason to add a new file.

## Sources

- `openspec/drafts/harness/brainstorming-drafts/findings/external-references.md`
- `Reference/README.md` — "Skill-design research snapshots"
