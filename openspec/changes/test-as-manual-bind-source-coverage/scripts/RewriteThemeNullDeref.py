#!/usr/bin/env python3
"""Lift default-null A*/U* Observe locals into injected parameters with throw-on-null.

Transforms existing handwritten theme .as bodies in place. Does not emit files from CSV.
"""
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from DetectThemeNullDeref import (
    LOCAL_DECL,
    PLAN,
    REPO,
    detect_file,
    function_spans,
    has_deref,
    is_safe_use,
    only_handle_tests,
)


def flagged_locals(body: str) -> list[tuple[str, str]]:
    found: list[tuple[str, str]] = []
    seen: set[str] = set()
    for decl in LOCAL_DECL.finditer(body):
        local_type = decl.group("type")
        local = decl.group("name")
        if local in seen:
            continue
        if not has_deref(body, local):
            continue
        if is_safe_use(body, local):
            continue
        if only_handle_tests(body, local):
            continue
        seen.add(local)
        found.append((local_type, local))
    return found


def param_has_name(params: str, name: str) -> bool:
    return bool(re.search(rf"\b{re.escape(name)}\b", params))


def rewrite_function(
    indent: str,
    rettype: str,
    name: str,
    params: str,
    body: str,
    stem: str,
    newline: str,
    flagged: list[tuple[str, str]],
) -> str:
    new_params = params.strip()
    for local_type, local in flagged:
        if param_has_name(new_params, local):
            continue
        piece = f"{local_type} {local}"
        new_params = f"{new_params}, {piece}" if new_params else piece

    rest_lines: list[str] = []
    drop = {(local_type, local) for local_type, local in flagged}
    for line in body.splitlines(keepends=True):
        match = LOCAL_DECL.match(line)
        if match and (match.group("type"), match.group("name")) in drop:
            continue
        rest_lines.append(line)

    rest = "".join(rest_lines).lstrip("\r\n")
    body_indent = indent + "\t"
    for line in rest_lines:
        stripped = line.lstrip("\r\n")
        if stripped.strip():
            body_indent = stripped[: len(stripped) - len(stripped.lstrip(" \t"))]
            break

    guards: list[str] = []
    for _local_type, local in flagged:
        guards.append(f"{body_indent}if ({local} is null){newline}")
        guards.append(f"{body_indent}{{{newline}")
        guards.append(
            f'{body_indent}\tthrow("{stem} setup: required {local} is null");{newline}'
        )
        guards.append(f"{body_indent}}}{newline}")

    new_body = "".join(guards) + rest
    if new_body and not new_body.endswith(("\n", "\r\n")):
        new_body += newline
    if not new_body.startswith(newline):
        new_body = newline + new_body
    return f"{indent}{rettype} {name}({new_params}){newline}{indent}{{{new_body}{indent}}}"


def rewrite_text(path: Path, text: str) -> str | None:
    hits = detect_file(path, text)
    if not hits:
        return None
    newline = "\r\n" if "\r\n" in text else "\n"
    spans = function_spans(text)
    replacements: list[tuple[int, int, str]] = []
    for indent, rettype, name, params, start, end, body in spans:
        flagged = flagged_locals(body)
        if not flagged:
            continue
        rewritten = rewrite_function(
            indent,
            rettype,
            name,
            params,
            body,
            path.stem,
            newline,
            flagged,
        )
        replacements.append((start, end, rewritten))
    if not replacements:
        return None
    new_text = text
    for start, end, rewritten in reversed(replacements):
        new_text = new_text[:start] + rewritten + new_text[end:]
    return new_text


def main() -> int:
    changed = 0
    skipped = 0
    with PLAN.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    for row in rows:
        path = REPO / row["TargetPath"]
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        new_text = rewrite_text(path, text)
        if new_text is None or new_text == text:
            skipped += 1
            continue
        with path.open("w", encoding="utf-8", newline="") as handle:
            handle.write(new_text)
        changed += 1
    print(f"rewritten_files={changed} unchanged_files={skipped}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
