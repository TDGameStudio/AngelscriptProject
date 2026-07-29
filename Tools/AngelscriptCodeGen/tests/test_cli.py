from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.cli import main, parse_args
import angelscript_codegen.cli as cli


def test_generate_command_uses_documented_defaults() -> None:
    arguments = parse_args(["generate"])

    assert arguments.command == "generate"
    assert arguments.profile == "native-core"
    assert arguments.kind == "valid"
    assert arguments.count == 1
    assert arguments.seed == 0
    assert arguments.max_depth == 3
    assert arguments.max_statements == 8
    assert arguments.out is None


def test_generate_command_accepts_reproducibility_and_output_options() -> None:
    arguments = parse_args(
        [
            "generate",
            "--profile",
            "ue-world",
            "--kind",
            "invalid",
            "--count",
            "4",
            "--seed",
            "424242",
            "--max-depth",
            "5",
            "--max-statements",
            "13",
            "--out",
            "D:/Temp/generated",
        ]
    )

    assert arguments.profile == "ue-world"
    assert arguments.kind == "invalid"
    assert arguments.count == 4
    assert arguments.seed == 424242
    assert arguments.max_depth == 5
    assert arguments.max_statements == 13
    assert arguments.out == Path("D:/Temp/generated")


@pytest.mark.parametrize("seed", ["-1", str(2**64)])
def test_generate_command_rejects_non_uint64_seed(seed: str) -> None:
    with pytest.raises(SystemExit):
        parse_args(["generate", "--seed", seed])


def test_main_generates_indexed_valid_cases_in_the_requested_directory(tmp_path: Path) -> None:
    output = tmp_path / "valid"

    result = main(
        [
            "generate",
            "--profile",
            "ue-annotated",
            "--count",
            "2",
            "--seed",
            "99",
            "--out",
            str(output),
        ]
    )

    index = json.loads((output / "index.json").read_text(encoding="utf-8"))
    first_path = output / index["cases"][0]["path"]

    assert result == 0
    assert len(index["cases"]) == 2
    assert index["cases"][0]["expected"] == "compile-pass"
    assert index["cases"][0]["verification"] == "source-only"
    assert "UCLASS()" in first_path.read_text(encoding="utf-8")


def test_main_generates_invalid_cases_using_profile_rules(tmp_path: Path) -> None:
    output = tmp_path / "invalid"

    result = main(
        [
            "generate",
            "--kind",
            "invalid",
            "--count",
            "2",
            "--out",
            str(output),
        ]
    )

    index = json.loads((output / "index.json").read_text(encoding="utf-8"))

    assert result == 0
    assert [case["invalid_rule"] for case in index["cases"]] == ["syntax-error", "unknown-symbol"]
    assert all(case["expected"] == "compile-fail" for case in index["cases"])


def test_main_repeats_the_same_request_with_byte_identical_output(tmp_path: Path) -> None:
    first = tmp_path / "first"
    second = tmp_path / "second"
    arguments = [
        "generate",
        "--profile",
        "ue-world",
        "--count",
        "3",
        "--seed",
        "8848",
        "--max-depth",
        "4",
        "--max-statements",
        "6",
    ]

    assert main([*arguments, "--out", str(first)]) == 0
    assert main([*arguments, "--out", str(second)]) == 0

    assert sorted(path.name for path in first.iterdir()) == sorted(path.name for path in second.iterdir())
    for path in first.iterdir():
        assert path.read_bytes() == (second / path.name).read_bytes()


def test_serve_command_is_loopback_only_and_exposes_a_port_and_open_option() -> None:
    arguments = parse_args(["serve", "--port", "9123", "--open"])

    assert arguments.command == "serve"
    assert arguments.port == 9123
    assert arguments.open is True


def test_serve_reports_how_to_install_the_optional_web_extra_when_fastapi_is_missing(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    def missing_web_server(_name: str) -> object:
        error = ModuleNotFoundError("No module named 'fastapi'")
        error.name = "fastapi"
        raise error

    monkeypatch.setattr(cli, "import_module", missing_web_server)

    assert main(["serve"]) == 2
    assert ".[web]" in capsys.readouterr().err
