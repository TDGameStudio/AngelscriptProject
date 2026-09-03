"""Deterministic, non-authoritative index and task projections for V2 contracts."""

from __future__ import annotations

from collections import Counter, defaultdict
import json
from pathlib import Path
from typing import Any

from .audit_v2 import audit_testsource, discover_sources, logical_source_path, source_domain
from .contract_v2 import canonical_json, contract_paths, read_contract, validate_contract_document


INDEX_SCHEMA_VERSION = "authored-case-index-v2"


class ProjectionError(RuntimeError):
    def __init__(self, message: str, diagnostic_codes: tuple[str, ...] = ()) -> None:
        super().__init__(message)
        self.diagnostic_codes = diagnostic_codes


def load_projection_contracts(contracts_root: Path) -> tuple[dict[str, Any], ...]:
    result: list[dict[str, Any]] = []
    for path in contract_paths(contracts_root):
        contract = read_contract(path)
        diagnostics = validate_contract_document(contract)
        if diagnostics:
            raise ProjectionError(
                f"contract {path} is not projection-clean",
                tuple(sorted({item.code for item in diagnostics})),
            )
        if contract["review"]["state"] != "reviewed":
            raise ProjectionError(f"contract {path} is not reviewed", ("contract-not-reviewed",))
        result.append(contract)
    return tuple(sorted(result, key=lambda item: (item["sourcePath"], item["caseId"], item.get("subcaseId", ""))))


def build_index(testsource_root: Path, contracts: tuple[dict[str, Any], ...]) -> dict[str, Any]:
    sources = tuple(logical_source_path(testsource_root, path) for path in discover_sources(testsource_root))
    source_set = set(sources)
    contracted_sources = {contract["sourcePath"] for contract in contracts}
    reviewed_sources = {
        contract["sourcePath"] for contract in contracts if contract["review"]["state"] == "reviewed"
    }
    source_strict_statuses = {
        "strict-pass",
        "compile-verified",
        "runtime-verified",
        "external-oracle-verified",
    }
    strict_sources = {
        contract["sourcePath"]
        for contract in contracts
        if contract["coverage"]["status"] in source_strict_statuses
    }
    if not contracts:
        coverage_state = "migration-pending"
    elif contracted_sources != source_set:
        coverage_state = "partial"
    elif reviewed_sources != source_set:
        coverage_state = "complete-draft"
    elif strict_sources == source_set:
        coverage_state = "complete-source-strict"
    else:
        coverage_state = "complete-reviewed"

    source_counts = Counter(source_domain(source) for source in sources)
    contract_counts = Counter(source_domain(contract["sourcePath"]) for contract in contracts)
    reviewed_counts = Counter(
        source_domain(contract["sourcePath"])
        for contract in contracts
        if contract["review"]["state"] == "reviewed"
    )
    domains = []
    for domain in sorted(set(source_counts) | set(contract_counts)):
        source_count = source_counts[domain]
        contract_count = contract_counts[domain]
        if contract_count == 0:
            state = "unmigrated"
        elif contract_count < source_count:
            state = "partial"
        elif reviewed_counts[domain] == contract_count:
            state = "reviewed"
        else:
            state = "draft"
        domains.append(
            {
                "domain": domain,
                "sourceCount": source_count,
                "contractCount": contract_count,
                "reviewedCount": reviewed_counts[domain],
                "coverageState": state,
            }
        )
    entries = [
        {
            "caseId": contract["caseId"],
            "subcaseId": contract.get("subcaseId", ""),
            "sourcePath": contract["sourcePath"],
            "domain": source_domain(contract["sourcePath"]),
            "functionCount": len(contract["functions"]),
            "reviewState": contract["review"]["state"],
            "coverageStatus": contract["coverage"]["status"],
        }
        for contract in contracts
    ]
    return {
        "schemaVersion": INDEX_SCHEMA_VERSION,
        "authority": "projection-only; edit per-source V2 contracts",
        "coverageState": coverage_state,
        "totals": {
            "sourceCount": len(sources),
            "contractCount": len(contracts),
            "reviewedContractCount": len(reviewed_sources),
            "strictPassContractCount": len(strict_sources),
            "uncontractedSourceCount": len(source_set - contracted_sources),
        },
        "domains": domains,
        "entries": entries,
    }


def task_filename(domain: str) -> str:
    return (domain.replace("/", "__") or "Root") + ".md"


def _one_line_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def render_task(domain: str, contracts: list[dict[str, Any]]) -> str:
    lines = [
        f"# Contract V2 projection — {domain or 'Root'}",
        "",
        "> Generated from reviewed Contract V2 JSON. This file is a projection, not an authority.",
        "",
    ]
    for contract in sorted(contracts, key=lambda item: (item["sourcePath"], item["caseId"])):
        lines.extend(
            [
                f"## `{contract['sourcePath']}` — {contract['caseId']}",
                "",
                f"- Review: `{contract['review']['state']}`; coverage: `{contract['coverage']['status']}`",
                f"- Execution: `{contract['executionProfile']['mode']}` / `{contract['executionProfile']['isolation']}`",
                "",
            ]
        )
        for function in contract["functions"]:
            facts = function["commentFacts"]
            lines.extend(
                [
                    f"### [ ] `{contract['caseId']}/{function['subcaseId']}` → `{function['name']}`",
                    "",
                    f"- Owner: `{function['owner']}`; role: `{function['role']}`",
                    f"- Old declaration: `{function['legacyDeclaration'] or '(none)'}`",
                    "- Exact declaration:",
                    "",
                    "```angelscript",
                    function["declaration"],
                    "```",
                    "",
                    f"- typed vectors: `{_one_line_json(function['vectors'])}`",
                    f"- Parameters/return/writebacks: `{_one_line_json({'parameters': function['parameters'], 'return': function['return'], 'writebacks': function['writebacks']})}`",
                    f"- Comment summary: {facts['purpose']}; inputs {facts['inputs']}; outputs {facts['outputs']}; boundary {facts['boundary']}; cleanup {facts['cleanup']}.",
                    f"- Fixture/phase/cleanup: `{_one_line_json(function['fixture'])}` / `{function['phase']}` / `{function['cleanupOwner']}`",
                    "",
                ]
            )
        lines.extend(
            [
                "Verification:",
                "",
                "```powershell",
                f"python TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain {domain}",
                "```",
                "",
            ]
        )
    return "\n".join(lines).rstrip() + "\n"


def write_projections(testsource_root: Path, contracts_root: Path, tasks_root: Path) -> tuple[Path, ...]:
    report = audit_testsource(testsource_root, contracts_root, mode="strict")
    if not report.clean:
        raise ProjectionError(
            f"projection blocked by {len(report.diagnostics)} strict audit diagnostic(s)",
            tuple(sorted(report.counts_by_code)),
        )

    # The audit above is deliberately complete before the first filesystem
    # mutation.  Dirty inputs therefore cannot truncate an existing index or
    # delete a task projection.
    contracts_root.mkdir(parents=True, exist_ok=True)
    tasks_root.mkdir(parents=True, exist_ok=True)
    contracts = load_projection_contracts(contracts_root)
    index_path = contracts_root / "index.json"
    index_path.write_text(canonical_json(build_index(testsource_root, contracts)), encoding="utf-8", newline="\n")

    by_domain: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for contract in contracts:
        by_domain[source_domain(contract["sourcePath"])].append(contract)
    expected_task_paths = {tasks_root / task_filename(domain) for domain in by_domain}
    for stale_path in sorted(tasks_root.glob("*.md"), key=lambda path: path.name):
        if stale_path not in expected_task_paths:
            stale_path.unlink()
    written = [index_path]
    for domain in sorted(by_domain):
        path = tasks_root / task_filename(domain)
        path.write_text(render_task(domain, by_domain[domain]), encoding="utf-8", newline="\n")
        written.append(path)
    return tuple(written)
