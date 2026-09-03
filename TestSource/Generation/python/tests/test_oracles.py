from __future__ import annotations

import pytest

from angelscript_generation.oracle import oracle_bytes, validate_oracle
from angelscript_generation.schema import SchemaError


def test_int_width_is_preserved() -> None:
    oracle = validate_oracle({"kind": "int", "payload": {"width": 64, "value": "-1"}})
    assert oracle["payload"]["width"] == 64
    assert oracle["payload"]["value"] == "-1"


def test_float_bits_do_not_coerce_to_int() -> None:
    oracle = validate_oracle(
        {"kind": "float", "comparison": "bits", "payload": {"bitPattern": "3FF0000000000000"}}
    )
    assert oracle["comparison"] == "bits"
    assert "value" not in oracle["payload"] or oracle["payload"].get("bitPattern")


def test_unknown_kind_fails() -> None:
    with pytest.raises(SchemaError) as caught:
        validate_oracle({"kind": "ExpectedInt"})
    assert caught.value.code == "invalid_oracle_kind"


def test_oracle_bytes_are_canonical() -> None:
    first = oracle_bytes({"kind": "bool", "payload": {"value": True}, "comparison": "exact"})
    second = oracle_bytes({"comparison": "exact", "kind": "bool", "payload": {"value": True}})
    assert first == second
