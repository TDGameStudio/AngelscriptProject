# Attachments: INDEX.md Template & Per-Directory Rules

This file owns the `attachments/INDEX.md` contract and the full rules for each of the six directories.

## INDEX.md

Overwrite-style, **≤120 lines**, the sole default loading entry for a change: a new session reads this one file first and opens other attachments only when the index points to them — never bulk-loads `attachments/`. Four sections; every attachment file gets exactly one index line (directory-level summaries are not enough to route a reader), and index lines count against the 120-line budget — when it no longer fits, merge or trim attachments, never relax the budget. No parallel state files (`*-next.md`, `*-leftover-*.md`): the current state lives here and only here.

### Template

```markdown
# INDEX

## Current position
<where work stands · next step · resume point — a few lines>

## Hard conclusions
- <settled decision, no longer up for debate>

## Forbidden
- <what must not be done and why — "don't go down this path again">

## Attachment index
- knowledges/<file> — <one-phrase summary> — <when to read it>
- reviews/<file> — <one-phrase summary> — <when to read it>
- implementation/<file> — <one-phrase summary> — <when to read it>
<one line per attachment file, grouped by directory>
```

Update it in the same stroke that adds or substantially changes an attachment, and before ending any session.

## knowledges/

- **One file =** one theme's currently-valid knowledge (or one external reference), revised in place when facts change. Admission test: "will this be looked up again later?"
- **Filename:** `<theme>.md`, or with a category prefix: `research-` (active investigation) / `audits-` (survey of current state) / `comparison-` (option or implementation comparison) / `references-` (external repos, docs, upstream PRs). No timestamp.
- **Header (mandatory):** `topic` / `source` / `verified_at` / `against` / `confidence` — the last two distinguish "confirmed against a specific source version" from "inferred from docs".
- **Body:** only currently-valid statements; when facts change, edit the text — no errata log.
- **`.html` allowed**, three constraints: static single file (double-click renders fully — no server, network, build, CDN links, `_files/` sidecars, or fetched content; inline JS is optional enhancement only) · a same-name `.md` sidecar is mandatory (what it is / source / key conclusions / when to open the HTML) · ≤500 KB — slim it down if over (big images to `data/`, drop unused libraries, prefer `.svg` for diagrams).
- **Boundary:** artifacts of a particular run (automation `index.html`, coverage reports, benchmark exports) go to `data/`, not here.

## reviews/

- **One file =** one review of one point-in-time state. This is the asynchronous review channel: a reviewer (subagent or another agent) records findings against a fixed state while the main agent keeps working; the file carries the handoff, the per-finding status field carries the follow-up. Timestamped filenames let parallel reviews land without conflict.
- **Filename:** `review-<YYYYMMDDHHmm>-<theme>.md`.
- **Structure:** header (what was reviewed, against which state/commit, scope) → overall verdict → numbered findings, each with a status field (`open` / `fixed` / `rejected` / `deferred`).
- **Hard rules:** status write-back never rewrites history — when a finding is handled, change its status field, never delete the entry · reviews do not track tasks — a finding that needs code change opens an entry in `implementation/` referencing the finding number, otherwise reviews grow into a second tasks.md.

## implementation/

- **One file =** one issue's full lifecycle: symptom → diagnosis → disposition → final evidence.
- **Filename:** `issue-<YYYYMMDDHHmm>-<theme>.md`.
- **Structure:** symptom → what was tried and observed (chronological) → disposition → final-state evidence.
- **Hard rules:** evidence is a **run-ID path** (e.g. `Saved/Tests/<label>/<runid>/Report/index.json`), never "tests passed" · record **RED and GREEN** both · conclusions state **what they prove and what they do not** (a true total can still carry a false attribution) · record **rejected evidence** too, with path and rejection reason · **no second checkbox list** — all checking-off lives in `tasks.md`.

## talks/

- **One file =** one discussion, one topic. A discussion that changed direction is worth an entry even without a final decision — this is the decision trail: how conclusions were reached and overturned.
- **Filename:** `talk-<YYYYMMDDHHmm>-<theme>.md`.
- **Structure (four parts):** what was asked / what was found / what was decided / what remains open.
- **Hard rules:** append-only — to overturn an earlier conclusion, add a new entry naming the one it replaces, never edit the old text · once a conclusion stabilizes, promote it to `design.md` and mark the original entry as promoted · "what remains open" is the resume point for the next session.

## scripts/

- **One file =** one script written along the way, one-off or reusable.
- **Filename:** free, named for the script's purpose. No timestamp.
- **Header comment:** purpose, usage, dependencies — enough to rerun it months later.

## data/

- **One file =** one dataset, matrix, catalog, or trimmed log — text-first, excerpts not raw dumps. Trimmed evidence keeps past conclusions verifiable.
- **Filename:** free, named for content. No timestamp.
- **Hard rules:** a single file over **100 KB or 1000 lines must be trimmed** before entering git · trimming keeps three things — source run ID, trim rationale, original line ranges — all three present makes the trim reversible · raw logs never enter the repo in raw form · trimming happens **before archive** (archive does no cleanup).
