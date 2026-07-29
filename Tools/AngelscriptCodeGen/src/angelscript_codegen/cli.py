from __future__ import annotations

import argparse
from importlib import import_module
from pathlib import Path
import sys
from typing import Sequence

from angelscript_codegen.generation.invalid import InvalidProgramGenerator
from angelscript_codegen.generation.valid import ValidProgramGenerator
from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.output.writer import write_cases
from angelscript_codegen.profiles.loader import built_in_profile_directory, load_profile


def _positive_int(value: str) -> int:
    parsed = int(value)
    if parsed < 1:
        raise argparse.ArgumentTypeError("value must be at least 1")
    return parsed


def _uint64(value: str) -> int:
    parsed = int(value)
    if not 0 <= parsed < 2**64:
        raise argparse.ArgumentTypeError("value must be an unsigned 64-bit integer")
    return parsed


def _port(value: str) -> int:
    parsed = int(value)
    if not 1 <= parsed <= 65535:
        raise argparse.ArgumentTypeError("port must be between 1 and 65535")
    return parsed


def default_output_directory() -> Path:
    return Path(__file__).resolve().parents[4] / "Saved" / "AngelscriptCodeGen"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="angelscript-codegen",
        description="Generate reproducible AngelScript test source.",
    )
    commands = parser.add_subparsers(dest="command", required=True)
    generate = commands.add_parser("generate", help="Generate AngelScript source cases.")
    generate.add_argument("--profile", default="native-core")
    generate.add_argument("--kind", choices=("valid", "invalid"), default="valid")
    generate.add_argument("--count", type=_positive_int, default=1)
    generate.add_argument("--seed", type=_uint64, default=0)
    generate.add_argument("--max-depth", type=_positive_int, default=3)
    generate.add_argument("--max-statements", type=_positive_int, default=8)
    generate.add_argument("--out", type=Path)
    serve = commands.add_parser("serve", help="Start the loopback source-preview Web site.")
    serve.add_argument("--port", type=_port, default=8765)
    serve.add_argument("--open", action="store_true")
    return parser


def parse_args(arguments: Sequence[str] | None = None) -> argparse.Namespace:
    return build_parser().parse_args(arguments)


def main(arguments: Sequence[str] | None = None) -> int:
    args = parse_args(arguments)
    if args.command == "generate":
        index_path = generate_cases(
            profile_id=args.profile,
            kind=args.kind,
            count=args.count,
            seed=args.seed,
            max_depth=args.max_depth,
            max_statements=args.max_statements,
            output_directory=args.out or default_output_directory(),
        )
        print(f"Generated {args.count} {args.kind} case(s): {index_path}")
    if args.command == "serve":
        return start_preview_server(port=args.port, open_browser=args.open)
    return 0


def start_preview_server(*, port: int, open_browser: bool) -> int:
    try:
        server = import_module("angelscript_codegen.web.server")
    except ModuleNotFoundError as error:
        if error.name not in {"fastapi", "uvicorn"}:
            raise
        print(
            "网页预览需要可选依赖。请先运行：python -m pip install -e \".[web]\"",
            file=sys.stderr,
        )
        return 2
    return server.run_preview_server(port=port, open_browser=open_browser)


def generate_cases(
    *,
    profile_id: str,
    kind: str,
    count: int,
    seed: int,
    max_depth: int,
    max_statements: int,
    output_directory: Path,
) -> Path:
    profile = load_profile(profile_id, built_in_profile_directory())
    if kind == "valid":
        generator = ValidProgramGenerator(
            profile,
            seed=seed,
            max_depth=max_depth,
            max_statements=max_statements,
        )
        cases = tuple(generator.generate(ordinal=ordinal) for ordinal in range(count))
    else:
        if not profile.invalid_rules:
            raise ValueError(f"Profile '{profile.id}' does not declare any invalid-generation rules.")
        generator = InvalidProgramGenerator(
            profile,
            seed=seed,
            max_depth=max_depth,
            max_statements=max_statements,
        )
        cases = tuple(
            generator.generate(
                ordinal=ordinal,
                rule=profile.invalid_rules[ordinal % len(profile.invalid_rules)],
            )
            for ordinal in range(count)
        )
    return write_cases(cases, output_directory)
