from __future__ import annotations

from pathlib import Path

from angelscript_generation.reload_history import (
    apply_unified_diff,
    extract_version,
    parse_reload_history,
    replay_history,
    reverse_unified_diff,
)


TESTSOURCE = Path(__file__).resolve().parents[3]
SPEC = TESTSOURCE / "HotReload" / "AddModifyLookupFlow.as"


def test_add_modify_lookup_flow_diff_is_the_state_change() -> None:
    history = parse_reload_history(SPEC.read_text(encoding="utf-8-sig"), "TestSource/HotReload/AddModifyLookupFlow.as")
    assert "return 1;" in history.origin
    assert "return 2;" not in history.origin
    assert [item.tag for item in history.versions] == ["root", "body-update"]
    assert extract_version(history, "root") == history.origin
    body_update = extract_version(history, "body-update")
    assert "return 2;" in body_update
    assert "return 1;" not in body_update

    steps = replay_history(history)
    assert len(steps) == 1
    step = steps[0]
    assert step.slug == "body-update"
    assert step.compile == "SoftReloadOnly"
    assert step.before == history.origin
    assert step.after == body_update
    assert apply_unified_diff(step.after, reverse_unified_diff(history.commits[0].diff)) == history.origin
    assert "return 2;" in history.commits[0].diff
    assert apply_unified_diff(history.origin, history.commits[0].diff) == body_update


FAILURE_SPEC = TESTSOURCE / "HotReload" / "FailureKeepsOldCodeAndDiagnostics.as"


def test_failure_keeps_old_code_extracts_broken_version_by_tag() -> None:
    history = parse_reload_history(
        FAILURE_SPEC.read_text(encoding="utf-8-sig"),
        "TestSource/HotReload/FailureKeepsOldCodeAndDiagnostics.as",
    )
    broken = extract_version(history, "broken-type")
    assert history.commits[0].expect == 'compile-fail "MissingType"'
    assert "MissingType GetValue()" in broken
    assert "return 5;" not in broken
    assert "return 5;" in extract_version(history, "root")
    steps = replay_history(history)
    assert steps[0].before == history.origin
    assert steps[0].after == broken
