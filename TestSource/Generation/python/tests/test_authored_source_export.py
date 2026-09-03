from __future__ import annotations

from pathlib import Path

import pytest

from angelscript_generation.authored import export_authored_case, load_authored_index, load_authored_rule
from angelscript_generation.schema import SchemaError

WORKSPACE = Path(__file__).resolve().parents[4]


def test_index_lists_614_case_keys() -> None:
    index = load_authored_index()
    assert index["count"] == 614
    assert len(index["entries"]) == 614


def test_v1_rule_cannot_drive_active_authored_export_without_v2_contract() -> None:
    rule = load_authored_rule("TS-BIND-AACTOR-001")
    with pytest.raises(SchemaError) as raised:
        export_authored_case(rule, WORKSPACE)
    assert raised.value.code == "v2_contract_required"
