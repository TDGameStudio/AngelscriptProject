"""Export reviewed TestSource .as files as generation results. Seed is ignored."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .audit_v2 import validate_contract_against_source
from .canonical import canonical_json_bytes, canonical_source_bytes
from .case_key import case_key_from_authored_path, cpp_symbol
from .comments import validate_comment_facts
from .contract_v2 import SCHEMA_VERSION as CONTRACT_V2_SCHEMA_VERSION
from .schema import SCHEMA_VERSION_RESULT, SchemaError

GENERATION_ROOT = Path(__file__).resolve().parents[2]


def authored_index_path() -> Path:
    return GENERATION_ROOT / "Rules" / "Authored" / "index.json"


def load_authored_index() -> dict[str, Any]:
    path = authored_index_path()
    if not path.is_file():
        raise SchemaError("missing_index", f"missing authored index {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def load_authored_rule(task_id: str) -> dict[str, Any]:
    path = GENERATION_ROOT / "Rules" / "Authored" / f"{task_id}.json"
    if not path.is_file():
        raise SchemaError("missing_rule", f"missing authored rule {task_id}")
    return json.loads(path.read_text(encoding="utf-8"))


def adapt_v1_authored_rule(rule: dict[str, Any]) -> dict[str, Any]:
    """Expose migration state without pretending a v1 row is reviewed V2 data.

    The adapter deliberately preserves the original record verbatim beneath
    ``legacyRule``.  It does not infer function declarations from the
    semicolon-packed ``plannedSymbols`` field.
    """

    return {
        "schemaVersion": "authored-rule-v1-adapter",
        "sourcePath": rule.get("sourcePath", ""),
        "legacyRule": dict(rule),
        "coverage": {"status": "audit-only", "evidence": []},
        "review": {
            "state": "legacy-unreviewed",
            "reviewer": "",
            "reviewedAt": "",
        },
    }


def _resolve_v2_contract(candidate: dict[str, Any]) -> dict[str, Any]:
    if candidate.get("schemaVersion") == CONTRACT_V2_SCHEMA_VERSION:
        return candidate
    raise SchemaError(
        "v2_contract_required",
        "active authored export accepts Contract V2 documents only; v1 rules are audit evidence",
    )


def _recorded_compile_status(contract: dict[str, Any]) -> str:
    verified_statuses = {"compile-verified", "runtime-verified", "external-oracle-verified"}
    has_compile_pass = any(
        item.get("stage") == "compile"
        and item.get("result") == "pass"
        and str(item.get("command") or "").strip()
        and str(item.get("recordedAt") or "").strip()
        for item in contract["coverage"]["evidence"]
    )
    return "pass" if contract["coverage"]["status"] in verified_statuses and has_compile_pass else "unverified"


def export_authored_case(candidate: dict[str, Any], workspace_root: Path) -> dict[str, Any]:
    """Export only reviewed, current-source-clean Contract V2 data.

    A v1 rule may locate an already migrated V2 sidecar, but none of its
    ``plannedSymbols`` or inferred compile state enters the active result.
    """

    contract = _resolve_v2_contract(candidate)
    diagnostics = validate_contract_against_source(workspace_root / "TestSource", contract)
    if diagnostics:
        details = "; ".join(item.format() for item in diagnostics[:5])
        raise SchemaError(
            "v2_contract_not_exportable",
            f"active authored export requires reviewed source-parity-clean V2: {details}",
        )

    source_path = contract["sourcePath"]
    as_file = workspace_root / source_path
    if not as_file.is_file():
        raise SchemaError("missing_source", f"missing authored source {source_path}")
    source_bytes = canonical_source_bytes(as_file.read_bytes())
    case_key = case_key_from_authored_path(source_path)
    function_facts = [function["commentFacts"] for function in contract["functions"]]
    comments = validate_comment_facts(
        {
            "schemaVersion": "comment-facts-v1",
            "feature": f"{contract['caseId']}: " + "; ".join(item["purpose"] for item in function_facts),
            "inputs": "; ".join(item["inputs"] for item in function_facts),
            "expectations": "; ".join(item["outputs"] for item in function_facts),
            "boundary": "; ".join(item["boundary"] for item in function_facts),
            "references": [],
            "attachment": "; ".join(
                f"{function['owner']}|{function['declaration']}" for function in contract["functions"]
            ),
        }
    )
    oracle = {
        "kind": "authored",
        "comparison": "exact",
        "compileStatus": _recorded_compile_status(contract),
        "payload": {
            "contractCaseId": contract["caseId"],
            "sourceShape": contract["sourceShape"],
            "functions": [
                {
                    key: function[key]
                    for key in (
                        "subcaseId",
                        "owner",
                        "role",
                        "name",
                        "declaration",
                        "annotations",
                        "parameters",
                        "return",
                        "writebacks",
                        "vectors",
                    )
                }
                for function in contract["functions"]
            ],
        },
    }
    manifest = {
        "caseKey": case_key,
        "origin": "Authored",
        "recipeId": "authored-source-export",
        "recipeVersion": "2",
        "seed": "0",
        "cppSymbol": cpp_symbol(case_key),
        "sourcePath": source_path,
        "contractCaseId": contract["caseId"],
        "review": contract["review"],
        "coverage": contract["coverage"],
        "requiredHarness": contract["executionProfile"].get("requiredHarness", []),
    }
    cells = []
    for function in contract["functions"]:
        for vector in function["vectors"]:
            cells.append(
                {
                    "cellIndex": len(cells),
                    "declaration": function["declaration"],
                    "entryPoint": function["name"],
                    "arguments": [
                        vector["arguments"][parameter["name"]]
                        for parameter in function["parameters"]
                        if parameter["name"] in vector["arguments"]
                    ],
                    "axisValues": {
                        "owner": function["owner"],
                        "subcaseId": function["subcaseId"],
                        "vectorId": vector["id"],
                    },
                }
            )
    return {
        "schemaVersion": SCHEMA_VERSION_RESULT,
        "origin": "Authored",
        "caseKey": case_key,
        "recipeId": "authored-source-export",
        "recipeVersion": "2",
        "seed": "0",
        "selectedAxes": {"authoredFixture": case_key},
        "sourceBundle": [
            {
                "logicalPath": source_path,
                "utf8BytesHex": source_bytes.hex(),
                "role": "authored",
            }
        ],
        "manifestUtf8": canonical_json_bytes(manifest).decode("utf-8"),
        "cells": cells,
        "oracle": oracle,
        "commentFacts": comments,
        "references": [],
        "harness": list(contract["executionProfile"].get("requiredHarness", [])),
        "error": None,
        "negativeMutation": None,
        "recoverySourceHex": None,
    }
