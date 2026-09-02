#!/usr/bin/env python3
"""Flag Observe_* that default-declare A*/U* locals and then dereference them."""
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[4]
PLAN = REPO / "openspec/changes/test-as-manual-bind-source-coverage/inventory/planned-theme-sources.csv"

OBS_START = re.compile(
    r"(?m)^(?P<indent>\t*)(?P<rettype>[A-Za-z_][A-Za-z0-9_]*)\s+"
    r"(?P<name>Observe_[A-Za-z0-9_]+)\s*\((?P<params>[^)]*)\)\s*\{"
)
LOCAL_DECL = re.compile(r"(?m)^\s*(?P<type>A[A-Z]\w*|U[A-Z]\w*)\s+(?P<name>[A-Za-z_]\w*)\s*;")
ASSIGN = re.compile(r"\b{name}\s*=")
DOT = re.compile(r"\b{name}\s*\.")
IS_NULL = re.compile(r"\b{name}\s+(?:is\s+null|==\s+nullptr|!=\s+nullptr|is\s+[A-Za-z_])")
def throw_guard_re(name: str) -> re.Pattern[str]:
    return re.compile(
        r"if\s*\(\s*" + re.escape(name) + r"\s+(?:is\s+null|==\s+nullptr)\s*\)\s*\{\s*throw\s*\("
    )


def function_spans(text: str) -> list[tuple[str, str, str, str, int, int, str]]:
    spans = []
    for match in OBS_START.finditer(text):
        start = match.end() - 1  # '{'
        depth = 0
        i = start
        while i < len(text):
            ch = text[i]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    body = text[start + 1 : i]
                    spans.append(
                        (
                            match.group("indent"),
                            match.group("rettype"),
                            match.group("name"),
                            match.group("params"),
                            match.start(),
                            i + 1,
                            body,
                        )
                    )
                    break
            i += 1
    return spans


def is_safe_use(body: str, name: str) -> bool:
    if throw_guard_re(name).search(body):
        return True
    assign_re = re.compile(rf"\b{re.escape(name)}\s*=")
    if assign_re.search(body):
        return True
    spawn = re.compile(
        rf"\b{re.escape(name)}\s*=\s*(?:SpawnActor|SpawnPersistentActor|NewObject|ConstructObject)\b"
    )
    if spawn.search(body):
        return True
    return False


def has_deref(body: str, name: str) -> bool:
    return bool(re.search(rf"\b{re.escape(name)}\s*\.", body))


def only_handle_tests(body: str, name: str) -> bool:
    stripped = re.sub(rf"\b{re.escape(name)}\s+(?:is\s+null|==\s+nullptr|!=\s+nullptr|is\s+[A-Za-z_]\w*)", "", body)
    stripped = re.sub(rf"\b{re.escape(name)}\s*;", "", stripped)
    stripped = re.sub(rf"\b{re.escape(name)}\b", "NAME", stripped)
    return "." not in stripped or not re.search(r"NAME\s*\.", stripped)


def detect_file(path: Path, text: str) -> list[str]:
    hits = []
    try:
        rel = path.relative_to(REPO).as_posix()
    except ValueError:
        rel = path.as_posix()
    for _indent, _rettype, name, params, _a, _b, body in function_spans(text):
        for decl in LOCAL_DECL.finditer(body):
            local = decl.group("name")
            if not has_deref(body, local):
                continue
            if is_safe_use(body, local):
                continue
            if only_handle_tests(body, local):
                continue
            hits.append(f"{rel}::{name} local={decl.group('type')} {local}")
    return hits


def collect_hits() -> list[str]:
    hits: list[str] = []
    with PLAN.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    for row in rows:
        path = REPO / row["TargetPath"]
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        hits.extend(detect_file(path, text))
    return hits


def main() -> int:
    hits = collect_hits()
    out_path = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    report = "\n".join(hits + [f"null_deref={len(hits)}"]) + "\n"
    if out_path is not None:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(report, encoding="utf-8")
    sys.stdout.write(report)
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main())
