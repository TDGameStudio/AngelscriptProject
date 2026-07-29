from __future__ import annotations

import json
from pathlib import Path

from angelscript_codegen.lifting.angelscript import lift_case
from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.output.catalog import build_index, case_index_entry


def write_cases(cases: tuple[GenerationCase, ...], output_directory: Path) -> Path:
    case_ids = [case.case_id for case in cases]
    if len(case_ids) != len(set(case_ids)):
        raise ValueError("Generated case IDs must be unique within one output directory.")

    output_directory.mkdir(parents=True, exist_ok=True)
    entries: list[dict[str, object]] = []
    for case in cases:
        filename = f"{case.case_id}.as"
        source = lift_case(case)
        _atomic_write(output_directory / filename, source)
        entries.append(case_index_entry(case, filename, source))

    index_path = output_directory / "index.json"
    _atomic_write(index_path, json.dumps(build_index(entries), indent=2, ensure_ascii=False) + "\n")
    return index_path


def _atomic_write(path: Path, content: str) -> None:
    temporary = path.with_suffix(f"{path.suffix}.tmp")
    temporary.write_text(content, encoding="utf-8", newline="\n")
    temporary.replace(path)
