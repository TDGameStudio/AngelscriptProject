# Exploration Marker Vocabulary

Load this reference only when markers make a pre-Change exploration round, comparison, or handoff easier to scan. Markers are optional presentation hints, not a state machine.

## Usage contract

- Use at most one leading marker per line and always follow it with the stable English label below.
- Keep the sentence complete without the emoji. Color, glyph width, or emoji rendering must never carry the only meaning.
- Do not put markers in YAML, filenames, Task DAG IDs/edges, review or issue status fields, or commands.
- Do not parse markers to determine readiness, completion, review state, or knowledge promotion.

## Core decision and evidence markers

| Marker | Stable label | Meaning |
|---|---|---|
| 📌 | `Pinned fact:` | Repository or external evidence investigated by the agent; cite the source and allow correction. |
| ❔ | `Open decision:` | A user-owned decision on the current frontier. |
| 👉 | `Recommendation:` | The single recommended option for that decision, with its reason. |
| ❗ | `Risk:` or `Flip condition:` | A material caveat, constraint, or evidence that would reverse the recommendation. |
| ✅ | `Settled:` | An accepted decision. It never means a test or gate passed. |
| ❌ | `Dropped:` | A rejected option or path, with the reason it should not be retried. |
| 🚫 | `Out of scope:` | An explicit boundary; the excluded option is not necessarily wrong. |
| 💡 | `Knowledge candidate:` | An evidence-backed insight that may be useful beyond the current question. It is not promoted automatically. |
| 🔗 | `Source:` | A dependency, repository path, document, commit, or external source. |
| 📁 | `Affected paths:` | Optional exact paths when a file map materially helps the decision. |

## Round-only navigation markers

These remain conversation navigation. They are kept in the draft `log.md` as part of the round record, but never copied into Change artifacts merely to preserve round state.

| Marker | Stable label | Meaning |
|---|---|---|
| ⭐ | `Heavyweight:` | The decision needs or received full option comparison. |
| ✨ | `New:` | A question or branch newly entered or newly unblocked this round. |
| ⏳ | `Held:` | Waiting for repository research, an external prerequisite, or a prior decision. |
| 🔁 | `Reopened:` | New evidence invalidated an earlier answer; state the invalidated premise. |

Historical `🔴 Reopened` and `🟢 Landed` are deliberately not restored. The visual-explanation system already uses red/green circles for risk or heat, and a green dot does not explain what landed. When a wait ends, record the resulting `📌 Pinned fact:`, mark the unlocked branch `✨ New:`, or mark its final decision `✅ Settled:`.

Verification remains explicit plain text such as `Verification: passed`; it never reuses `✅ Settled:`.

## Durable carryover

After the target Change is created, preserve only accepted carryover:

- A talk may keep `📌 Pinned fact:`, `✅ Settled:`, `❌ Dropped:`, `❗ Flip condition:`, `🚫 Out of scope:`, `🔗 Source:`, and the smallest decision-critical diagram or table.
- Change-local knowledge may keep `💡 Knowledge candidate:`, its evidence, application boundary, and sources.
- Proposal, specs, design, and tasks contain the current settled truth. Marked attachments provide rationale or reusable evidence and never replace those artifacts.
- Temporary `❔`, `⭐`, `✨`, `⏳`, and `🔁` round navigation stays in the draft `log.md` and enters the Change only when the underlying decision or evidence qualifies independently for a talk.
