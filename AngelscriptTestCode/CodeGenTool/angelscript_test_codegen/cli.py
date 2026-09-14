"""Command parsing, messages, and stable process exit codes."""

from __future__ import annotations

import argparse
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
import sys
from typing import Sequence, TextIO

from .model import CodegenError, SyncPlan
from .paths import CodegenPaths
from .sync import apply_sync_plan, build_sync_plan


def _make_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="codegen.py",
        description="Synchronize checked-in C++ projections for AngelScript test code.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser(
        "generate", help="write desired projections and remove safe stale projections"
    )
    subparsers.add_parser("check", help="report projection drift without writing")
    return parser


def _default_paths() -> CodegenPaths:
    return CodegenPaths.from_tool_file(Path(__file__).resolve().parents[1] / "codegen.py")


def _report_plan(plan: SyncPlan, output: TextIO) -> None:
    for label, paths in (
        ("missing", plan.missing),
        ("changed", plan.changed),
        ("stale", plan.stale),
        ("unsafe-extra", plan.unsafe_extra),
    ):
        for relative_path in paths:
            print(f"{label}: {relative_path}", file=output)


def main(
    argv: Sequence[str] | None = None,
    *,
    paths: CodegenPaths | None = None,
    stdout: TextIO | None = None,
    stderr: TextIO | None = None,
) -> int:
    output = stdout if stdout is not None else sys.stdout
    error_output = stderr if stderr is not None else sys.stderr
    parser = _make_parser()
    try:
        with redirect_stdout(output), redirect_stderr(error_output):
            arguments = parser.parse_args(list(argv) if argv is not None else None)
    except SystemExit as error:
        return int(error.code)

    selected_paths = paths if paths is not None else _default_paths()
    try:
        plan = build_sync_plan(selected_paths.author_root, selected_paths.generated_root)
        if arguments.command == "check":
            if plan.is_clean:
                print("Test-code generated projections are synchronized.", file=output)
                return 0
            _report_plan(plan, output)
            return 1

        apply_sync_plan(plan)
        final_plan = build_sync_plan(selected_paths.author_root, selected_paths.generated_root)
        if final_plan.is_clean:
            print("Test-code generated projections are synchronized.", file=output)
            return 0
        _report_plan(final_plan, output)
        return 1
    except (CodegenError, OSError) as error:
        print(f"error: {error}", file=error_output)
        return 2
