from __future__ import annotations

import json
from pathlib import Path

import pytest

from angelscript_generation.case_key import (
    CaseKeyError,
    case_key_from_authored_path,
    cpp_symbol,
    fnv1a64_utf8,
    validate_unique_symbols,
)

GOLDEN = Path(__file__).resolve().parents[2] / "goldens" / "fnv1a-casekeys.json"


def test_authored_path_becomes_logical_case_key() -> None:
    key = case_key_from_authored_path("TestSource/Bindings/AActor/Test_Queries_01.as")
    assert key == "TestSource/Bindings/AActor/Test_Queries_01"


def test_windows_and_absolute_paths_are_rejected() -> None:
    with pytest.raises(CaseKeyError) as caught:
        case_key_from_authored_path(r"D:\Workspace\AngelscriptProject\TestSource\Bindings\AActor\Test_Queries_01.as")
    assert caught.value.code == "absolute_path"


def test_cpp_symbol_sanitizes_and_uses_declared_name() -> None:
    key = "TestSource/Bindings/AActor/Test_Queries_01"
    assert cpp_symbol(key, "TS_TS_BIND_AACTOR_001") == "TS_TS_BIND_AACTOR_001"
    assert cpp_symbol("NativeSDK/LANG-FN-PARAM-DIRECTION").startswith("TS_")


def test_fnv1a_matches_golden_vectors() -> None:
    vectors = json.loads(GOLDEN.read_text(encoding="utf-8"))
    for item in vectors["vectors"]:
        assert f"{fnv1a64_utf8(item['text']):016X}" == item["fnv1a64Hex"]


def test_symbol_collision_is_rejected() -> None:
    with pytest.raises(CaseKeyError) as caught:
        validate_unique_symbols(
            [
                ("TestSource/A", "TS_A"),
                ("TestSource/B", "TS_A"),
            ]
        )
    assert caught.value.code == "symbol_collision"
