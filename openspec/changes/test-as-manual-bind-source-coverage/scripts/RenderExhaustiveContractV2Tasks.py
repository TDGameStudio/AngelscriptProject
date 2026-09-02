#!/usr/bin/env python3
"""Render the exhaustive OpenSpec tasks projection from normalized plan JSONL.

This script never reads or writes TestSource. Normalization/review owns semantic
decisions; this renderer only validates the frozen rows and projects them into
the human-reviewable tasks document.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
from typing import Any, Iterable

from jsonschema import Draft202012Validator


DOMAIN_ORDER = {
    "Bindings/TArray": 3,
    "Containers/TArray": 4,
    "Bindings": 5,
    "Containers": 6,
    "Optional": 7,
    "Language": 8,
    "Definitions": 9,
    "Feature": 10,
    "World": 11,
    "Gameplay": 12,
    "HotReload": 13,
    "TestFramework": 14,
    "Debugger": 15,
}


def _canonical_bytes(value: Any) -> bytes:
    return (json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n").encode("utf-8")


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _json_text(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def _domain(source_path: str) -> str:
    relative = source_path.removeprefix("TestSource/")
    parts = relative.split("/")
    if len(parts) >= 2 and parts[0] in {"Bindings", "Containers"} and parts[1] == "TArray":
        return f"{parts[0]}/TArray"
    return parts[0]


def _lines(text: str) -> list[str]:
    return text.replace("\r\n", "\n").replace("\r", "\n").split("\n")


def _bullet_json(label: str, value: Any, indent: str = "  ") -> list[str]:
    return [f"{indent}- {label}: `{_json_text(value)}`"]


def _render_header(manifest: dict[str, Any]) -> list[str]:
    counts = manifest["counts"]
    hashes = manifest["hashes"]
    return [
        "# TestSource Authored Contract V2 — exhaustive review and implementation plan",
        "",
        "> Plan-only gate: this file predesigns the complete refactor. No TestSource source implementation may resume until the user accepts this plan revision or selected normalized row hashes.",
        "",
        f"- Plan revision: `{manifest['planRevision']}`",
        f"- Normalized manifest SHA-256: `{hashes['manifestContentSha256']}`",
        f"- Canonical pre-edit baseline: `{counts['sourceFiles']}` sources / `{counts['currentCallables']}` owner-qualified callables / `{counts['sourceOnlyFiles']}` source-only files",
        f"- Proposed callable tasks: `{counts['proposedCallables']}`",
        f"- Explicit retirement tasks: `{counts['retirements']}`",
        f"- Source-only assertion tasks: `{counts['sourceAssertions']}`",
        f"- Per-file verification tasks: `{counts['sourceFiles']}`",
        f"- Blocker/evidence-resolution tasks: `{counts['blockerTasks']}` across `{counts['blockedRows']}` design-blocked plan rows; runner-blocked rows: `{counts['runnerBlockedRows']}`",
        f"- Total checklist tasks (including `{counts['basePlanTasks']}` record/protocol/full-corpus closure tasks): `{counts['totalChecklistTasks']}`",
        "",
        "## Global execution constraints",
        "",
        "- Writable future source scope is `TestSource/**` plus this OpenSpec only. Plugin, host, Tools, Documents, and C++ runner files are read-only evidence unless the user explicitly widens scope.",
        "- A file cannot be edited until every normalized row for that file is accepted and its recorded pre-edit SHA-256 still matches.",
        "- Each callable task below freezes one semantic name, one exact annotation-plus-declaration block, one immediate English comment, typed input/result/writeback vectors, body constraints, fixture/cleanup, status, blockers, and literal commands.",
        "- Expected values belong in contract vectors. Do not add `Expected*` or `bExpect*` source parameters.",
        "- `Observe_*`, `SurfaceNNN`, `_Nominal`, and generic `ExerciseExpectedFailure` are hard-renamed without aliases unless the row records a framework/reflection-required name and reason.",
        "- Direct lifecycle, ProcessEvent, RepNotify, timer callback, or delegate handler calls cannot substitute for the external driver named by the row.",
        "- Every source callable gets the exact adjacent comment shown by its row. File headers do not satisfy this requirement.",
        "- A design blocker must be resolved by its `D` task before the associated `C` task. `runner-blocked` is allowed but never means compile/runtime/external PASS.",
        "- No executor may invent or weaken a signature, vector, comment, fixture, cleanup action, diagnostic, or fallback. Any change creates a new plan revision and review hash.",
        "",
        "## 0. Plan record and user gate",
        "",
        "- [x] 0.1 Preserve the pre-Contract-V2 and pre-exhaustive OpenSpec histories under `attachments/history/`.",
        "- [x] 0.2 Complete read-only domain audits, both TArray audits, high-risk lifecycle audit, and canonical identity reconciliation.",
        "- [x] 0.3 Reconcile exactly 3,041 source paths and 11,987 current callable identities; exclude 21 phantom audit rows and repair 16 owner misattributions.",
        "- [x] 0.4 Define source-only assertions, normalized row schema, status vocabulary, review hash rules, and deterministic task projection.",
        "- [ ] 0.5 User reviews `attachments/reviews/plan-review-guide.md`, `attachments/contracts/audit-index.md`, this exhaustive task projection, and selected normalized rows.",
        "- [ ] 0.6 Record accepted plan revision/row hashes. This checkbox is the source-implementation gate and must not be inferred from OpenSpec strict validation.",
        "",
        "## 1. Existing Contract V2 infrastructure snapshot — independent acceptance pending",
        "",
        "- [ ] 1.1 Independently re-review the existing `TestSource/Generation/**` Contract V2 implementation against `attachments/reviews/contract-v2-correction-red-green-report.md`; status remains `existing-unaccepted-implementation-snapshot`.",
        "- [ ] 1.2 Add reviewed source-only assertion support, richer coverage/fixture/cleanup/body-plan fields, and normalized-row import only after Task 0.6 is accepted.",
        "- [ ] 1.3 Re-run `python -B -m pytest TestSource/Generation/python/tests -q`; expected accepted baseline is 97 passing tests before new source-only/plan-import tests are added.",
        "- [ ] 1.4 Run `python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode audit --max-diagnostics 0`; before migration it must still report `sources=3041`, `contracts=0`, `callables=11987` and exit non-zero truthfully.",
        "",
        "## 2. Design-blocker protocol",
        "",
        "- [ ] 2.1 Resolve each `D` task using the named evidence; update the exact candidate row, regenerate row/manifest hashes, and return changed rows for review before any associated source task.",
        "- [ ] 2.2 Capture missing exact compile diagnostics without inventing text; preserve phase and post-failure state.",
        "- [ ] 2.3 Resolve line-sensitive Debugger comments with a TestSource-owned line-neutral or paired-expectation decision; plugin/C++ line-map edits remain out of scope.",
        "- [ ] 2.4 Resolve compile/ABI branches such as container returns/reference marshalling by the pre-recorded branch, then update the reviewed declaration rather than silently selecting a fallback.",
        "",
    ]


def _render_blocker(task_id: str, blocker: dict[str, Any]) -> list[str]:
    return [
        f"- [ ] {task_id} — resolve `{blocker['code']}` for `{blocker['field']}`",
        f"  - Reason: {blocker['reason']}",
        f"  - Evidence needed: {blocker['evidenceNeeded']}",
        f"  - Resolution updates row/task: `{blocker['resolutionTaskId']}` and requires a new reviewed row hash.",
    ]


def _render_callable(row: dict[str, Any]) -> list[str]:
    current = row["current"]
    proposal = row["proposal"]
    status = row["status"]
    lines: list[str] = []
    for index, blocker in enumerate(row["blockers"], start=1):
        design_id = re.sub(r"\.(?:C\d{4}|S\d{3})$", f".D{index:03d}", row["taskId"])
        lines.extend(_render_blocker(design_id, blocker))
    lines.extend(
        [
            f"- [ ] {row['taskId']} — `{row['caseId']}/{proposal['subcaseId']}` `{proposal['owner']}::{proposal['semanticName']}` [{status['design']}]",
            (
                f"  - Current identity: `{current['identity']}`; kind `{current['kind']}`; line `{current['line']}`; declaration `{current['declaration']}`."
                if current is not None
                else "  - Current identity: none; this is an explicit high-risk replacement callable introduced after the linked retirement tasks, not a source-only pseudo-function."
            ),
            f"  - Disposition: `{proposal['disposition']}`; required-name reason: `{proposal['requiredNameReason'] or 'none'}`.",
            f"  - Exact adjacent comment ({row['comment']['placement']}): `{row['comment']['exactText']}`",
        ]
    )
    if proposal["declaration"] is None:
        lines.append("  - Exact replacement declaration: none; remove the current aggregate only after its named coverage-transfer rows are accepted. No alias is permitted.")
    else:
        lines.extend(["  - Exact replacement declaration:", "", "    ```angelscript"])
        lines.extend(f"    {line}" for line in _lines(proposal["declaration"]) if line)
        lines.extend(["    ```", ""])
    lines.extend(_bullet_json("Parameters", proposal["parameters"]))
    lines.extend(_bullet_json("Raw return", proposal["returnType"]))
    lines.extend(_bullet_json("Writebacks", proposal["writebacks"]))
    lines.extend(_bullet_json("Body plan", proposal["bodyPlan"]))
    lines.extend(_bullet_json("Prohibited calls", proposal["prohibitedCalls"]))
    lines.extend(_bullet_json("Concrete typed vectors", row["vectors"]))
    lines.extend(_bullet_json("Fixture / invocation / cleanup", row["fixture"]))
    lines.extend(_bullet_json("Coverage evidence", row["coverage"]))
    lines.extend(_bullet_json("Status", status))
    lines.extend(_bullet_json("Static verification", row["verification"]["staticCommands"]))
    lines.append(f"  - Expected static result: {row['verification']['expectedStaticResult']}")
    if row["verification"]["runtimeCommand"]:
        lines.append(f"  - Runtime verification: `{row['verification']['runtimeCommand']}`; expected: {row['verification']['expectedRuntimeResult']}")
    else:
        lines.append(f"  - Runtime verification: no authorized command; {row['verification']['expectedRuntimeResult']}")
    lines.append(f"  - Provenance: `{row['provenance']['auditPath']}` `{row['provenance']['rawPointer']}`; normalized row SHA-256 `{row['provenance']['normalizedRowSha256']}`.")
    return lines


def _render_source_assertion(row: dict[str, Any]) -> list[str]:
    assertion = row["sourceAssertion"]
    lines: list[str] = []
    for index, blocker in enumerate(row["blockers"], start=1):
        design_id = re.sub(r"\.S\d{3}$", f".D{index:03d}", row["taskId"])
        lines.extend(_render_blocker(design_id, blocker))
    lines.extend(
        [
            f"- [ ] {row['taskId']} — `{row['caseId']}` source-only `{assertion['kind']}` [{row['status']['design']}]",
            f"  - Exact source facts: `{_json_text(assertion['exactSourceFacts'])}`",
            f"  - Diagnostic/state contract: `{_json_text(assertion['diagnosticOrState'])}`",
            f"  - Source-level comment: `{row['comment']['exactText']}`",
            f"  - Fixture / cleanup: `{_json_text(row['fixture'])}`",
            f"  - Verification: `{_json_text(row['verification']['staticCommands'])}`; expected: {row['verification']['expectedStaticResult']}",
            f"  - Provenance row SHA-256: `{row['provenance']['normalizedRowSha256']}`.",
        ]
    )
    return lines


def _render_rows(manifest: dict[str, Any], rows: list[dict[str, Any]]) -> str:
    output = _render_header(manifest)
    grouped: dict[str, dict[str, list[dict[str, Any]]]] = {}
    for row in rows:
        domain = _domain(row["sourcePath"])
        grouped.setdefault(domain, {}).setdefault(row["sourcePath"], []).append(row)
    for domain in sorted(grouped, key=lambda value: DOMAIN_ORDER[value]):
        wave = DOMAIN_ORDER[domain]
        output.extend([f"## W{wave:02d}. {domain}", ""])
        for source_path in sorted(grouped[domain]):
            source_rows = sorted(grouped[domain][source_path], key=lambda item: item["taskId"])
            file_id = source_rows[0]["fileTaskId"]
            output.extend(
                [
                    f"### {file_id} — `{source_path}`",
                    "",
                    f"- CaseId(s): `{', '.join(sorted({row['caseId'] for row in source_rows}))}`",
                    f"- Pre-edit source SHA-256: `{source_rows[0]['sourceSha256']}`",
                    f"- Normalized rows: `{len(source_rows)}`; plan states: `{_json_text(sorted({row['status']['design'] for row in source_rows}))}`",
                    "",
                ]
            )
            for row in source_rows:
                output.extend(_render_source_assertion(row) if row["sourceOnly"] else _render_callable(row))
                output.append("")
            verify_id = f"{file_id}.V000"
            domain_command = f"python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain {source_path.removeprefix('TestSource/')} --max-diagnostics 100"
            output.extend(
                [
                    f"- [ ] {verify_id} — after all accepted rows for this file are materialized, verify source hash transition, declaration/comment parity, legacy-name zero scan, vectors/fixture/cleanup coverage, and run `{domain_command}`; expected result is zero strict diagnostics for this exact path while runtime state remains separately truthful.",
                    "",
                ]
            )
    output.extend(
        [
            "## W16. Full-corpus closure",
            "",
            "- [ ] W16.B01.R0001 Regenerate normalized JSONL, manifest, and this task projection twice; the second pass must be byte-identical.",
            "- [ ] W16.B01.R0002 Require exactly 3,041 source contracts, complete disposition for all 11,987 pre-edit current callable identities, and no orphan/duplicate proposed identity.",
            "- [ ] W16.B01.R0003 Require zero source declarations matching forbidden legacy names, zero missing immediate comments, zero hidden Expected parameters, zero unexplained zero-argument entries, and zero compound bool as sole oracle.",
            "- [ ] W16.B01.R0004 Run `python -B -m pytest TestSource/Generation/python/tests -q` and the full strict validator; do not promote compile/runtime/external statuses without their own recorded evidence.",
            "- [ ] W16.B01.R0005 Run `openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive` and `openspec validate test-as-source-generation-rules --type change --strict --no-interactive`.",
            "- [ ] W16.B01.R0006 Request final specification and code-quality reviews, reconcile checked tasks with evidence, and report runner-blocked boundaries without changing plugin/runner scope.",
            "",
        ]
    )
    return "\n".join(output).rstrip() + "\n"


def _load_rows(normalized_root: Path, schema: dict[str, Any], manifest: dict[str, Any]) -> list[dict[str, Any]]:
    validator = Draft202012Validator(schema)
    rows: list[dict[str, Any]] = []
    for item in manifest["domainFiles"]:
        path = normalized_root / item["path"]
        data = path.read_bytes()
        if _sha256(data) != item["sha256"]:
            raise ValueError(f"hash drift: {path}")
        for line_number, line in enumerate(data.decode("utf-8").splitlines(), start=1):
            if not line.strip():
                continue
            row = json.loads(line)
            errors = sorted(validator.iter_errors(row), key=lambda error: list(error.path))
            if errors:
                first = errors[0]
                raise ValueError(f"{path}:{line_number}: schema error at {list(first.path)}: {first.message}")
            rows.append(row)
    return rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--normalized-root", type=Path, required=True)
    parser.add_argument("--tasks", type=Path, required=True)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    normalized_root = args.normalized_root.resolve()
    manifest_path = normalized_root / "manifest.json"
    schema_path = normalized_root / "plan-row-schema.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    rows = _load_rows(normalized_root, schema, manifest)

    if len(rows) != manifest["counts"]["normalizedRows"]:
        raise ValueError(f"row count drift: manifest={manifest['counts']['normalizedRows']} actual={len(rows)}")
    if len({row["planRowId"] for row in rows}) != len(rows):
        raise ValueError("duplicate planRowId")
    if len({row["taskId"] for row in rows}) != len(rows):
        raise ValueError("duplicate taskId")

    tasks_text = _render_rows(manifest, rows)
    tasks_bytes = tasks_text.encode("utf-8")
    expected_hash = manifest["hashes"]["tasksSha256"]
    actual_hash = _sha256(tasks_bytes)

    if args.check:
        if not args.tasks.exists() or args.tasks.read_bytes() != tasks_bytes:
            raise ValueError(f"tasks projection drift: expected bytes with sha256={actual_hash}")
        if actual_hash != expected_hash:
            raise ValueError(f"tasks hash drift: manifest={expected_hash} actual={actual_hash}")
        print(f"PASS rows={len(rows)} tasksSha256={actual_hash}")
        return 0

    args.tasks.write_bytes(tasks_bytes)
    print(f"WROTE {args.tasks} rows={len(rows)} tasksSha256={actual_hash}")
    if expected_hash and expected_hash != actual_hash:
        print("WARNING: update manifest hashes.tasksSha256 after reviewed generation", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
