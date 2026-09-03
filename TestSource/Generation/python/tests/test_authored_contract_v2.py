from __future__ import annotations

import copy
import json
from importlib import import_module
from pathlib import Path

import pytest


def valid_source() -> str:
    return """namespace TS_Pilot
{
    // Case TS-PILOT-001/read-value. Purpose reads caller input. Inputs Value. Outputs raw int32. Boundary caller-owned.
    int32 ReadValue(int32 Value)
    {
        return Value;
    }
}
"""


def valid_contract(source_path: str = "TestSource/Bindings/Pilot/Test_Read.as") -> dict:
    return {
        "schemaVersion": "authored-case-contract-v2",
        "caseId": "TS-PILOT-001",
        "subcaseId": "pilot-source",
        "sourcePath": source_path,
        "namespace": "TS_Pilot",
        "sourceShape": "NamespaceFunctions",
        "executionProfile": {"mode": "Runtime", "isolation": "DefaultSafe"},
        "legacySymbols": ["Observe_Value_Nominal"],
        "functions": [
            {
                "subcaseId": "read-value",
                "owner": "TS_Pilot",
                "role": "Entry",
                "name": "ReadValue",
                "declaration": "int32 ReadValue(int32 Value)",
                "annotations": [],
                "legacyDeclaration": "bool Observe_Value_Nominal()",
                "requiredNameReason": "",
                "zeroArgumentReason": "",
                "fixture": {"kind": "None", "identity": "", "owner": ""},
                "phase": "Act",
                "cleanupOwner": "None",
                "parameters": [
                    {"name": "Value", "asType": "int32", "direction": "value"}
                ],
                "return": {"asType": "int32"},
                "writebacks": [],
                "vectors": [
                    {
                        "id": "positive",
                        "arguments": {"Value": {"asType": "int32", "value": 7}},
                        "expectedReturn": {
                            "asType": "int32",
                            "comparison": "exact",
                            "value": 7,
                        },
                        "writebacks": [],
                    }
                ],
                "commentFacts": {
                    "purpose": "reads caller input",
                    "inputs": "Value",
                    "outputs": "raw int32",
                    "boundary": "caller-owned",
                    "cleanup": "None",
                },
            }
        ],
        "coverage": {"status": "reviewed", "evidence": []},
        "review": {
            "state": "reviewed",
            "reviewer": "unit-test",
            "reviewedAt": "2026-08-24",
        },
    }


def contract_api():
    return import_module("angelscript_generation.contract_v2")


def diagnostic_codes(contract: dict) -> set[str]:
    return {item.code for item in contract_api().validate_contract_document(contract)}


def test_schema_accepts_a_complete_typed_contract() -> None:
    assert diagnostic_codes(valid_contract()) == set()


def test_validator_rejects_reviewed_state_without_review_identity_and_date() -> None:
    contract = valid_contract()
    contract["review"]["reviewer"] = ""
    contract["review"]["reviewedAt"] = ""
    assert "incomplete-review" in diagnostic_codes(contract)


def test_schema_rejects_missing_required_function_comment_facts() -> None:
    contract = valid_contract()
    del contract["functions"][0]["commentFacts"]
    assert "schema-invalid" in diagnostic_codes(contract)


def test_schema_rejects_untyped_vector_values() -> None:
    contract = valid_contract()
    contract["functions"][0]["vectors"][0]["arguments"]["Value"] = 7
    assert "schema-invalid" in diagnostic_codes(contract)


def test_validator_rejects_legacy_name_in_reviewed_declaration() -> None:
    contract = valid_contract()
    contract["functions"][0]["name"] = "Observe_Value_Nominal"
    contract["functions"][0]["declaration"] = "int32 Observe_Value_Nominal(int32 Value)"
    assert "legacy-source-name" in diagnostic_codes(contract)


def test_validator_rejects_out_parameter_without_writeback_vectors() -> None:
    contract = valid_contract()
    function = contract["functions"][0]
    function["declaration"] = "void ReadValue(int32&out Value)"
    function["parameters"][0] = {"name": "Value", "asType": "int32&out", "direction": "out"}
    function["return"] = {"asType": "void"}
    function["vectors"][0].pop("expectedReturn")
    assert "missing-writeback" in diagnostic_codes(contract)


def test_validator_rejects_writeback_comparison_without_required_payload() -> None:
    contract = valid_contract()
    function = contract["functions"][0]
    function["declaration"] = "void ReadValue(int32&out Value)"
    function["parameters"][0] = {"name": "Value", "asType": "int32&out", "direction": "out"}
    function["return"] = {"asType": "void"}
    function["writebacks"] = [{"parameter": "Value"}]
    vector = function["vectors"][0]
    vector["arguments"] = {}
    vector.pop("expectedReturn")
    vector["writebacks"] = [
        {
            "parameter": "Value",
            "before": {"asType": "int32", "value": 0},
            "after": {"asType": "int32", "value": 7},
            "comparison": "relation",
        }
    ]
    assert "missing-comparison-payload" in diagnostic_codes(contract)


def test_validator_rejects_zero_argument_entry_without_reason() -> None:
    contract = valid_contract()
    function = contract["functions"][0]
    function["declaration"] = "int32 ReadValue()"
    function["parameters"] = []
    function["vectors"][0]["arguments"] = {}
    assert "missing-zero-argument-reason" in diagnostic_codes(contract)


def test_validator_rejects_negative_trigger_without_exception_or_diagnostic() -> None:
    contract = valid_contract()
    function = contract["functions"][0]
    function["role"] = "NegativeTrigger"
    function["name"] = "TriggerOutOfRange"
    function["declaration"] = "int32 TriggerOutOfRange(int32 Value)"
    assert "missing-exception-oracle" in diagnostic_codes(contract)


def test_validator_rejects_strict_pass_without_source_strict_evidence() -> None:
    contract = valid_contract()
    contract["coverage"] = {"status": "strict-pass", "evidence": []}
    assert "unsupported-status-claim" in diagnostic_codes(contract)


def test_validator_rejects_near_comparison_without_tolerance() -> None:
    contract = valid_contract()
    contract["functions"][0]["vectors"][0]["expectedReturn"]["comparison"] = "near"
    assert "missing-tolerance" in diagnostic_codes(contract)


@pytest.mark.parametrize(
    ("comparison", "payload_key", "expected_code"),
    [
        ("exact", "value", "missing-comparison-payload"),
        ("sameIdentity", "identity", "missing-comparison-payload"),
        ("orderedElements", "elements", "missing-comparison-payload"),
        ("relation", "relation", "missing-comparison-payload"),
    ],
)
def test_validator_rejects_payload_free_comparison(
    comparison: str, payload_key: str, expected_code: str
) -> None:
    contract = valid_contract()
    oracle = contract["functions"][0]["vectors"][0]["expectedReturn"]
    oracle.clear()
    oracle.update({"asType": "int32", "comparison": comparison})
    assert payload_key not in oracle
    assert expected_code in diagnostic_codes(contract)


def test_validator_rejects_contradictory_return_exception_and_compile_diagnostic() -> None:
    contract = valid_contract()
    vector = contract["functions"][0]["vectors"][0]
    vector["expectedException"] = {"comparison": "exception", "message": "boom"}
    vector["expectedCompileDiagnostic"] = {
        "comparison": "compileDiagnostic",
        "message": "compile boom",
    }
    codes = diagnostic_codes(contract)
    assert "contradictory-vector-oracle" in codes
    assert "diagnostic-comparison-mismatch" not in codes


def test_validator_rejects_exception_and_compile_diagnostic_comparison_mismatch() -> None:
    contract = valid_contract()
    vector = contract["functions"][0]["vectors"][0]
    vector.pop("expectedReturn")
    vector["expectedException"] = {
        "comparison": "compileDiagnostic",
        "message": "wrong channel",
    }
    assert "diagnostic-comparison-mismatch" in diagnostic_codes(contract)


def test_validator_rejects_fixed_role_without_required_name_reason() -> None:
    contract = valid_contract()
    contract["functions"][0]["role"] = "Import"
    assert "missing-required-name-reason" in diagnostic_codes(contract)


def test_validator_rejects_legacy_declaration_without_matching_history() -> None:
    contract = valid_contract()
    contract["legacySymbols"] = ["SomeOtherLegacyName"]
    assert "legacy-history-mismatch" in diagnostic_codes(contract)


def test_validator_rejects_orphan_legacy_history_without_declaration() -> None:
    contract = valid_contract()
    contract["functions"][0]["legacyDeclaration"] = ""
    assert "legacy-history-mismatch" in diagnostic_codes(contract)


@pytest.mark.parametrize(
    ("status", "stages"),
    [
        ("strict-pass", ()),
        ("compile-verified", ("compile",)),
        ("runtime-verified", ("source-strict", "runtime")),
        ("external-oracle-verified", ("source-strict", "compile", "external-oracle")),
    ],
)
def test_validator_rejects_incomplete_verified_status_evidence_chain(
    status: str, stages: tuple[str, ...]
) -> None:
    contract = valid_contract()
    contract["coverage"] = {
        "status": status,
        "evidence": [
            {
                "stage": stage,
                "command": f"verify-{stage}",
                "result": "pass",
                "recordedAt": "2026-08-24",
            }
            for stage in stages
        ],
    }
    assert "unsupported-status-claim" in diagnostic_codes(contract)


def test_validator_rejects_pass_evidence_without_recorded_at() -> None:
    contract = valid_contract()
    contract["coverage"] = {
        "status": "strict-pass",
        "evidence": [
            {"stage": "source-strict", "command": "any-command", "result": "pass"}
        ],
    }
    assert "unsupported-status-claim" in diagnostic_codes(contract)


def test_validator_accepts_complete_structural_evidence_without_authenticating_command_text() -> None:
    contract = valid_contract()
    contract["coverage"] = {
        "status": "compile-verified",
        "evidence": [
            {
                "stage": stage,
                "command": f"recorded-but-not-statically-authenticated-{stage}",
                "result": "pass",
                "recordedAt": "2026-08-24",
            }
            for stage in ("source-strict", "compile")
        ],
    }
    assert diagnostic_codes(contract) == set()


def write_case(root: Path, contract: dict | None = None, source: str | None = None) -> tuple[Path, Path]:
    source_path = root / "Bindings" / "Pilot" / "Test_Read.as"
    source_path.parent.mkdir(parents=True, exist_ok=True)
    source_path.write_text(source if source is not None else valid_source(), encoding="utf-8")
    contracts = root / "Generation" / "Contracts"
    if contract is not None:
        contract_path = contracts / "Bindings" / "Pilot" / "Test_Read.as.json"
        contract_path.parent.mkdir(parents=True, exist_ok=True)
        contract_path.write_text(json.dumps(contract), encoding="utf-8")
    return source_path, contracts


def audit_codes(root: Path, contracts: Path, *, mode: str = "strict", domains: tuple[str, ...] = ()) -> set[str]:
    audit = import_module("angelscript_generation.audit_v2")
    report = audit.audit_testsource(root, contracts, mode=mode, domains=domains)
    return {item.code for item in report.diagnostics}


def test_strict_allows_same_declaration_under_different_owners(tmp_path: Path) -> None:
    source = """class AFirst
{
    // Case TS-OWNER-001/first. Purpose lifecycle entry. Inputs actor fixture. Outputs side effects. Boundary engine-owned.
    UFUNCTION(BlueprintOverride)
    void BeginPlay() {}
}
class ASecond
{
    // Case TS-OWNER-001/second. Purpose lifecycle entry. Inputs actor fixture. Outputs side effects. Boundary engine-owned.
    UFUNCTION(BlueprintOverride)
    void BeginPlay() {}
}
"""
    contract = valid_contract()
    contract.update(
        {
            "caseId": "TS-OWNER-001",
            "namespace": "",
            "sourceShape": "ClassMethods",
            "legacySymbols": [],
        }
    )
    functions = []
    for owner, subcase in (("AFirst", "first"), ("ASecond", "second")):
        function = copy.deepcopy(contract["functions"][0])
        function.update(
            {
                "subcaseId": subcase,
                "owner": owner,
                "role": "LifecycleCallback",
                "name": "BeginPlay",
                "declaration": "UFUNCTION(BlueprintOverride)\n    void BeginPlay()",
                "annotations": ["UFUNCTION(BlueprintOverride)"],
                "legacyDeclaration": "",
                "requiredNameReason": "Unreal lifecycle callback name",
                "parameters": [],
                "return": {"asType": "void"},
                "vectors": [{"id": "invoke", "arguments": {}, "writebacks": []}],
                "commentFacts": {
                    "purpose": "lifecycle entry",
                    "inputs": "actor fixture",
                    "outputs": "side effects",
                    "boundary": "engine-owned",
                    "cleanup": "None",
                },
            }
        )
        functions.append(function)
    contract["functions"] = functions
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert audit_codes(root, contracts) == set()


def test_strict_allows_same_declaration_in_different_namespaces(tmp_path: Path) -> None:
    source = """namespace Alpha
{
    // Case TS-NAMESPACE-001/alpha. Purpose reads namespace value. Inputs Value. Outputs raw int. Boundary caller-owned.
    int ReadValue(int Value) { return Value; }
}
namespace Beta
{
    // Case TS-NAMESPACE-001/beta. Purpose reads namespace value. Inputs Value. Outputs raw int. Boundary caller-owned.
    int ReadValue(int Value) { return Value; }
}
"""
    contract = valid_contract()
    contract.update(
        {
            "caseId": "TS-NAMESPACE-001",
            "namespace": "",
            "sourceShape": "NamespaceFunctions",
            "legacySymbols": [],
        }
    )
    functions = []
    for owner, subcase in (("Alpha", "alpha"), ("Beta", "beta")):
        function = copy.deepcopy(contract["functions"][0])
        function.update(
            {
                "subcaseId": subcase,
                "owner": owner,
                "declaration": "int ReadValue(int Value)",
                "legacyDeclaration": "",
                "parameters": [{"name": "Value", "asType": "int", "direction": "value"}],
                "return": {"asType": "int"},
                "vectors": [
                    {
                        "id": "positive",
                        "arguments": {"Value": {"asType": "int", "value": 7}},
                        "expectedReturn": {"asType": "int", "comparison": "exact", "value": 7},
                        "writebacks": [],
                    }
                ],
                "commentFacts": {
                    "purpose": "reads namespace value",
                    "inputs": "Value",
                    "outputs": "raw int",
                    "boundary": "caller-owned",
                    "cleanup": "None",
                },
            }
        )
        functions.append(function)
    contract["functions"] = functions
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert audit_codes(root, contracts) == set()


@pytest.mark.parametrize(
    ("field", "value", "expected_code"),
    [
        ("owner", "TS_Other", "owner-mismatch"),
        ("role", "Delegate", "callable-role-mismatch"),
        ("return", {"asType": "float32"}, "return-type-mismatch"),
        ("annotations", ["UFUNCTION(BlueprintCallable)"], "annotation-mismatch"),
    ],
)
def test_strict_rejects_owner_role_return_and_annotation_drift(
    tmp_path: Path, field: str, value: object, expected_code: str
) -> None:
    contract = valid_contract()
    contract["functions"][0][field] = value
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract)
    assert expected_code in audit_codes(root, contracts)


def test_strict_rejects_parameter_default_drift(tmp_path: Path) -> None:
    source = valid_source().replace("int32 Value)", "int32 Value = 7)")
    contract = valid_contract()
    contract["functions"][0]["declaration"] = "int32 ReadValue(int32 Value = 7)"
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert "parameter-default-mismatch" in audit_codes(root, contracts)


def test_strict_rejects_parameter_direction_drift(tmp_path: Path) -> None:
    source = valid_source().replace("int32 Value)", "const int32&in Value)")
    contract = valid_contract()
    function = contract["functions"][0]
    function["declaration"] = "int32 ReadValue(const int32&in Value)"
    function["parameters"][0]["asType"] = "const int32&in"
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert "parameter-direction-mismatch" in audit_codes(root, contracts)


def test_strict_rejects_declaration_source_mismatch(tmp_path: Path) -> None:
    root = tmp_path / "TestSource"
    contract = valid_contract()
    contract["functions"][0]["declaration"] = "int32 ReadOtherValue(int32 Value)"
    _, contracts = write_case(root, contract)
    assert "declaration-mismatch" in audit_codes(root, contracts)


def test_strict_attaches_comment_above_annotation(tmp_path: Path) -> None:
    source = """// Case TS-PILOT-001/read-value. Purpose reads caller input. Inputs Value. Outputs raw int32. Boundary caller-owned.
UFUNCTION(BlueprintCallable)
int32 ReadValue(int32 Value)
{
    return Value;
}
"""
    contract = valid_contract()
    contract["namespace"] = ""
    contract["sourceShape"] = "GlobalFunctions"
    contract["functions"][0]["owner"] = "::"
    contract["functions"][0]["declaration"] = "UFUNCTION(BlueprintCallable)\nint32 ReadValue(int32 Value)"
    contract["functions"][0]["annotations"] = ["UFUNCTION(BlueprintCallable)"]
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert audit_codes(root, contracts) == set()


def test_strict_rejects_comment_below_annotation(tmp_path: Path) -> None:
    source = """UFUNCTION(BlueprintCallable)
// Case TS-PILOT-001/read-value. Purpose reads caller input. Inputs Value. Outputs raw int32. Boundary caller-owned.
int32 ReadValue(int32 Value)
{
    return Value;
}
"""
    contract = valid_contract()
    contract["namespace"] = ""
    contract["sourceShape"] = "GlobalFunctions"
    contract["functions"][0]["owner"] = "::"
    contract["functions"][0]["declaration"] = "UFUNCTION(BlueprintCallable)\n// Case TS-PILOT-001/read-value. Purpose reads caller input. Inputs Value. Outputs raw int32. Boundary caller-owned.\nint32 ReadValue(int32 Value)"
    contract["functions"][0]["annotations"] = ["UFUNCTION(BlueprintCallable)"]
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert "missing-callable-comment" in audit_codes(root, contracts)


def test_strict_rejects_unspecified_reference_direction(tmp_path: Path) -> None:
    source = valid_source().replace("int32 Value)", "const int32& Value)")
    contract = valid_contract()
    contract["functions"][0]["declaration"] = "int32 ReadValue(const int32& Value)"
    contract["functions"][0]["parameters"][0] = {
        "name": "Value",
        "asType": "const int32&",
        "direction": "in",
    }
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert "unspecified-reference-direction" in audit_codes(root, contracts)


def test_strict_rejects_expected_value_comparison_wrapper(tmp_path: Path) -> None:
    source = valid_source().replace(
        "int32 ReadValue(int32 Value)", "bool ReadValue(int32 Value, int32 ExpectedValue)"
    ).replace("return Value;", "return Value == ExpectedValue;")
    contract = valid_contract()
    function = contract["functions"][0]
    function["declaration"] = "bool ReadValue(int32 Value, int32 ExpectedValue)"
    function["parameters"].append(
        {"name": "ExpectedValue", "asType": "int32", "direction": "value"}
    )
    function["return"] = {"asType": "bool"}
    function["vectors"][0]["arguments"]["ExpectedValue"] = {"asType": "int32", "value": 7}
    function["vectors"][0]["expectedReturn"] = {
        "asType": "bool",
        "comparison": "exact",
        "value": True,
    }
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert "expected-value-wrapper" in audit_codes(root, contracts)


def test_strict_rejects_compound_boolean_as_only_multi_value_oracle(tmp_path: Path) -> None:
    source = valid_source().replace("int32 ReadValue", "bool ReadValue").replace(
        "return Value;", "return Value > 0 && Value < 10;"
    )
    contract = valid_contract()
    function = contract["functions"][0]
    function["declaration"] = "bool ReadValue(int32 Value)"
    function["return"] = {"asType": "bool"}
    function["vectors"][0]["expectedReturn"] = {
        "asType": "bool",
        "comparison": "exact",
        "value": True,
    }
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, contract, source)
    assert "compound-bool-oracle" in audit_codes(root, contracts)


def test_selected_domain_strict_does_not_scan_unrelated_sources(tmp_path: Path) -> None:
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, valid_contract())
    unrelated = root / "Language" / "Legacy" / "Test_Old.as"
    unrelated.parent.mkdir(parents=True)
    unrelated.write_text("bool Observe_Surface001_Nominal() { return true; }\n", encoding="utf-8")
    assert audit_codes(root, contracts, domains=("Bindings/Pilot",)) == set()


def test_audit_reports_missing_contract_and_legacy_name_without_crashing(tmp_path: Path) -> None:
    root = tmp_path / "TestSource"
    source = "bool Observe_Surface001_Nominal() { return true; }\n"
    _, contracts = write_case(root, None, source)
    codes = audit_codes(root, contracts, mode="audit")
    assert {"missing-contract", "legacy-source-name"} <= codes


def test_strict_rejects_stale_paths_and_duplicate_case_subcase(tmp_path: Path) -> None:
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, valid_contract())
    duplicate = valid_contract("TestSource/Bindings/Pilot/Missing.as")
    duplicate_path = contracts / "Bindings" / "Pilot" / "Missing.as.json"
    duplicate_path.write_text(json.dumps(duplicate), encoding="utf-8")
    codes = audit_codes(root, contracts)
    assert {"stale-source-path", "duplicate-case-subcase"} <= codes


def test_strict_rejects_duplicate_case_id_even_when_source_subcases_differ(tmp_path: Path) -> None:
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, valid_contract())
    duplicate = valid_contract("TestSource/Bindings/Pilot/Missing.as")
    duplicate["subcaseId"] = "different-source"
    duplicate["functions"][0]["subcaseId"] = "different-function"
    duplicate_path = contracts / "Bindings" / "Pilot" / "Missing.as.json"
    duplicate_path.write_text(json.dumps(duplicate), encoding="utf-8")
    assert "duplicate-case-id" in audit_codes(root, contracts)


def test_strict_rejects_duplicate_contract_declarations(tmp_path: Path) -> None:
    root = tmp_path / "TestSource"
    contract = valid_contract()
    duplicate_function = copy.deepcopy(contract["functions"][0])
    duplicate_function["subcaseId"] = "duplicate-declaration"
    contract["functions"].append(duplicate_function)
    _, contracts = write_case(root, contract)
    assert "duplicate-declaration" in audit_codes(root, contracts)


def test_projection_generation_is_byte_deterministic_and_truthful(tmp_path: Path) -> None:
    projections = import_module("angelscript_generation.projections_v2")
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, valid_contract())
    tasks = root / "Generation" / "Tasks"

    first = projections.write_projections(root, contracts, tasks)
    first_bytes = {path.relative_to(root).as_posix(): path.read_bytes() for path in first}
    second = projections.write_projections(root, contracts, tasks)
    second_bytes = {path.relative_to(root).as_posix(): path.read_bytes() for path in second}

    assert first_bytes == second_bytes
    index = json.loads((contracts / "index.json").read_text(encoding="utf-8"))
    assert index["coverageState"] == "complete-reviewed"
    task_text = (tasks / "Bindings__Pilot.md").read_text(encoding="utf-8")
    assert "bool Observe_Value_Nominal()" in task_text
    assert "int32 ReadValue(int32 Value)" in task_text
    assert "typed vectors" in task_text
    assert "--mode strict --domain Bindings/Pilot" in task_text


def test_projection_counts_later_verified_status_as_source_strict(tmp_path: Path) -> None:
    projections = import_module("angelscript_generation.projections_v2")
    root = tmp_path / "TestSource"
    contract = valid_contract()
    contract["coverage"] = {
        "status": "compile-verified",
        "evidence": [
            {
                "stage": stage,
                "command": f"verify-{stage}",
                "result": "pass",
                "recordedAt": "2026-08-24",
            }
            for stage in ("source-strict", "compile")
        ],
    }
    _, contracts = write_case(root, contract)

    projections.write_projections(root, contracts, root / "Generation" / "Tasks")

    index = json.loads((contracts / "index.json").read_text(encoding="utf-8"))
    assert index["coverageState"] == "complete-source-strict"
    assert index["totals"]["strictPassContractCount"] == 1


@pytest.mark.parametrize("dirty_kind", ["draft", "source-drift"])
def test_projection_fails_closed_before_touching_existing_outputs(
    tmp_path: Path, dirty_kind: str
) -> None:
    projections = import_module("angelscript_generation.projections_v2")
    root = tmp_path / "TestSource"
    contract = valid_contract()
    source = valid_source()
    if dirty_kind == "draft":
        contract["review"]["state"] = "draft"
    else:
        contract["functions"][0]["declaration"] = "int32 ReadOther(int32 Value)"
    _, contracts = write_case(root, contract, source)
    tasks = root / "Generation" / "Tasks"
    tasks.mkdir(parents=True)
    index_path = contracts / "index.json"
    task_path = tasks / "sentinel.md"
    index_path.write_bytes(b"existing-index\n")
    task_path.write_bytes(b"existing-task\n")

    with pytest.raises(projections.ProjectionError):
        projections.write_projections(root, contracts, tasks)

    assert index_path.read_bytes() == b"existing-index\n"
    assert task_path.read_bytes() == b"existing-task\n"


def test_active_authored_export_uses_only_reviewed_parity_clean_v2(tmp_path: Path) -> None:
    authored = import_module("angelscript_generation.authored")
    canonical = import_module("angelscript_generation.canonical")
    schema = import_module("angelscript_generation.schema")
    root = tmp_path / "Workspace"
    testsource = root / "TestSource"
    contract = valid_contract()
    source_path, _ = write_case(testsource, contract)

    result = schema.load_result(authored.export_authored_case(contract, root))

    assert bytes.fromhex(result.source_bundle[0]["utf8BytesHex"]) == canonical.canonical_source_bytes(source_path.read_bytes())
    assert result.cells == (
        {
            "cellIndex": 0,
            "declaration": "int32 ReadValue(int32 Value)",
            "entryPoint": "ReadValue",
            "arguments": [{"asType": "int32", "value": 7}],
            "axisValues": {
                "owner": "TS_Pilot",
                "subcaseId": "read-value",
                "vectorId": "positive",
            },
        },
    )
    assert result.oracle["compileStatus"] == "unverified"
    assert "plannedSymbols" not in result.oracle["payload"]
    assert "plannedSymbols" not in result.manifest_utf8


def test_v1_rule_remains_audit_only_even_when_a_v2_sidecar_exists(tmp_path: Path) -> None:
    authored = import_module("angelscript_generation.authored")
    schema = import_module("angelscript_generation.schema")
    root = tmp_path / "Workspace"
    testsource = root / "TestSource"
    contract = valid_contract()
    write_case(testsource, contract)
    v1 = {
        "schemaVersion": "authored-rule-v1",
        "sourcePath": contract["sourcePath"],
        "plannedSymbols": "ReadValue",
    }

    with pytest.raises(schema.SchemaError) as raised:
        authored.export_authored_case(v1, root)
    assert raised.value.code == "v2_contract_required"


@pytest.mark.parametrize("dirty_kind", ["draft", "source-drift"])
def test_active_authored_export_rejects_unreviewed_or_source_dirty_v2(
    tmp_path: Path, dirty_kind: str
) -> None:
    authored = import_module("angelscript_generation.authored")
    schema = import_module("angelscript_generation.schema")
    root = tmp_path / "Workspace"
    testsource = root / "TestSource"
    contract = valid_contract()
    if dirty_kind == "draft":
        contract["review"]["state"] = "draft"
    else:
        contract["functions"][0]["declaration"] = "int32 ReadOther(int32 Value)"
    write_case(testsource, contract)

    with pytest.raises(schema.SchemaError) as raised:
        authored.export_authored_case(contract, root)
    assert raised.value.code == "v2_contract_not_exportable"


def test_v1_adapter_is_explicitly_unreviewed_and_audit_only() -> None:
    authored = import_module("angelscript_generation.authored")
    adapted = authored.adapt_v1_authored_rule(valid_contract())
    assert adapted["review"]["state"] == "legacy-unreviewed"
    assert adapted["coverage"]["status"] == "audit-only"


def test_finstancedstruct_v1_baseline_includes_negative_entry() -> None:
    authored = import_module("angelscript_generation.authored")
    rule = authored.load_authored_rule("TS-BIND-FINSTANCEDSTRUCT-002")
    assert "ExerciseExpectedFailure" in rule["plannedSymbols"].split(";")


def test_cli_audit_returns_nonzero_with_actionable_inventory(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, None, "bool Observe_Surface001_Nominal() { return true; }\n")
    cli = import_module("angelscript_generation.cli_v2")

    exit_code = cli.main(
        [
            "--root",
            str(root),
            "--contracts",
            str(contracts),
            "--mode",
            "audit",
            "--max-diagnostics",
            "2",
        ]
    )

    output = capsys.readouterr().out
    assert exit_code == 1
    assert "mode=audit sources=1 contracts=0 callables=1" in output
    assert "missing-contract=1" in output
    assert "legacy-source-name=1" in output
    assert "TestSource/Bindings/Pilot/Test_Read.as:1" in output


def test_cli_selected_strict_domain_returns_zero(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    root = tmp_path / "TestSource"
    _, contracts = write_case(root, valid_contract())
    unrelated = root / "Language" / "Legacy" / "Test_Old.as"
    unrelated.parent.mkdir(parents=True)
    unrelated.write_text("bool Observe_Surface001_Nominal() { return true; }\n", encoding="utf-8")
    cli = import_module("angelscript_generation.cli_v2")

    exit_code = cli.main(
        [
            "--root",
            str(root),
            "--contracts",
            str(contracts),
            "--mode",
            "strict",
            "--domain",
            "Bindings/Pilot",
        ]
    )

    output = capsys.readouterr().out
    assert exit_code == 0
    assert "mode=strict sources=1 contracts=1 callables=1 diagnostics=0" in output
