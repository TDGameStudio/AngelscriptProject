# Issue Record

| ID | State | Finding | Required closure |
| --- | --- | --- | --- |
| AS-SWITCH-001 | Source and regression present; fresh linked verification pending | Signed `int` arithmetic in `CompileSwitchStatement()` overflowed near `INT_MAX`, causing incorrect grouping/default emission and risking dense-loop wrap. P066-P069 widen only lowering intermediates. | Run a fresh build, exact Switch owner, ControlFlow parent, and complete SDK prefix; retain the high-end generated sources and terminal report metadata. |

Historical `LANG-CF-005` and `LANG-CF-006` remain the red/green root-cause
record. They are not fresh final evidence for this linked change.
