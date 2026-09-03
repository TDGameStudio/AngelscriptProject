"""Cross-file Contract V2 and AngelScript source audit."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
import json
from pathlib import Path
import re
from typing import Any, Iterable

from .as_inventory import CallableDeclaration, has_compound_boolean_return, inventory_source, legacy_name
from .reload_history import is_reload_history_path
from .contract_v2 import (
    Diagnostic,
    contract_paths,
    diagnostic_sort_key,
    read_contract,
    validate_contract_document,
)


@dataclass(frozen=True)
class AuditReport:
    mode: str
    domains: tuple[str, ...]
    source_count: int
    contract_count: int
    callable_count: int
    diagnostics: tuple[Diagnostic, ...]

    @property
    def clean(self) -> bool:
        return not self.diagnostics

    @property
    def counts_by_code(self) -> dict[str, int]:
        return dict(sorted(Counter(item.code for item in self.diagnostics).items()))


def normalize_domain(domain: str) -> str:
    value = domain.replace("\\", "/").strip("/")
    if value == "TestSource":
        return ""
    if value.startswith("TestSource/"):
        value = value[len("TestSource/") :]
    return value.rstrip("/")


def relative_source_path(source_path: str) -> str:
    value = source_path.replace("\\", "/").lstrip("/")
    if value.startswith("TestSource/"):
        return value[len("TestSource/") :]
    return value


def source_domain(source_path: str) -> str:
    relative = relative_source_path(source_path)
    parent = Path(relative).parent.as_posix()
    return "" if parent == "." else parent


def _selected(source_path: str, domains: tuple[str, ...]) -> bool:
    if not domains:
        return True
    relative = relative_source_path(source_path)
    return any(not domain or relative == domain or relative.startswith(domain + "/") for domain in domains)


def discover_sources(testsource_root: Path, domains: Iterable[str] = ()) -> tuple[Path, ...]:
    normalized = tuple(sorted({normalize_domain(domain) for domain in domains}))
    if not testsource_root.is_dir():
        return ()
    result = []
    for path in testsource_root.rglob("*.as"):
        relative = path.relative_to(testsource_root)
        if relative.parts and relative.parts[0].lower() == "generation":
            continue
        if is_reload_history_path(path):
            continue
        logical = "TestSource/" + relative.as_posix()
        if _selected(logical, normalized):
            result.append(path)
    return tuple(sorted(result, key=lambda item: item.relative_to(testsource_root).as_posix()))


def logical_source_path(testsource_root: Path, path: Path) -> str:
    return "TestSource/" + path.relative_to(testsource_root).as_posix()


def resolve_source_path(testsource_root: Path, source_path: str) -> Path:
    return testsource_root / Path(relative_source_path(source_path))


def expected_contract_path(contracts_root: Path, source_path: str) -> Path:
    relative = relative_source_path(source_path)
    return contracts_root / Path(relative + ".json")


def _source_diagnostic(
    code: str,
    message: str,
    source_path: str,
    callable_: CallableDeclaration | None = None,
    *,
    severity: str = "error",
) -> Diagnostic:
    return Diagnostic(
        code,
        message,
        source_path,
        line=callable_.line if callable_ else None,
        declaration=callable_.declaration if callable_ else "",
        severity=severity,
    )


def _comment_diagnostics(
    contract: dict[str, Any],
    function: dict[str, Any],
    callable_: CallableDeclaration,
) -> list[Diagnostic]:
    source_path = contract["sourcePath"]
    if not callable_.comment:
        return [
            _source_diagnostic(
                "missing-callable-comment",
                "callable needs an English knowledge comment immediately above its annotation/declaration",
                source_path,
                callable_,
            )
        ]
    comment = callable_.comment
    diagnostics: list[Diagnostic] = []
    identity_fragments = [contract["caseId"], function["subcaseId"]]
    facts = function["commentFacts"]
    required_facts = [facts["purpose"], facts["inputs"], facts["outputs"], facts["boundary"]]
    if facts["cleanup"].strip().lower() not in {"none", "n/a", "not applicable"}:
        required_facts.append(facts["cleanup"])
    missing = [fragment for fragment in identity_fragments + required_facts if fragment.lower() not in comment.lower()]
    if missing:
        diagnostics.append(
            _source_diagnostic(
                "comment-fact-mismatch",
                "attached comment omits contracted facts: " + ", ".join(missing),
                source_path,
                callable_,
            )
        )
    if not re.search(r"[A-Za-z]{3,}", comment):
        diagnostics.append(
            _source_diagnostic(
                "non-english-comment",
                "knowledge comment must contain explanatory English text",
                source_path,
                callable_,
            )
        )
    return diagnostics


def _source_only_diagnostics(
    source_path: str,
    callable_: CallableDeclaration,
    *,
    require_comment: bool,
) -> list[Diagnostic]:
    diagnostics: list[Diagnostic] = []
    if legacy_name(callable_.name):
        diagnostics.append(
            _source_diagnostic(
                "legacy-source-name",
                f"forbidden migrated name {callable_.name}; preserve it only in legacySymbols/legacyDeclaration",
                source_path,
                callable_,
            )
        )
    for parameter in callable_.parameters:
        if parameter.direction == "unspecified":
            diagnostics.append(
                _source_diagnostic(
                    "unspecified-reference-direction",
                    f"reference parameter {parameter.name} must spell &in, &out, or &inout",
                    source_path,
                    callable_,
                )
            )
    if any(parameter.name.lower().startswith("expected") for parameter in callable_.parameters):
        diagnostics.append(
            _source_diagnostic(
                "expected-value-wrapper",
                "expected values belong in typed vectors, not callable parameters",
                source_path,
                callable_,
            )
        )
    out_channels = [parameter for parameter in callable_.parameters if parameter.direction in {"out", "inout"}]
    if callable_.return_type.strip().endswith("bool") and not out_channels and has_compound_boolean_return(callable_.body):
        diagnostics.append(
            _source_diagnostic(
                "compound-bool-oracle",
                "compound Boolean is the only channel for multiple observations",
                source_path,
                callable_,
            )
        )
    if require_comment and not callable_.comment:
        diagnostics.append(
            _source_diagnostic(
                "missing-callable-comment",
                "callable has no immediately attached knowledge comment",
                source_path,
                callable_,
            )
        )
    return diagnostics


def _role_matches(role: str, callable_: CallableDeclaration) -> bool:
    structural_roles = {
        "constructor": {"Constructor"},
        "destructor": {"Destructor"},
        "operator": {"Operator"},
        "delegate": {"Delegate"},
        "event": {"Event"},
        "import": {"Import"},
        "mixin": {"Mixin"},
        "lambda": {"Lambda"},
    }
    if callable_.kind in structural_roles:
        return role in structural_roles[callable_.kind]
    return role in {"Entry", "Helper", "LifecycleCallback", "FrameworkHook", "NegativeTrigger"}


def _semantic_return(as_type: str) -> str:
    return " ".join((as_type.strip() or "void").split())


def _source_shape(callables: tuple[CallableDeclaration, ...]) -> str:
    if not callables:
        return "GlobalFunctions"
    if all(item.kind in {"delegate", "event"} for item in callables):
        return "Delegates"
    container_kinds = {item.container_kind for item in callables}
    if container_kinds == {"interface"}:
        return "InterfaceMethods"
    if container_kinds == {"struct"}:
        return "StructMethods"
    if container_kinds == {"class"}:
        return "ClassMethods"
    if container_kinds == {None}:
        return "NamespaceFunctions" if any(item.scope for item in callables) else "GlobalFunctions"
    return "Mixed"


def _parity_diagnostics(
    contract: dict[str, Any],
    callables: tuple[CallableDeclaration, ...],
) -> list[Diagnostic]:
    diagnostics: list[Diagnostic] = []
    source_path = contract["sourcePath"]
    contracted_functions = contract["functions"]
    source_by_declaration: dict[tuple[str, str], list[CallableDeclaration]] = {}
    for callable_ in callables:
        source_by_declaration.setdefault((callable_.owner, callable_.declaration), []).append(callable_)
    contract_by_declaration: dict[tuple[str, str], list[dict[str, Any]]] = {}
    for function in contracted_functions:
        contract_by_declaration.setdefault((function["owner"], function["declaration"]), []).append(function)

    for qualified_declaration, instances in source_by_declaration.items():
        if len(instances) > 1:
            for callable_ in instances[1:]:
                diagnostics.append(
                    _source_diagnostic(
                        "duplicate-declaration",
                        f"source declaration is duplicated under owner {qualified_declaration[0]}",
                        source_path,
                        callable_,
                    )
                )
    for qualified_declaration, functions in contract_by_declaration.items():
        if len(functions) > 1:
            diagnostics.append(
                Diagnostic(
                    "duplicate-declaration",
                    f"contract declaration is duplicated under owner {qualified_declaration[0]}",
                    source_path,
                    declaration=qualified_declaration[1],
                )
            )

    actual_shape = _source_shape(callables)
    if contract["sourceShape"] not in {actual_shape, "CompileDiagnostic"}:
        diagnostics.append(
            Diagnostic(
                "source-shape-mismatch",
                f"contract sourceShape {contract['sourceShape']} differs from inventory {actual_shape}",
                source_path,
            )
        )

    for callable_ in callables:
        qualified_declaration = (callable_.owner, callable_.declaration)
        functions = contract_by_declaration.get(qualified_declaration, [])
        if not functions:
            same_declaration = [
                function
                for (owner, declaration), rows in contract_by_declaration.items()
                if declaration == callable_.declaration and owner != callable_.owner
                for function in rows
            ]
            if same_declaration:
                diagnostics.append(
                    _source_diagnostic(
                        "owner-mismatch",
                        f"contract owner(s) {sorted({item['owner'] for item in same_declaration})} differ from source {callable_.owner}",
                        source_path,
                        callable_,
                    )
                )
            diagnostics.append(
                _source_diagnostic(
                    "uncontracted-callable",
                    "source callable has no owner-qualified exact V2 function row",
                    source_path,
                    callable_,
                )
            )
            continue
        function = functions[0]
        if function["name"] != callable_.name:
            diagnostics.append(_source_diagnostic("function-name-mismatch", f"contract names {function['name']}", source_path, callable_))
        if not _role_matches(function["role"], callable_):
            diagnostics.append(
                _source_diagnostic(
                    "callable-role-mismatch",
                    f"contract role {function['role']} is incompatible with source kind {callable_.kind}",
                    source_path,
                    callable_,
                )
            )
        if _semantic_return(function["return"]["asType"]) != _semantic_return(callable_.return_type):
            diagnostics.append(
                _source_diagnostic(
                    "return-type-mismatch",
                    f"contract return {function['return']['asType']} differs from source {callable_.return_type or 'void'}",
                    source_path,
                    callable_,
                )
            )
        if list(callable_.annotations) != function["annotations"]:
            diagnostics.append(
                _source_diagnostic(
                    "annotation-mismatch",
                    f"contract annotations {function['annotations']!r} differ from source {list(callable_.annotations)!r}",
                    source_path,
                    callable_,
                )
            )
        if contract["namespace"] and contract["namespace"] != callable_.scope:
            diagnostics.append(
                _source_diagnostic(
                    "namespace-mismatch",
                    f"contract namespace {contract['namespace']!r} differs from source {callable_.scope!r}",
                    source_path,
                    callable_,
                )
            )
        source_parameters = callable_.parameters
        contract_parameters = function["parameters"]
        if len(source_parameters) != len(contract_parameters):
            diagnostics.append(
                _source_diagnostic(
                    "parameter-contract-mismatch",
                    f"source has {len(source_parameters)} parameters but contract has {len(contract_parameters)}",
                    source_path,
                    callable_,
                )
            )
        for index, (source_parameter, contract_parameter) in enumerate(zip(source_parameters, contract_parameters)):
            if source_parameter.name != contract_parameter["name"] or " ".join(source_parameter.as_type.split()) != " ".join(contract_parameter["asType"].split()):
                diagnostics.append(
                    _source_diagnostic(
                        "parameter-contract-mismatch",
                        f"parameter {index} name/type differs between source and contract",
                        source_path,
                        callable_,
                    )
                )
            if source_parameter.direction != contract_parameter["direction"]:
                diagnostics.append(
                    _source_diagnostic(
                        "parameter-direction-mismatch",
                        f"parameter {source_parameter.name} direction {source_parameter.direction} differs from contract {contract_parameter['direction']}",
                        source_path,
                        callable_,
                    )
                )
            if source_parameter.default != contract_parameter.get("default"):
                diagnostics.append(
                    _source_diagnostic(
                        "parameter-default-mismatch",
                        f"parameter {source_parameter.name} default {source_parameter.default!r} differs from contract {contract_parameter.get('default')!r}",
                        source_path,
                        callable_,
                    )
                )
        diagnostics.extend(_comment_diagnostics(contract, function, callable_))

    for owner, declaration in sorted(set(contract_by_declaration) - set(source_by_declaration)):
        diagnostics.append(
            Diagnostic(
                "declaration-mismatch",
                f"contract declaration under owner {owner} is absent or differs byte-for-byte from source",
                source_path,
                declaration=declaration,
            )
        )
    return diagnostics


def audit_testsource(
    testsource_root: Path,
    contracts_root: Path,
    *,
    mode: str = "audit",
    domains: Iterable[str] = (),
) -> AuditReport:
    if mode not in {"audit", "strict"}:
        raise ValueError("mode must be audit or strict")
    normalized_domains = tuple(sorted({normalize_domain(domain) for domain in domains}))
    sources = discover_sources(testsource_root, normalized_domains)
    diagnostics: list[Diagnostic] = []
    contracts: list[tuple[Path, dict[str, Any]]] = []

    for path in contract_paths(contracts_root):
        try:
            contract = read_contract(path)
        except (OSError, ValueError, json.JSONDecodeError) as error:
            diagnostics.append(Diagnostic("invalid-contract-json", str(error), path.as_posix()))
            continue
        source_path = str(contract.get("sourcePath") or "")
        if normalized_domains and source_path and not _selected(source_path, normalized_domains):
            continue
        contracts.append((path, contract))
        diagnostics.extend(validate_contract_document(contract))

    source_contracts: dict[str, list[tuple[Path, dict[str, Any]]]] = {}
    case_ids: dict[str, list[str]] = {}
    identities: dict[tuple[str, str], list[str]] = {}
    function_identities: dict[tuple[str, str], list[str]] = {}
    for path, contract in contracts:
        source_path = str(contract.get("sourcePath") or "")
        if not source_path:
            continue
        source_contracts.setdefault(source_path, []).append((path, contract))
        case_ids.setdefault(str(contract.get("caseId") or ""), []).append(source_path)
        identity = (str(contract.get("caseId") or ""), str(contract.get("subcaseId") or ""))
        identities.setdefault(identity, []).append(source_path)
        for function in contract.get("functions") or []:
            function_identity = (str(contract.get("caseId") or ""), str(function.get("subcaseId") or ""))
            function_identities.setdefault(function_identity, []).append(source_path)
        expected_path = expected_contract_path(contracts_root, source_path)
        if path.resolve() != expected_path.resolve():
            diagnostics.append(
                Diagnostic(
                    "contract-location-mismatch",
                    f"contract must be generated at {expected_path.relative_to(contracts_root).as_posix()}",
                    source_path,
                )
            )
        if not resolve_source_path(testsource_root, source_path).is_file():
            diagnostics.append(Diagnostic("stale-source-path", "contract sourcePath does not exist", source_path))

    for case_id, source_paths in sorted(case_ids.items()):
        if len(source_paths) > 1:
            for source_path in sorted(source_paths):
                diagnostics.append(Diagnostic("duplicate-case-id", f"duplicate CaseId {case_id}", source_path))
    for identity, source_paths in sorted(identities.items()):
        if len(source_paths) > 1:
            for source_path in sorted(source_paths):
                diagnostics.append(Diagnostic("duplicate-case-subcase", f"duplicate case/subcase {identity[0]}/{identity[1]}", source_path))
    for identity, source_paths in sorted(function_identities.items()):
        if len(source_paths) > 1:
            for source_path in sorted(source_paths):
                diagnostics.append(Diagnostic("duplicate-function-identity", f"duplicate function identity {identity[0]}/{identity[1]}", source_path))
    for source_path, rows in sorted(source_contracts.items()):
        if len(rows) > 1:
            diagnostics.append(Diagnostic("duplicate-source-contract", "sourcePath has more than one contract", source_path))

    callable_count = 0
    source_logicals = {logical_source_path(testsource_root, path) for path in sources}
    for source in sources:
        source_path = logical_source_path(testsource_root, source)
        text = source.read_text(encoding="utf-8-sig")
        inventory = inventory_source(text, source_path)
        callable_count += len(inventory.callables)
        rows = source_contracts.get(source_path, [])
        if not rows:
            diagnostics.append(
                Diagnostic(
                    "missing-contract",
                    "source has no authored-case-contract-v2 document",
                    source_path,
                    severity="warning" if mode == "audit" else "error",
                )
            )
        for callable_ in inventory.callables:
            diagnostics.extend(_source_only_diagnostics(source_path, callable_, require_comment=True))
        if len(rows) == 1:
            contract_diagnostics = validate_contract_document(rows[0][1])
            if not any(item.code == "schema-invalid" for item in contract_diagnostics):
                diagnostics.extend(_parity_diagnostics(rows[0][1], inventory.callables))
            if mode == "strict" and not any(item.code == "schema-invalid" for item in contract_diagnostics) and rows[0][1]["review"]["state"] != "reviewed":
                diagnostics.append(Diagnostic("contract-not-reviewed", "strict mode requires reviewed contract", source_path))

    for source_path in sorted(set(source_contracts) - source_logicals):
        if resolve_source_path(testsource_root, source_path).is_file():
            diagnostics.append(Diagnostic("domain-selection-mismatch", "selected contract source was not discovered", source_path))

    unique_diagnostics = {
        (item.code, item.message, item.source_path, item.line, item.declaration, item.severity): item
        for item in diagnostics
    }
    ordered = tuple(sorted(unique_diagnostics.values(), key=diagnostic_sort_key))
    return AuditReport(mode, normalized_domains, len(sources), len(contracts), callable_count, ordered)


def validate_contract_against_source(
    testsource_root: Path,
    contract: dict[str, Any],
    *,
    require_reviewed: bool = True,
) -> tuple[Diagnostic, ...]:
    """Validate one in-memory V2 contract at the active export boundary.

    This intentionally performs document and current-source parity checks only;
    repository-global CaseId uniqueness remains the projection/full-audit gate.
    """

    diagnostics = list(validate_contract_document(contract))
    if any(item.code == "schema-invalid" for item in diagnostics):
        return tuple(sorted(diagnostics, key=diagnostic_sort_key))
    source_path = contract["sourcePath"]
    source = resolve_source_path(testsource_root, source_path)
    if not source.is_file():
        diagnostics.append(Diagnostic("stale-source-path", "contract sourcePath does not exist", source_path))
    else:
        inventory = inventory_source(source.read_text(encoding="utf-8-sig"), source_path)
        for callable_ in inventory.callables:
            diagnostics.extend(_source_only_diagnostics(source_path, callable_, require_comment=True))
        diagnostics.extend(_parity_diagnostics(contract, inventory.callables))
    if require_reviewed and contract["review"]["state"] != "reviewed":
        diagnostics.append(Diagnostic("contract-not-reviewed", "active use requires reviewed contract", source_path))
    unique = {
        (item.code, item.message, item.source_path, item.line, item.declaration, item.severity): item
        for item in diagnostics
    }
    return tuple(sorted(unique.values(), key=diagnostic_sort_key))
