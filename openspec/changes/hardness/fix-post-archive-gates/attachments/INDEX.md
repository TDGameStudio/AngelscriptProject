# INDEX

## Current position

The completed Hardness dogfood archive remains immutable. A post-archive Quick run exposed four fixture-lifecycle failures, all traced to reusable tests depending on the former active path. The implementation now uses a hermetic temporary Task Graph for default TaskStatus performance sampling and audits the original Review/Replan history at its fixed archive path. Quick passes `10/10`, Performance passes `2/2`, raw artifacts remain ignored, and the accepted privacy-trimmed follow-up aggregate is retained below. Independent fixed-snapshot review is closed with `APPROVE`, the durable delta is synchronized into `openspec/specs/hardness/core/`, and all five Task DAG nodes are complete. The record is ready for the CLI's completed archive move, strict historical validation, and one post-move non-destructive Quick gate.

## Hard conclusions

- `task.status` remains an active execution primitive; it does not read archived tasks.
- Default performance measurement is hermetic; explicit `-TaskChange` intentionally selects an active project record.
- The old active-change TaskStatus baseline and the new hermetic-fixture TaskStatus series are not directly comparable.
- Raw machine-specific samples remain ignored; accepted aggregate statistics and raw hashes are durable change evidence.
- Completed archives are immutable. A post-move defect creates a follow-up change rather than an archive edit.
- No OpenSpec executable, `Tools/openspec` gitlink, Unreal Engine code, build, or test belongs to this repair.

## Attachment index

- `implementation/post-archive-regression.md` — reproduction, cause, repair boundary, and verification summary.
- `data/hardness-performance-post-archive-20260903-072834.json` — accepted privacy-trimmed PS5/PS7 aggregate for the hermetic TaskStatus fixture; SHA-256 `fc2fd5aaaf3b6cf347ca62480906389deb949df268f7adb679b81f5940facba0`, with source and raw-artifact hashes. It links, but does not replace, immutable predecessor aggregate SHA-256 `7a59c05d964dc4e7f2732219d4245f587d81e636ffd8fe4bb517aff13e78efd5`.
- `reviews/review-20260903-073806-post-archive-gates.md` — closed independent `APPROVE` review of fixed commit `6deb443f`, aggregate/raw/source hashes, archive immutability, cleanup containment, and package history; SHA-256 `73a8f99056eab4dbf70e69499a9ba78f31dc64ca50ea636016fe3bb65e694996`.
