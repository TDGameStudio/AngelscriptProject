"""Command-line interface for Contract V2 audit, strict validation, and projections."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Sequence

from .audit_v2 import AuditReport, audit_testsource
from .projections_v2 import ProjectionError, write_projections


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="validate_testsource.py",
        description="Audit TestSource AngelScript callables against authored Contract V2.",
    )
    parser.add_argument("--root", type=Path, default=Path("TestSource"), help="TestSource directory")
    parser.add_argument("--contracts", type=Path, help="Contract directory; defaults to <root>/Generation/Contracts")
    parser.add_argument("--tasks", type=Path, help="Task projection directory; defaults to <root>/Generation/Tasks")
    parser.add_argument("--mode", choices=("audit", "strict"), default="audit")
    parser.add_argument("--domain", action="append", default=[], help="Selected source-relative domain prefix; repeatable")
    parser.add_argument("--write-projections", action="store_true", help="Regenerate index.json and per-domain Tasks/*.md")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    parser.add_argument("--max-diagnostics", type=int, default=50, help="Maximum detailed diagnostics in text output")
    return parser


def _json_report(report: AuditReport) -> dict:
    return {
        "mode": report.mode,
        "domains": list(report.domains),
        "clean": report.clean,
        "counts": {
            "sources": report.source_count,
            "contracts": report.contract_count,
            "callables": report.callable_count,
            "diagnostics": len(report.diagnostics),
            "byCode": report.counts_by_code,
        },
        "diagnostics": [
            {
                "code": item.code,
                "severity": item.severity,
                "sourcePath": item.source_path,
                "line": item.line,
                "declaration": item.declaration,
                "message": item.message,
            }
            for item in report.diagnostics
        ],
    }


def _print_text(report: AuditReport, max_diagnostics: int) -> None:
    print(
        f"mode={report.mode} sources={report.source_count} contracts={report.contract_count} "
        f"callables={report.callable_count} diagnostics={len(report.diagnostics)}"
    )
    domains = ",".join(report.domains) if report.domains else "<all>"
    print(f"domains={domains}")
    if report.counts_by_code:
        print("diagnostic-counts " + " ".join(f"{code}={count}" for code, count in report.counts_by_code.items()))
    else:
        print("diagnostic-counts <none>")
    limit = max(0, max_diagnostics)
    for diagnostic in report.diagnostics[:limit]:
        print(diagnostic.format())
    omitted = len(report.diagnostics) - limit
    if omitted > 0:
        print(f"... {omitted} additional diagnostics omitted; use --format json or increase --max-diagnostics")


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    root = args.root.resolve()
    contracts = (args.contracts or root / "Generation" / "Contracts").resolve()
    tasks = (args.tasks or root / "Generation" / "Tasks").resolve()
    report = audit_testsource(root, contracts, mode=args.mode, domains=args.domain)
    projection_failed = False
    if args.write_projections:
        try:
            written = write_projections(root, contracts, tasks)
        except ProjectionError as error:
            projection_failed = True
            if args.format == "text":
                print(f"projections-blocked={error}")
        else:
            if args.format == "text":
                print(f"projections-written={len(written)}")
    if args.format == "json":
        print(json.dumps(_json_report(report), ensure_ascii=False, indent=2, sort_keys=True))
    else:
        _print_text(report, args.max_diagnostics)
    return 0 if report.clean and not projection_failed else 1
