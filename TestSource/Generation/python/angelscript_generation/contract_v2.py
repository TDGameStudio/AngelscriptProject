"""Authored Contract V2 schema loading and document-level validation."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
import json
from pathlib import Path
import re
from typing import Any, Iterable

from jsonschema import Draft202012Validator, FormatChecker

from .as_inventory import legacy_name


SCHEMA_VERSION = "authored-case-contract-v2"
GENERATION_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SCHEMA_PATH = GENERATION_ROOT / "schema" / "authored-case-contract-v2.json"


@dataclass(frozen=True)
class Diagnostic:
    code: str
    message: str
    source_path: str = ""
    line: int | None = None
    declaration: str = ""
    severity: str = "error"

    @property
    def location(self) -> str:
        if not self.source_path:
            return "<contract>"
        return f"{self.source_path}:{self.line}" if self.line else self.source_path

    def format(self) -> str:
        declaration = f" [{self.declaration}]" if self.declaration else ""
        return f"{self.location}: {self.severity} {self.code}: {self.message}{declaration}"


def diagnostic_sort_key(item: Diagnostic) -> tuple[str, int, str, str, str]:
    return (item.source_path, item.line or 0, item.code, item.declaration, item.message)


def load_schema(path: Path | None = None) -> dict[str, Any]:
    schema_path = path or DEFAULT_SCHEMA_PATH
    return json.loads(schema_path.read_text(encoding="utf-8"))


def _json_path(parts: Iterable[Any]) -> str:
    result = "$"
    for part in parts:
        result += f"[{part}]" if isinstance(part, int) else f".{part}"
    return result


def _diag(code: str, message: str, contract: dict[str, Any], function: dict[str, Any] | None = None) -> Diagnostic:
    return Diagnostic(
        code,
        message,
        str(contract.get("sourcePath") or ""),
        declaration=str((function or {}).get("declaration") or ""),
    )


def _base_as_type(as_type: str) -> str:
    value = re.sub(r"&\s*(?:(?:inout|in|out)\b)?", "", as_type)
    value = re.sub(r"^const\s+", "", value)
    return " ".join(value.split())


def _validate_near(oracle: dict[str, Any], contract: dict[str, Any], function: dict[str, Any], diagnostics: list[Diagnostic]) -> None:
    if oracle.get("comparison") == "near" and not isinstance(oracle.get("tolerance"), (int, float)):
        diagnostics.append(_diag("missing-tolerance", "near comparison requires a positive numeric tolerance", contract, function))


def _has_any_payload(value: dict[str, Any], keys: set[str]) -> bool:
    return any(key in value for key in keys)


def _validate_comparison_payload(
    oracle: dict[str, Any],
    contract: dict[str, Any],
    function: dict[str, Any],
    diagnostics: list[Diagnostic],
) -> None:
    comparison = oracle.get("comparison")
    required: dict[str, set[str]] = {
        "exact": {"value", "isNull", "identity", "class", "outer", "name", "flags", "elements"},
        "near": {"value"},
        "sameIdentity": {"identity"},
        "differentIdentity": {"identity"},
        "orderedElements": {"elements"},
        "unorderedElements": {"elements"},
        "contains": {"value", "elements"},
        "atLeast": {"value"},
        "relation": {"relation"},
    }
    payload_keys = required.get(str(comparison))
    if payload_keys is not None and not _has_any_payload(oracle, payload_keys):
        diagnostics.append(
            _diag(
                "missing-comparison-payload",
                f"{comparison} comparison requires one of {sorted(payload_keys)}",
                contract,
                function,
            )
        )
    _validate_near(oracle, contract, function, diagnostics)


def _validate_writeback_comparison_payload(
    writeback: dict[str, Any],
    contract: dict[str, Any],
    function: dict[str, Any],
    diagnostics: list[Diagnostic],
) -> None:
    comparison = writeback["comparison"]
    after = writeback["after"]
    required_after: dict[str, set[str]] = {
        "near": {"value"},
        "sameIdentity": {"identity"},
        "differentIdentity": {"identity"},
        "orderedElements": {"elements"},
        "unorderedElements": {"elements"},
        "contains": {"value", "elements"},
        "atLeast": {"value"},
    }
    if comparison == "relation" and not str(writeback.get("relation") or "").strip():
        diagnostics.append(
            _diag(
                "missing-comparison-payload",
                "relation writeback comparison requires relation",
                contract,
                function,
            )
        )
    payload_keys = required_after.get(comparison)
    if payload_keys is not None and not _has_any_payload(after, payload_keys):
        diagnostics.append(
            _diag(
                "missing-comparison-payload",
                f"{comparison} writeback comparison requires after payload {sorted(payload_keys)}",
                contract,
                function,
            )
        )
    if comparison in {"exception", "compileDiagnostic"}:
        diagnostics.append(
            _diag(
                "diagnostic-comparison-mismatch",
                f"{comparison} is not a writeback comparison",
                contract,
                function,
            )
        )
    _validate_near(writeback, contract, function, diagnostics)


def _declaration_name(declaration: str) -> str:
    matches = re.findall(r"(~?[A-Za-z_]\w*)\s*\(", declaration)
    return matches[-1] if matches else ""


def validate_contract_document(
    contract: dict[str, Any],
    *,
    schema_path: Path | None = None,
) -> tuple[Diagnostic, ...]:
    """Validate one V2 document without reading its source file."""

    schema = load_schema(schema_path)
    schema_errors = sorted(
        Draft202012Validator(schema, format_checker=FormatChecker()).iter_errors(contract),
        key=lambda error: list(error.absolute_path),
    )
    if schema_errors:
        return tuple(
            Diagnostic(
                "schema-invalid",
                f"{_json_path(error.absolute_path)}: {error.message}",
                str(contract.get("sourcePath") or ""),
            )
            for error in schema_errors
        )

    diagnostics: list[Diagnostic] = []
    functions: list[dict[str, Any]] = contract["functions"]
    seen_subcases: set[str] = set()
    seen_declarations: set[tuple[str, str]] = set()
    required_fixed_names = {
        "BeginPlay",
        "Tick",
        "EndPlay",
        "Construct",
        "BeforeAll",
        "BeforeEach",
        "AfterEach",
        "AfterAll",
    }

    for function in functions:
        subcase = function["subcaseId"]
        if subcase in seen_subcases:
            diagnostics.append(_diag("duplicate-function-subcase", f"duplicate function subcaseId {subcase}", contract, function))
        seen_subcases.add(subcase)
        declaration = function["declaration"]
        qualified_declaration = (function["owner"], declaration)
        if qualified_declaration in seen_declarations:
            diagnostics.append(
                _diag(
                    "duplicate-declaration",
                    f"declaration appears more than once under owner {function['owner']}",
                    contract,
                    function,
                )
            )
        seen_declarations.add(qualified_declaration)

        if legacy_name(function["name"]):
            diagnostics.append(_diag("legacy-source-name", f"migrated callable uses forbidden legacy name {function['name']}", contract, function))
        fixed_role = function["role"] in {
            "FrameworkHook",
            "LifecycleCallback",
            "Import",
            "Event",
            "Mixin",
            "Lambda",
        }
        fixed_annotation = any(
            "BlueprintOverride" in annotation or "BlueprintEvent" in annotation
            for annotation in function["annotations"]
        )
        if fixed_role or fixed_annotation or function["name"] in required_fixed_names or function["name"].startswith("Test_"):
            if not function["requiredNameReason"].strip():
                diagnostics.append(_diag("missing-required-name-reason", f"fixed framework name {function['name']} requires a reason", contract, function))

        legacy_declaration = function["legacyDeclaration"].strip()
        if legacy_declaration:
            legacy_declaration_name = _declaration_name(legacy_declaration)
            if not legacy_declaration_name or legacy_declaration_name not in contract["legacySymbols"]:
                diagnostics.append(
                    _diag(
                        "legacy-history-mismatch",
                        f"legacy declaration name {legacy_declaration_name or '<unparsed>'} is absent from legacySymbols",
                        contract,
                        function,
                    )
                )

        parameters = function["parameters"]
        if function["role"] == "Entry" and not parameters and not function["zeroArgumentReason"].strip():
            diagnostics.append(_diag("missing-zero-argument-reason", "zero-argument entry requires a default-construction or framework reason", contract, function))

        parameter_by_name = {parameter["name"]: parameter for parameter in parameters}
        writeback_parameters = {
            parameter["name"] for parameter in parameters if parameter["direction"] in {"out", "inout"}
        }
        declared_writebacks = {item["parameter"] for item in function["writebacks"]}
        for name in sorted(writeback_parameters - declared_writebacks):
            diagnostics.append(_diag("missing-writeback", f"{name} is out/inout but has no function writeback contract", contract, function))
        for name in sorted(declared_writebacks - writeback_parameters):
            diagnostics.append(_diag("invalid-writeback", f"writeback {name} is not an out/inout parameter", contract, function))

        vector_ids: set[str] = set()
        has_exception_or_diagnostic = False
        for vector in function["vectors"]:
            vector_id = vector["id"]
            if vector_id in vector_ids:
                diagnostics.append(_diag("duplicate-vector", f"duplicate vector id {vector_id}", contract, function))
            vector_ids.add(vector_id)
            arguments = vector["arguments"]
            required_arguments = {
                parameter["name"] for parameter in parameters if parameter["direction"] != "out"
            }
            for name in sorted(required_arguments - set(arguments)):
                diagnostics.append(_diag("missing-vector-argument", f"vector {vector_id} omits input {name}", contract, function))
            for name, value in sorted(arguments.items()):
                parameter = parameter_by_name.get(name)
                if parameter is None:
                    diagnostics.append(_diag("unknown-vector-argument", f"vector {vector_id} names unknown parameter {name}", contract, function))
                elif _base_as_type(value["asType"]) != _base_as_type(parameter["asType"]):
                    diagnostics.append(_diag("vector-type-mismatch", f"vector {vector_id} types {name} as {value['asType']} but declaration uses {parameter['asType']}", contract, function))

            vector_writebacks = {item["parameter"]: item for item in vector["writebacks"]}
            for name in sorted(writeback_parameters - set(vector_writebacks)):
                diagnostics.append(_diag("missing-writeback", f"vector {vector_id} omits before/after writeback for {name}", contract, function))
            for name, writeback in sorted(vector_writebacks.items()):
                parameter = parameter_by_name.get(name)
                if parameter is None or parameter["direction"] not in {"out", "inout"}:
                    diagnostics.append(_diag("invalid-writeback", f"vector {vector_id} writes back non-out parameter {name}", contract, function))
                else:
                    expected_type = _base_as_type(parameter["asType"])
                    for side in ("before", "after"):
                        actual_type = _base_as_type(writeback[side]["asType"])
                        if actual_type != expected_type:
                            diagnostics.append(_diag("vector-type-mismatch", f"vector {vector_id} {side} value for {name} uses {actual_type}, expected {expected_type}", contract, function))
                    _validate_writeback_comparison_payload(writeback, contract, function, diagnostics)

            expected_return = vector.get("expectedReturn")
            expected_exception = vector.get("expectedException")
            expected_compile_diagnostic = vector.get("expectedCompileDiagnostic")
            oracle_count = sum(
                item is not None
                for item in (expected_return, expected_exception, expected_compile_diagnostic)
            )
            if oracle_count > 1:
                diagnostics.append(
                    _diag(
                        "contradictory-vector-oracle",
                        f"vector {vector_id} must select exactly one return, exception, or compile-diagnostic channel",
                        contract,
                        function,
                    )
                )
            if expected_exception is not None and expected_exception["comparison"] != "exception":
                diagnostics.append(
                    _diag(
                        "diagnostic-comparison-mismatch",
                        f"vector {vector_id} expectedException must use exception comparison",
                        contract,
                        function,
                    )
                )
            if expected_compile_diagnostic is not None and expected_compile_diagnostic["comparison"] != "compileDiagnostic":
                diagnostics.append(
                    _diag(
                        "diagnostic-comparison-mismatch",
                        f"vector {vector_id} expectedCompileDiagnostic must use compileDiagnostic comparison",
                        contract,
                        function,
                    )
                )
            mode = contract["executionProfile"]["mode"]
            if expected_exception is not None and mode in {"CompileOnly", "DiagnosticOnly"}:
                diagnostics.append(
                    _diag(
                        "diagnostic-profile-mismatch",
                        f"vector {vector_id} runtime exception is inconsistent with {mode}",
                        contract,
                        function,
                    )
                )
            if expected_compile_diagnostic is not None and mode not in {"CompileOnly", "DiagnosticOnly"}:
                diagnostics.append(
                    _diag(
                        "diagnostic-profile-mismatch",
                        f"vector {vector_id} compile diagnostic is inconsistent with {mode}",
                        contract,
                        function,
                    )
                )
            if function["return"]["asType"] != "void" and not function["return"].get("hostVisibleState"):
                if expected_return is None and not expected_exception and not expected_compile_diagnostic:
                    diagnostics.append(_diag("missing-return-oracle", f"vector {vector_id} has no raw return oracle", contract, function))
            if expected_return is not None:
                if expected_return["comparison"] in {"exception", "compileDiagnostic"}:
                    diagnostics.append(
                        _diag(
                            "diagnostic-comparison-mismatch",
                            f"vector {vector_id} diagnostic comparison belongs in its diagnostic channel",
                            contract,
                            function,
                        )
                    )
                _validate_comparison_payload(expected_return, contract, function, diagnostics)
                if _base_as_type(expected_return["asType"]) != _base_as_type(function["return"]["asType"]):
                    diagnostics.append(_diag("vector-type-mismatch", f"vector {vector_id} return type differs from declaration return", contract, function))
            has_exception_or_diagnostic |= bool(expected_exception or expected_compile_diagnostic)

        if function["role"] == "NegativeTrigger" and not has_exception_or_diagnostic:
            diagnostics.append(_diag("missing-exception-oracle", "negative trigger requires an exact exception or compile diagnostic", contract, function))

        fixture = function["fixture"]
        if fixture["kind"] != "None" and (not fixture["identity"].strip() or not fixture["owner"].strip()):
            diagnostics.append(_diag("incomplete-fixture", "nontrivial fixture requires identity and owner", contract, function))
        if fixture["kind"] in {"Actor", "Component", "World", "GameInstance", "Object"} and function["cleanupOwner"].strip().lower() == "none":
            diagnostics.append(_diag("missing-cleanup-owner", "lifecycle fixture requires an explicit cleanup owner", contract, function))

    declared_legacy_names = {
        _declaration_name(function["legacyDeclaration"])
        for function in functions
        if function["legacyDeclaration"].strip()
    }
    for legacy_symbol in sorted(set(contract["legacySymbols"]) - declared_legacy_names):
        diagnostics.append(
            _diag(
                "legacy-history-mismatch",
                f"legacy symbol {legacy_symbol} has no matching function legacyDeclaration",
                contract,
            )
        )

    coverage = contract["coverage"]
    evidence = coverage["evidence"]
    passed_stages = {
        item["stage"]
        for item in evidence
        if item["result"] == "pass"
        and item["command"].strip()
        and str(item.get("recordedAt") or "").strip()
    }
    required_stages = {
        "strict-pass": {"source-strict"},
        "compile-verified": {"source-strict", "compile"},
        "runtime-verified": {"source-strict", "compile", "runtime"},
        "external-oracle-verified": {
            "source-strict",
            "compile",
            "runtime",
            "external-oracle",
        },
    }.get(coverage["status"], set())
    missing_stages = sorted(required_stages - passed_stages)
    if missing_stages:
        diagnostics.append(
            _diag(
                "unsupported-status-claim",
                f"{coverage['status']} lacks passing recorded evidence for {', '.join(missing_stages)}",
                contract,
            )
        )
    if coverage["status"] == "audit-only" and contract["review"]["state"] != "legacy-unreviewed":
        diagnostics.append(_diag("invalid-audit-only-state", "audit-only is reserved for legacy-unreviewed adapters", contract))

    review = contract["review"]
    if review["state"] == "reviewed":
        valid_review_date = False
        try:
            date.fromisoformat(review["reviewedAt"])
            valid_review_date = True
        except (TypeError, ValueError):
            pass
        if not review["reviewer"].strip() or not valid_review_date:
            diagnostics.append(
                _diag(
                    "incomplete-review",
                    "reviewed state requires reviewer identity and an ISO review date",
                    contract,
                )
            )

    return tuple(sorted(diagnostics, key=diagnostic_sort_key))


def contract_paths(contracts_root: Path) -> tuple[Path, ...]:
    if not contracts_root.is_dir():
        return ()
    return tuple(
        sorted(
            (path for path in contracts_root.rglob("*.json") if path.name != "index.json"),
            key=lambda path: path.relative_to(contracts_root).as_posix(),
        )
    )


def read_contract(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError("contract root must be a JSON object")
    return payload


def canonical_json(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
