#!/usr/bin/env python3
"""Normalize domain audits into the exhaustive Contract V2 OpenSpec plan.

The script is intentionally OpenSpec-local. It reads TestSource only through the
already-frozen reconciliation/source hashes and never edits TestSource.
"""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import sys
from typing import Any, Iterable

from jsonschema import Draft202012Validator

import RenderExhaustiveContractV2Tasks as renderer
from AuditNormalizedPlanQuality import (
    audit_file_rows as audit_quality_file_rows,
    audit_row as audit_quality_row,
)


PLAN_REVISION = "plan-v2"
GENERATED_ON = "2026-08-24"
DOMAIN_ORDER = renderer.DOMAIN_ORDER
DOMAIN_FILES = {
    "Bindings/TArray": "Bindings-TArray.jsonl",
    "Containers/TArray": "Containers-TArray.jsonl",
    "Bindings": "Bindings.jsonl",
    "Containers": "Containers.jsonl",
    "Optional": "Optional.jsonl",
    "Language": "Language.jsonl",
    "Definitions": "Definitions.jsonl",
    "Feature": "Feature.jsonl",
    "World": "World.jsonl",
    "Gameplay": "Gameplay.jsonl",
    "HotReload": "HotReload.jsonl",
    "TestFramework": "TestFramework.jsonl",
    "Debugger": "Debugger.jsonl",
}
ALLOWED_KINDS = {"function", "method", "constructor", "destructor", "operator", "delegate", "event", "import", "mixin", "lambda"}
LEGACY_PATTERN = re.compile(r"(?:\bObserve_|\bSurface\d+|_Nominal\b|\bExerciseExpectedFailure\b)")
PLACEHOLDER_PATTERN = re.compile(r"(?:\bVariant\d+\b|\bObservedCondition\d+\b|\.\.\.)")
QUALITY_BLOCKER_CODES = {
    "blueprint-state-reader-missing": "signature-unresolved",
    "diagnostic-only-runtime-contract": "fixture-unresolved",
    "derived-condition-output": "signature-unresolved",
    "direct-dispatch-contract-contradiction": "fixture-unresolved",
    "external-oracle-classification-required": "external-oracle-unresolved",
    "generic-purpose-comment": "comment-unresolved",
    "known-lifecycle-oracle-contradiction": "vector-unresolved",
    "post-dispatch-reader-missing": "signature-unresolved",
    "process-event-driver-missing": "fixture-unresolved",
    "raw-return-oracle-missing": "vector-unresolved",
    "required-name-reason-missing": "signature-unresolved",
    "retirement-transfer-link-missing": "coverage-unresolved",
    "unstructured-input-vector": "vector-unresolved",
    "writeback-channel-missing": "signature-unresolved",
}


def canonical_bytes(value: Any) -> bytes:
    return (json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n").encode("utf-8")


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def domain_for(source_path: str) -> str:
    parts = source_path.removeprefix("TestSource/").split("/")
    if parts[0] in {"Bindings", "Containers"} and len(parts) > 1 and parts[1] == "TArray":
        return f"{parts[0]}/TArray"
    return parts[0]


def slug(value: str) -> str:
    result = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return result or "source"


def normalize_direction(value: str | None, as_type: str = "") -> str:
    raw = (value or "").lower()
    if raw in {"value", "in", "out", "inout"}:
        return raw
    match = re.search(r"&\s*(inout|in|out)\b", as_type)
    if match:
        return match.group(1)
    if "&" in as_type:
        return "in"
    return "value"


def declaration_parameter_text(parameter: dict[str, Any]) -> str:
    if parameter.get("declaration"):
        return str(parameter["declaration"])
    as_type = parameter.get("asType") or parameter.get("type") or "unknown"
    name = parameter.get("name") or "Value"
    default = parameter.get("default")
    return f"{as_type} {name}" + (f" = {default}" if default is not None else "")


def normalize_parameters(parameters: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for parameter in parameters or []:
        as_type = str(parameter.get("asType") or parameter.get("type") or parameter.get("declaration") or "unknown")
        result.append(
            {
                "declaration": declaration_parameter_text(parameter),
                "name": str(parameter.get("name") or "Value"),
                "asType": as_type,
                "direction": normalize_direction(parameter.get("direction"), as_type),
                "default": parameter.get("default"),
                "valueSource": str(parameter.get("valueSource") or parameter.get("source") or "contract vector"),
            }
        )
    return result


def split_top_level(value: str, delimiter: str) -> list[str]:
    """Split an AngelScript declaration fragment without breaking nested types/defaults."""
    result: list[str] = []
    start = 0
    depth = {"(": 0, "[": 0, "{": 0, "<": 0}
    closing = {")": "(", "]": "[", "}": "{", ">": "<"}
    quote: str | None = None
    escaped = False
    for index, character in enumerate(value):
        if quote is not None:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = None
            continue
        if character in {'"', "'"}:
            quote = character
            continue
        if character in depth:
            depth[character] += 1
            continue
        if character in closing:
            opener = closing[character]
            depth[opener] = max(0, depth[opener] - 1)
            continue
        if character == delimiter and not any(depth.values()):
            result.append(value[start:index].strip())
            start = index + 1
    result.append(value[start:].strip())
    return [item for item in result if item]


def parse_declaration_parameters(declaration: str) -> list[dict[str, Any]] | None:
    """Recover exact parameter channels when an audit preserved only the full declaration."""
    lines = declaration.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    annotation_only = re.compile(r"^\s*(?:UFUNCTION|UPROPERTY|UCLASS|USTRUCT|UENUM|UMETA)\s*(?:\([^)]*\))?\s*$")
    while lines and annotation_only.match(lines[0]):
        lines.pop(0)
    signature = " ".join(line.strip() for line in lines if line.strip())
    inline_annotation = re.compile(r"^\s*(?:UFUNCTION|UPROPERTY|UCLASS|USTRUCT|UENUM|UMETA)\s*(?:\([^)]*\))?\s*")
    while inline_annotation.match(signature):
        signature = inline_annotation.sub("", signature, count=1)
    open_index = signature.find("(")
    if open_index < 0:
        return None
    depth = 0
    close_index = -1
    quote: str | None = None
    escaped = False
    for index in range(open_index, len(signature)):
        character = signature[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = None
            continue
        if character in {'"', "'"}:
            quote = character
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                close_index = index
                break
    if close_index < 0:
        return None
    parameter_text = signature[open_index + 1:close_index].strip()
    if not parameter_text or parameter_text == "void":
        return []
    result: list[dict[str, Any]] = []
    for index, raw_parameter in enumerate(split_top_level(parameter_text, ","), start=1):
        default_parts = split_top_level(raw_parameter, "=")
        declaration_without_default = default_parts[0].strip()
        default = "=".join(default_parts[1:]).strip() if len(default_parts) > 1 else None
        name_match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*$", declaration_without_default)
        if not name_match:
            return None
        name = name_match.group(1)
        as_type = declaration_without_default[:name_match.start()].strip()
        if not as_type:
            return None
        direction = normalize_direction(None, as_type)
        result.append(
            {
                "declaration": raw_parameter,
                "name": name,
                "asType": as_type,
                "direction": direction,
                "default": default,
                "valueSource": "writeback target" if direction == "out" else "contract vector",
            }
        )
    return result


def complete_signature_channels(rows: list[dict[str, Any]]) -> None:
    """Make declaration parameters/out channels explicit without inventing values or oracles."""
    for row in rows:
        proposal = row.get("proposal")
        if not proposal or not proposal.get("declaration"):
            continue
        parsed = parse_declaration_parameters(proposal["declaration"])
        if parsed is None:
            if not any(blocker["code"] == "signature-unresolved" for blocker in row["blockers"]):
                row["blockers"].append(
                    {
                        "rawCode": "parameter-channel-parse-required",
                        "code": "signature-unresolved",
                        "field": "proposal.parameters",
                        "reason": "The exact declaration is recorded, but its parameter channels could not be normalized deterministically.",
                        "evidenceNeeded": "Record every exact parameter declaration, name, AngelScript type, default, and in/out/inout direction before source implementation.",
                    }
                )
            continue
        known_parameters = {parameter["name"] for parameter in proposal["parameters"]}
        known_writebacks = {str(writeback.get("name") or "") for writeback in proposal["writebacks"]}
        for parameter in parsed:
            if parameter["direction"] != "out" and parameter["name"] not in known_parameters:
                proposal["parameters"].append(parameter)
                known_parameters.add(parameter["name"])
            if parameter["direction"] in {"out", "inout"} and parameter["name"] not in known_writebacks:
                proposal["writebacks"].append(
                    {
                        "declaration": parameter["declaration"],
                        "name": parameter["name"],
                        "type": parameter["asType"],
                        "direction": parameter["direction"],
                        "default": parameter["default"],
                    }
                )
                known_writebacks.add(parameter["name"])


def inject_quality_blockers(rows: list[dict[str, Any]]) -> None:
    """Convert semantic self-audit failures into explicit pre-implementation tasks."""
    rows_by_source: dict[str, list[dict[str, Any]]] = defaultdict(list)

    def append_finding(row: dict[str, Any], item: dict[str, str]) -> None:
        existing = {
            (blocker.get("field"), blocker.get("reason")) for blocker in row["blockers"]
        }
        identity = (item["field"], item["reason"])
        if identity in existing:
            return
        row["blockers"].append(
            {
                "rawCode": item["code"],
                "code": QUALITY_BLOCKER_CODES[item["code"]],
                "field": item["field"],
                "reason": item["reason"],
                "evidenceNeeded": item["evidenceNeeded"],
            }
        )

    for row in rows:
        rows_by_source[row["sourcePath"]].append(row)
        for item in audit_quality_row(row):
            append_finding(row, item)

    for source_rows in rows_by_source.values():
        for row, item in audit_quality_file_rows(source_rows):
            append_finding(row, item)


def normalize_vectors(vectors: Iterable[Any], case_id: str, subcase_id: str, fixture_identity: str) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for index, vector in enumerate(vectors or [], start=1):
        if isinstance(vector, str):
            raw = {"evidence": vector}
            vector_id = f"{case_id}/{subcase_id}/vector-{index:02d}"
            phase = "invoke"
            arguments: dict[str, Any] = {}
            expected = raw
            post_failure: list[dict[str, Any]] = []
        else:
            raw = dict(vector)
            vector_id = str(raw.get("vectorId") or raw.get("id") or f"{case_id}/{subcase_id}/vector-{index:02d}")
            phase = str(raw.get("phase") or raw.get("vectorKind") or raw.get("executionState") or "invoke")
            arguments = raw.get("arguments") or raw.get("typedInputs") or raw.get("inputBindings") or {}
            if not isinstance(arguments, dict):
                arguments = {"evidence": arguments}
            expected = {
                key: value
                for key, value in raw.items()
                if key
                not in {
                    "vectorId",
                    "id",
                    "phase",
                    "vectorKind",
                    "executionState",
                    "arguments",
                    "typedInputs",
                    "inputBindings",
                    "omittedArguments",
                    "fixtureInputs",
                    "postFailureState",
                }
            }
            if not expected:
                expected = {"reviewEvidence": raw}
            post_failure = raw.get("postFailureState") or []
            if not isinstance(post_failure, list):
                post_failure = [{"evidence": post_failure}]
        result.append(
            {
                "vectorId": vector_id,
                "phase": phase,
                "arguments": arguments,
                "omittedArguments": list(raw.get("omittedArguments") or []) if isinstance(raw, dict) else [],
                "fixtureInputs": dict(raw.get("fixtureInputs") or {"identity": fixture_identity}) if isinstance(raw, dict) else {"identity": fixture_identity},
                "expected": expected,
                "postFailureState": post_failure,
            }
        )
    return result


def blocker_code(raw_code: str, field: str, reason: str) -> str:
    text = f"{raw_code} {field} {reason}".lower()
    if "duplicate" in text:
        return "signature-unresolved"
    if "line" in text or "debugger" in text or "sourceposition" in text:
        return "line-map-unresolved"
    if "owner" in text or "scanner" in text or "artifact" in text or "inventory" in text:
        return "owner-kind-unresolved" if "owner" in text or "scanner" in text else "inventory-drift"
    if "vector" in text or "diagnostic" in text or "matcher" in text or "oracle" in text or "expected" in text:
        return "vector-unresolved"
    if "signature" in text or "declaration" in text or "duplicate" in text or "raw-type" in text or "condition" in text:
        return "signature-unresolved"
    if "fixture" in text or "cleanup" in text or "phase" in text or "world" in text or "dispatch" in text:
        return "fixture-unresolved"
    if "compile" in text or "abi" in text or "marshal" in text or "probe" in text:
        return "compile-probe-required"
    if "runner" in text:
        return "runner-blocked"
    return "coverage-unresolved"


def raw_blockers(items: Iterable[Any], default_field: str = "plan") -> list[dict[str, str]]:
    result: list[dict[str, str]] = []
    for item in items or []:
        if isinstance(item, str):
            raw_code = "evidence-required"
            field = default_field
            reason = item
            evidence = item
        else:
            raw_code = str(item.get("code") or "evidence-required")
            field = str(item.get("field") or default_field)
            reason = str(item.get("reason") or item.get("evidenceRequired") or raw_code)
            evidence = str(item.get("evidenceNeeded") or item.get("evidenceRequired") or reason)
        result.append(
            {
                "rawCode": raw_code,
                "code": blocker_code(raw_code, field, reason),
                "field": field,
                "reason": reason,
                "evidenceNeeded": evidence,
            }
        )
    return result


def current_record(
    identity: str,
    line: int,
    owner: str,
    kind: str,
    annotations: Iterable[str],
    declaration: str,
    body_sha: str | None,
) -> dict[str, Any]:
    return {
        "identity": identity,
        "line": int(line),
        "owner": owner or "::",
        "kind": kind if kind in ALLOWED_KINDS else "function",
        "annotations": list(annotations or []),
        "declaration": declaration,
        "bodySha256": body_sha,
    }


def comment_record(exact_text: str | list[str], case_id: str, subcase_id: str, current: dict[str, Any] | None, cleanup: str) -> dict[str, Any]:
    text = "\n".join(exact_text) if isinstance(exact_text, list) else str(exact_text)
    if not text.startswith("//"):
        text = f"// {text}"
    placement = "source-level" if current is None else ("above-first-annotation" if current["annotations"] else ("above-containing-lambda-expression" if current["kind"] == "lambda" else "above-declaration"))
    return {
        "exactText": text,
        "placement": placement,
        "caseAndSubcase": f"{case_id}/{subcase_id}",
        "purpose": text,
        "inputsOrFixture": "Typed parameters and fixture inputs are frozen by this plan row.",
        "outputsOrEffects": "Raw return, writebacks, diagnostics, and side effects are frozen by this plan row.",
        "boundary": "Expected values remain in typed vectors; the source does not receive Expected* values.",
        "cleanup": cleanup,
    }


def fixture_record(
    raw: Any,
    cleanup: Any,
    diagnostic: bool,
    framework: bool,
    owner: str,
    phases: Iterable[str] | None = None,
) -> dict[str, Any]:
    fixture = raw if isinstance(raw, dict) else {"description": str(raw or "pure-value/module fixture")}
    cleanup_obj = cleanup if isinstance(cleanup, dict) else {"owner": "runner", "actions": [str(cleanup or "runner releases module and fixture state")], "on": []}
    required_harness = fixture.get("requiredHarness") or fixture.get("harness") or []
    if isinstance(required_harness, str):
        required_harness = [required_harness]
    kind = str(fixture.get("kind") or fixture.get("description") or "ValueOrModule")
    instance_kind = str(fixture.get("instanceKind") or fixture.get("identity") or kind)
    phase_values = list(phases or fixture.get("phases") or ["arrange fixture", "invoke exact declaration", "observe raw channels", "cleanup"])
    cleanup_actions = cleanup_obj.get("actions") or [cleanup_obj.get("description") or str(cleanup_obj)]
    cleanup_on = cleanup_obj.get("on") or ["success", "assertion-failure", "expected-diagnostic", "timeout", "early-exit"]
    return {
        "executionMode": "DiagnosticOnly" if diagnostic else ("Framework" if framework else "Runtime"),
        "requiredHarness": sorted({str(value) for value in required_harness}),
        "kind": kind,
        "instanceKind": instance_kind,
        "identity": str(fixture.get("identity") or instance_kind),
        "owner": str(fixture.get("setupOwner") or fixture.get("owner") or owner or "runner"),
        "invocationDriver": str(fixture.get("dispatchAuthority") or fixture.get("invocationDriver") or ("compiler diagnostic driver" if diagnostic else "typed contract runner")),
        "phases": phase_values or ["invoke"],
        "cleanupOwner": str(cleanup_obj.get("owner") or fixture.get("cleanupOwner") or "runner"),
        "cleanupActions": [str(value) for value in cleanup_actions if str(value)],
        "cleanupOn": [value for value in cleanup_on if value in {"success", "assertion-failure", "expected-diagnostic", "timeout", "early-exit"}] or ["success", "assertion-failure", "expected-diagnostic", "timeout", "early-exit"],
        "isolation": str(fixture.get("isolation") or "fresh fixture/module per mutating, diagnostic, and lifecycle vector"),
    }


def coverage_record(audit_path: str, evidence: Iterable[Any], surfaces: Iterable[Any] = (), high_risk: Iterable[Any] = (), authored_rule: str | None = None) -> dict[str, Any]:
    surface_ids: list[str] = []
    primary_apis: list[str] = []
    for surface in surfaces or []:
        if isinstance(surface, dict):
            value = str(surface.get("surfaceId") or surface.get("signature") or "")
        else:
            value = str(surface)
        if value:
            surface_ids.append(value)
            primary_apis.append(value)
    cpp_evidence = [str(value) for value in evidence or [] if str(value)]
    return {
        "authoredRule": authored_rule,
        "bindingIds": [],
        "surfaceIds": surface_ids,
        "primaryApis": primary_apis,
        "cppEvidence": cpp_evidence,
        "inventoryEvidence": [audit_path],
        "highRiskDirectives": [str(value) for value in high_risk or [] if str(value)],
    }


def status_record(blockers: list[dict[str, Any]], runner_blocked: bool) -> dict[str, str]:
    return {
        "design": "blocked" if any(item["code"] != "runner-blocked" for item in blockers) else "review-ready",
        "implementation": "not-started",
        "sourceStrict": "blocked" if blockers else "not-run",
        "compile": "runner-blocked" if runner_blocked else "not-run",
        "runtime": "runner-blocked" if runner_blocked else "not-run",
        "externalOracle": "runner-blocked" if runner_blocked else "not-run",
    }


def proposal_disposition(raw: str, required_reason: str | None, split: bool = False) -> str:
    text = (raw or "").lower()
    if "retire" in text or "superseded" in text or "remove-replaced" in text or "replaced-by-high-risk" in text:
        return "retire-with-replacement"
    if split:
        return "split"
    if required_reason or "required" in text or "keep-fixed" in text:
        return "required-name"
    if "keep" in text:
        return "semantic-keep"
    if "high-risk" in text or "phase" in text:
        return "new-high-risk-phase"
    return "hard-rename"


def verification_record(source_path: str, runner_command: str | None, runner_reason: str) -> dict[str, Any]:
    strict = f"python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain {source_path.removeprefix('TestSource/')} --max-diagnostics 100"
    return {
        "staticCommands": [strict, "openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive"],
        "expectedStaticResult": "After implementation, this exact source has zero Contract V2 strict diagnostics; before implementation the task remains unchecked.",
        "runtimeCommand": runner_command,
        "expectedRuntimeResult": runner_reason,
    }


def base_row(
    source_path: str,
    source_sha: str,
    case_id: str,
    current: dict[str, Any] | None,
    proposal: dict[str, Any] | None,
    source_assertion: dict[str, Any] | None,
    exact_comment: str | list[str],
    vectors: list[dict[str, Any]],
    fixture: dict[str, Any],
    coverage: dict[str, Any],
    blockers: list[dict[str, Any]],
    verification: dict[str, Any],
    audit_path: str,
    audit_hash: str,
    raw_pointer: str,
    batch_raw: str,
    runner_blocked: bool,
) -> dict[str, Any]:
    if current is not None and not current["identity"].startswith(f"{source_path}|"):
        current = dict(current)
        current["identity"] = f"{source_path}|{current['identity']}"
    subcase = proposal["subcaseId"] if proposal else "source-only"
    cleanup_text = "; ".join(fixture["cleanupActions"]) or fixture["cleanupOwner"]
    row = {
        "planRevision": PLAN_REVISION,
        "planRowId": "pending",
        "taskId": "pending",
        "wave": "W00",
        "batch": "B00",
        "fileTaskId": "W00.B00.F0000",
        "sourcePath": source_path,
        "sourceSha256": source_sha,
        "caseId": case_id,
        "sourceOnly": current is None and proposal is None,
        "current": current,
        "proposal": proposal,
        "sourceAssertion": source_assertion,
        "comment": comment_record(exact_comment, case_id, subcase, current, cleanup_text),
        "vectors": vectors,
        "fixture": fixture,
        "coverage": coverage,
        "status": status_record(blockers, runner_blocked),
        "blockers": blockers,
        "verification": verification,
        "provenance": {
            "auditPath": audit_path,
            "auditSha256": audit_hash,
            "rawPointer": raw_pointer,
            "normalizedRowSha256": "0" * 64,
        },
        "_batchRaw": batch_raw or "default",
    }
    if current is None and proposal is not None:
        row["comment"]["placement"] = "above-first-annotation" if proposal.get("declaration", "").lstrip().startswith(("UFUNCTION", "UCLASS", "UPROPERTY")) else "above-declaration"
    return row


def adapt_bco(data: dict[str, Any], audit_path: str, audit_hash: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for file_index, file in enumerate(data["files"]):
        source_path = file["sourcePath"]
        for callable_index, callable_row in enumerate(file["callables"]):
            current_raw = callable_row["current"]
            current = current_record(
                current_raw["qualifiedIdentity"],
                current_raw["line"],
                current_raw["owner"],
                current_raw["kind"],
                current_raw.get("annotations", []),
                current_raw.get("declarationBlock") or current_raw["coreDeclaration"],
                current_raw.get("bodySha256"),
            )
            replacements = callable_row["replacements"]
            if not replacements and callable_row.get("retirement"):
                retirement = callable_row["retirement"]
                blockers = raw_blockers(retirement.get("blockers", []))
                proposal = {
                    "subcaseId": slug(retirement["normalizedSubcaseId"]),
                    "owner": current["owner"],
                    "semanticName": current_raw["name"],
                    "disposition": "retire-with-replacement",
                    "requiredNameReason": None,
                    "declaration": None,
                    "parameters": [],
                    "returnType": None,
                    "writebacks": [],
                    "bodyPlan": ["Remove the redundant aggregate only after all named coverage-transfer rows are accepted."],
                    "prohibitedCalls": ["Do not retain a forwarding alias for the retired aggregate."],
                }
                fixture = fixture_record({}, "Runner verifies coverage transfer and removes no unrelated source.", False, False, current["owner"])
                rows.append(
                    base_row(
                        source_path, file["sourceSha256"], file["caseId"], current, proposal, None,
                        f"// Case {file['caseId']}/{proposal['subcaseId']}. Retire this redundant compound aggregate only after its named semantic replacements retain all coverage; no source alias remains.",
                        [], fixture, coverage_record(audit_path, retirement.get("coverageTransfersTo", [])), blockers,
                        verification_record(source_path, None, "No runtime claim; retirement is accepted only by coverage reconciliation and later strict source validation."),
                        audit_path, audit_hash, f"/files/{file_index}/callables/{callable_index}/retirement", file.get("batch", "default"), False,
                    )
                )
                continue
            for replacement_index, replacement in enumerate(replacements):
                blockers = raw_blockers(replacement.get("blockers", []))
                parameters = normalize_parameters(replacement.get("parameters", []))
                exact_declaration = replacement["exactDeclaration"]
                raw_return = replacement.get("rawReturn", {})
                proposal = {
                    "subcaseId": slug(replacement["normalizedSubcaseId"]),
                    "owner": current["owner"],
                    "semanticName": replacement["semanticName"],
                    "disposition": proposal_disposition(replacement.get("disposition", ""), replacement.get("requiredNameReason"), len(replacements) > 1),
                    "requiredNameReason": replacement.get("requiredNameReason") or None,
                    "declaration": exact_declaration,
                    "parameters": parameters,
                    "returnType": str(raw_return.get("asType") or "void"),
                    "writebacks": list(replacement.get("writebacks", [])),
                    "bodyPlan": list(replacement.get("bodyPlan", {}).get("instructions") or ["Implement only the operation assigned to this semantic replacement and publish its raw channels."]),
                    "prohibitedCalls": list(replacement.get("bodyPlan", {}).get("prohibitedCalls") or []),
                }
                fixture = fixture_record(replacement.get("fixture"), replacement.get("cleanup"), bool(replacement.get("typedVectors") and any(v.get("expectedCompileDiagnostic") for v in replacement["typedVectors"] if isinstance(v, dict))), False, current["owner"])
                vectors = normalize_vectors(replacement.get("typedVectors", []), file["caseId"], proposal["subcaseId"], fixture["identity"])
                runner = replacement.get("runner", {})
                runner_blocked = runner.get("state") == "runner-blocked"
                rows.append(
                    base_row(
                        source_path, file["sourceSha256"], file["caseId"], current, proposal, None,
                        replacement["exactAdjacentEnglishComment"], vectors, fixture,
                        coverage_record(audit_path, runner.get("candidateCppEvidence", []), replacement.get("coverage", {}).get("matchedSurfaces", [])),
                        blockers, verification_record(source_path, None, str(runner.get("reason") or "Runtime/external oracle remains pending a later authorized runner.")),
                        audit_path, audit_hash, f"/files/{file_index}/callables/{callable_index}/replacements/{replacement_index}", file.get("batch", "default"), runner_blocked,
                    )
                )
        if not file["callables"]:
            blockers = raw_blockers(file.get("fileGateBlockers", []), "sourceAssertion")
            if not blockers and "Negative" in file.get("sourceShape", ""):
                blockers = raw_blockers([{"code": "exact-diagnostic-evidence-missing", "field": "sourceAssertion.diagnostic", "reason": "The source-only negative file needs its exact diagnostic matcher and failure phase frozen.", "evidenceNeeded": "Capture the exact matcher from the cited C++ oracle before implementation."}])
            fixture = fixture_record({}, "Runner discards the compiler module and diagnostics on every exit.", True, False, "runner")
            assertion = {"kind": "compile-diagnostic", "exactSourceFacts": [file.get("sourceShape", "source-only contract")], "diagnosticOrState": {"status": "evidence-blocked" if blockers else "review-ready"}, "cleanup": fixture["cleanupActions"][0]}
            vectors = normalize_vectors([{"vectorId": f"{file['caseId']}/source-only", "expected": assertion["diagnosticOrState"]}], file["caseId"], "source-only", fixture["identity"])
            rows.append(base_row(source_path, file["sourceSha256"], file["caseId"], None, None, assertion, f"// CaseId {file['caseId']}; source-only compile contract. Preserve the invalid declaration and verify the exact diagnostic; no helper function is synthesized.", vectors, fixture, coverage_record(audit_path, []), blockers, verification_record(source_path, None, "Compile-diagnostic runner evidence remains pending."), audit_path, audit_hash, f"/files/{file_index}", file.get("batch", "default"), True))
    return rows


def adapt_ldf(data: dict[str, Any], audit_path: str, audit_hash: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    overlays = {item["overridesCurrentQualifiedIdentity"]: item for item in data.get("highRiskOverlays", [])}
    matched_overlays: set[str] = set()
    for index, item in enumerate(data["currentRows"]):
        current_raw = item["current"]
        current = current_record(current_raw["qualifiedIdentity"], current_raw["line"], current_raw["owner"], current_raw["kind"], current_raw.get("annotations", []), current_raw["declaration"], current_raw.get("bodySha256"))
        overlay = overlays.get(current_raw["qualifiedIdentity"])
        if overlay is not None:
            matched_overlays.add(current_raw["qualifiedIdentity"])
        plan = overlay or item["plan"]
        blockers = raw_blockers(plan.get("blockers", []))
        parameters = normalize_parameters(plan.get("typedInputs", []))
        disposition = proposal_disposition(
            "required-name" if overlay is not None and plan.get("requiredNameReason") else plan.get("disposition", "new-high-risk-phase" if overlay is not None else ""),
            plan.get("requiredNameReason"),
        )
        exact = None if disposition == "retire-with-replacement" else plan["proposedExactDeclaration"]
        proposal = {
            "subcaseId": slug(plan.get("subcaseId") or item["subcaseId"]),
            "owner": str(((plan.get("proposedScannerQualifiedIdentity") or current["owner"]).split("|", 1)[0]) or current["owner"]),
            "semanticName": plan["semanticName"],
            "disposition": disposition,
            "requiredNameReason": plan.get("requiredNameReason"),
            "declaration": exact,
            "parameters": parameters,
            "returnType": None if exact is None else str(plan.get("proposedReturnType") or "void"),
            "writebacks": list(plan.get("writebacks", [])),
            "bodyPlan": [str(plan.get("bodyPlan") or "Preserve the current operation while exposing typed raw channels to the runner.")],
            "prohibitedCalls": ["Do not replace external lifecycle/reflection/timer/delegate/GC dispatch with a direct callback call."],
        }
        diagnostic = plan.get("diagnostic", {})
        fixture = fixture_record(plan.get("fixture"), plan.get("cleanupOwnerAndPhase"), diagnostic.get("mode") in {"compile-failure", "compile-diagnostic"}, False, proposal["owner"])
        runner_blocked = "blocked" in str(plan.get("runnerStatus", "")).lower() or bool(blockers)
        metadata = data["fileMetadata"][item["sourcePath"]]
        case_id = plan.get("caseId") or item["caseId"]
        vectors = normalize_vectors(plan.get("typedInputVectors", []), case_id, proposal["subcaseId"], fixture["identity"])
        raw_pointer = f"/highRiskOverlays/{data.get('highRiskOverlays', []).index(overlay)}" if overlay is not None else f"/currentRows/{index}"
        rows.append(base_row(item["sourcePath"], metadata["sourceSha256"], case_id, current, proposal, None, plan["adjacentEnglishComment"], vectors, fixture, coverage_record(audit_path, plan.get("sourceEvidence", metadata.get("sourceEvidence", [])), high_risk=["high-risk-overlay"] if overlay is not None else []), blockers, verification_record(item["sourcePath"], None, "Runtime/external verification is not claimed by the plan-only LDF audit."), audit_path, audit_hash, raw_pointer, metadata.get("theme", "default"), runner_blocked))
    unmatched_overlays = sorted(set(overlays) - matched_overlays)
    if unmatched_overlays:
        raise ValueError(f"LDF high-risk overlays did not match canonical current identities: {unmatched_overlays}")

    for index, plan in enumerate(data.get("highRiskReplacementRows", [])):
        source_path = plan["sourcePath"]
        metadata = data["fileMetadata"][source_path]
        blockers = raw_blockers(plan.get("blockers", []))
        proposal = {
            "subcaseId": slug(plan["subcaseId"]),
            "owner": plan.get("owner") or "::",
            "semanticName": plan["semanticName"],
            "disposition": proposal_disposition("new-high-risk-phase", plan.get("requiredNameReason")),
            "requiredNameReason": plan.get("requiredNameReason"),
            "declaration": plan["proposedExactDeclaration"],
            "parameters": normalize_parameters(plan.get("typedInputs", [])),
            "returnType": str(plan.get("proposedReturnType") or "void"),
            "writebacks": list(plan.get("writebacks", [])),
            "bodyPlan": [str(plan.get("bodyPlan") or "Add the high-risk raw-state phase recorded by the authoritative audit.")],
            "prohibitedCalls": ["Do not replace external lifecycle/reflection/timer/delegate/GC dispatch with a direct callback call."],
        }
        diagnostic = plan.get("diagnostic", {})
        fixture = fixture_record(plan.get("fixture"), plan.get("cleanupOwnerAndPhase"), diagnostic.get("mode") in {"compile-failure", "compile-diagnostic"}, False, proposal["owner"])
        vectors = normalize_vectors(plan.get("typedInputVectors", []), plan["caseId"], proposal["subcaseId"], fixture["identity"])
        runner_blocked = "blocked" in str(plan.get("status", "")).lower() or bool(blockers)
        rows.append(
            base_row(
                source_path,
                metadata["sourceSha256"],
                plan["caseId"],
                None,
                proposal,
                None,
                plan["adjacentEnglishComment"],
                vectors,
                fixture,
                coverage_record(audit_path, plan.get("sourceEvidence", metadata.get("sourceEvidence", [])), high_risk=["high-risk-replacement"]),
                blockers,
                verification_record(source_path, None, "Runtime/external verification is not claimed by the plan-only LDF high-risk audit."),
                audit_path,
                audit_hash,
                f"/highRiskReplacementRows/{index}",
                metadata.get("theme", "default"),
                runner_blocked,
            )
        )
    planned_sources = {row["sourcePath"] for row in rows}
    for source_path, metadata in data["fileMetadata"].items():
        if source_path in planned_sources:
            continue
        diagnostic = metadata.get("diagnostic", {})
        raw_items = []
        if diagnostic.get("blocker"):
            raw_items.append(diagnostic["blocker"])
        blockers = raw_blockers(raw_items, "sourceAssertion.diagnostic")
        fixture = fixture_record(metadata.get("fixture"), metadata.get("cleanupOwnerAndPhase"), metadata.get("negativeDiagnostic", False), False, "runner")
        evidence = metadata.get("sourceEvidence", [])
        assertion = {"kind": "compile-diagnostic" if metadata.get("negativeDiagnostic") else "source-shape", "exactSourceFacts": evidence or [metadata.get("sourceShape", "source-only declaration")], "diagnosticOrState": diagnostic or {"mode": "source-shape"}, "cleanup": metadata.get("cleanupOwnerAndPhase") or fixture["cleanupActions"][0]}
        rows.append(base_row(source_path, metadata["sourceSha256"], metadata["caseId"], None, None, assertion, f"// CaseId {metadata['caseId']}; source-only {assertion['kind']} contract. Preserve the exact declaration/diagnostic surface; no callable is synthesized.", normalize_vectors([{"vectorId": f"{metadata['caseId']}/source-only", "expected": assertion["diagnosticOrState"], "evidence": evidence}], metadata["caseId"], "source-only", fixture["identity"]), fixture, coverage_record(audit_path, evidence), blockers, verification_record(source_path, None, "Source-only compile/reflection verification remains controlled by the cited runner."), audit_path, audit_hash, f"/fileMetadata/{source_path}", metadata.get("theme", "default"), True))
    return rows


def adapt_wghfd(data: dict[str, Any], audit_path: str, audit_hash: str) -> list[dict[str, Any]]:
    source_map = {item["sourcePath"]: item for item in data["sourceRows"]}
    rows: list[dict[str, Any]] = []
    for index, item in enumerate(data["reviewRows"]):
        source = source_map[item["sourcePath"]]
        proposal_raw = item["proposal"]
        current = current_record(item["canonicalCurrentIdentity"], item["currentLine"], item["currentOwner"], item["currentKind"], item.get("currentAnnotations", []), item["currentDeclaration"], proposal_raw.get("bodyPlan", {}).get("currentBodySha256"))
        field_blockers = [
            {"code": "field-evidence-required", "field": blocker.get("field", "plan"), "reason": blocker.get("evidenceRequired", "Field evidence is missing."), "evidenceNeeded": blocker.get("evidenceRequired", "Capture exact evidence.")}
            for blocker in proposal_raw.get("fieldEvidenceBlockers", [])
        ]
        blockers = raw_blockers(field_blockers)
        typed_inputs = [dict(value) for value in proposal_raw.get("typedInputs", [])]
        expected_renames: dict[str, str] = {}
        for value in typed_inputs:
            name = str(value.get("name") or "")
            if name.startswith("Expected") and len(name) > len("Expected"):
                expected_renames[name] = name[len("Expected"):]
            elif name.startswith("bExpect") and len(name) > len("bExpect"):
                expected_renames[name] = "b" + name[len("bExpect"):]
        exact_declaration = proposal_raw["exactDeclaration"]
        for old_name, new_name in expected_renames.items():
            exact_declaration = re.sub(rf"\b{re.escape(old_name)}\b", new_name, exact_declaration)
            for value in typed_inputs:
                if value.get("name") == old_name:
                    value["name"] = new_name
                if value.get("declaration"):
                    value["declaration"] = re.sub(rf"\b{re.escape(old_name)}\b", new_name, str(value["declaration"]))
        if expected_renames:
            blockers.append({
                "rawCode": "expected-parameter-rename-required",
                "code": "signature-unresolved",
                "field": "proposal.parameters",
                "reason": f"Oracle-style parameter names must be renamed before implementation: {expected_renames}.",
                "evidenceNeeded": "Update declaration and body parameter references atomically; expected values remain in typed vectors.",
            })
        parameters = normalize_parameters(typed_inputs)
        proposal = {
            "subcaseId": slug(item["subcaseId"]),
            "owner": proposal_raw.get("owner") or current["owner"],
            "semanticName": proposal_raw["semanticName"],
            "disposition": proposal_disposition("required-name" if proposal_raw.get("requiredName") else "semantic-keep", proposal_raw.get("requiredNameReason")),
            "requiredNameReason": proposal_raw.get("requiredNameReason"),
            "declaration": exact_declaration,
            "parameters": parameters,
            "returnType": str(proposal_raw.get("rawResult", {}).get("type") or "void"),
            "writebacks": list(proposal_raw.get("writebacks", [])),
            "bodyPlan": list(proposal_raw.get("bodyPlan", {}).get("operations") or ["Preserve the exact operation and publish raw channels."]),
            "prohibitedCalls": list(proposal_raw.get("bodyPlan", {}).get("prohibitedCalls") or []),
        }
        diagnostic = bool(proposal_raw.get("diagnostics"))
        fixture = fixture_record(proposal_raw.get("fixture"), source.get("cleanup"), diagnostic, source["domain"] in {"TestFramework", "Debugger"}, proposal["owner"], source.get("fixturePhases"))
        vectors = normalize_vectors(proposal_raw.get("typedVectors", []), item["caseId"], proposal["subcaseId"], fixture["identity"])
        rows.append(base_row(item["sourcePath"], item["sourceSha256"], item["caseId"], current, proposal, None, proposal_raw["immediateEnglishComment"], vectors, fixture, coverage_record(audit_path, source.get("retainedEvidence", []) + source.get("replacedEvidence", []), high_risk=source.get("highRiskSections", [])), blockers, verification_record(item["sourcePath"], None, "The plan-only audit does not claim runtime/external execution; use the exact later driver named by the accepted contract."), audit_path, audit_hash, f"/reviewRows/{index}", source["domain"], bool(blockers) or source["domain"] in {"World", "Gameplay", "HotReload", "TestFramework", "Debugger"}))
    planned_sources = {row["sourcePath"] for row in rows}
    for source_index, source in enumerate(data["sourceRows"]):
        if source["sourcePath"] in planned_sources:
            continue
        plan = source.get("sourceOnlyPlan") or {"kind": "source-shape", "bodyPlan": "Preserve the source declaration/version state."}
        blockers = raw_blockers([{"code": "field-evidence-required", "field": item.get("field", "sourceAssertion"), "reason": item.get("evidenceRequired", "Evidence required"), "evidenceNeeded": item.get("evidenceRequired", "Capture exact evidence") } for item in source.get("fieldEvidenceBlockers", [])])
        fixture = fixture_record({"kind": source.get("fixtureInstanceKind"), "instanceKind": source.get("fixtureInstanceKind")}, source.get("cleanup"), "compile" in str(plan.get("kind", "")), source["domain"] in {"HotReload", "TestFramework", "Debugger"}, "runner", source.get("fixturePhases"))
        assertion = {"kind": "compile-diagnostic" if "compile" in str(plan.get("kind", "")) else ("version-state" if source["domain"] == "HotReload" else "source-shape"), "exactSourceFacts": [str(plan.get("bodyPlan") or plan)], "diagnosticOrState": {"diagnostics": plan.get("diagnostics", []), "hotReloadIdentityMatrix": source.get("hotReloadIdentityMatrix")}, "cleanup": source.get("cleanup") or fixture["cleanupActions"][0]}
        vectors = normalize_vectors([{"vectorId": f"{source['caseId']}/source-only", "expected": assertion["diagnosticOrState"]}], source["caseId"], "source-only", fixture["identity"])
        rows.append(base_row(source["sourcePath"], source["sourceSha256"], source["caseId"], None, None, assertion, f"// CaseId {source['caseId']}; source-only {assertion['kind']} contract. Preserve the exact diagnostic/version/type surface; no callable is synthesized.", vectors, fixture, coverage_record(audit_path, source.get("retainedEvidence", []) + source.get("replacedEvidence", []), high_risk=source.get("highRiskSections", [])), blockers, verification_record(source["sourcePath"], None, "Source-only external verification remains runner-blocked until the cited driver is authorized."), audit_path, audit_hash, f"/sourceRows/{source_index}", source["domain"], True))
    return rows


def adapt_tarrays(reconciliation: dict[str, Any], ct_data: dict[str, Any], recon_path: str, recon_hash: str, ct_path: str, ct_hash: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    ct_owner: dict[tuple[str, str], str] = {}
    ct_batch: dict[str, str] = {}
    for case in ct_data["cases"]:
        ct_batch[case["sourcePath"]] = case.get("batch", "default")
        for callable_row in case.get("callables", []):
            for replacement in callable_row.get("replacementDeclarations", []):
                ct_owner[(case["sourcePath"], replacement["exactDeclaration"])] = replacement.get("proposedOwner") or "::"
    for row_index, item in enumerate(reconciliation["planRows"]):
        if item["primaryAudit"] not in {"BTARRAY-MD", "CTARRAY"}:
            continue
        current = current_record(item["canonicalIdentity"], item["line"], item["owner"], item["kind"], item.get("annotations", []), item["declaration"], None)
        for proposal_index, raw in enumerate(item["proposals"]):
            blockers = raw_blockers(raw.get("blockers", []))
            parameters = normalize_parameters(raw.get("typedInputs", []))
            owner = item["owner"] if item["primaryAudit"] == "BTARRAY-MD" else ct_owner.get((item["sourcePath"], raw["exactProposedDeclaration"]), item["owner"])
            proposal = {
                "subcaseId": slug(raw["subcaseId"]),
                "owner": owner,
                "semanticName": raw["semanticName"],
                "disposition": proposal_disposition("required-name" if raw.get("requiredName") else "hard-rename", raw.get("requiredNameReason"), len(item["proposals"]) > 1),
                "requiredNameReason": raw.get("requiredNameReason"),
                "declaration": raw["exactProposedDeclaration"],
                "parameters": parameters,
                "returnType": str(raw.get("rawResult", {}).get("type") or "void"),
                "writebacks": list(raw.get("writebacks", [])),
                "bodyPlan": [f"Implement only `{raw['semanticName']}` for role {raw.get('role', 'callable')} and expose the declared raw channels."],
                "prohibitedCalls": ["Do not collapse several expected comparisons into one bool result."],
            }
            fixture = fixture_record(raw.get("fixture"), raw.get("fixture", {}).get("cleanup") if isinstance(raw.get("fixture"), dict) else None, bool(raw.get("diagnostics")), False, owner)
            vectors = normalize_vectors(raw.get("vectors", []), item["caseId"], proposal["subcaseId"], fixture["identity"])
            runner_blocked = bool(blockers) or "candidate" in str(raw.get("status", "")) or "blocking" in str(raw.get("status", ""))
            rows.append(base_row(item["sourcePath"], item["sourceSha256"], item["caseId"], current, proposal, None, raw["immediateEnglishComment"], vectors, fixture, coverage_record(recon_path if item["primaryAudit"] == "BTARRAY-MD" else ct_path, [], high_risk=[]), blockers, verification_record(item["sourcePath"], None, "Runtime remains pending the typed TestSource runner/compile probe recorded by the TArray audit."), recon_path if item["primaryAudit"] == "BTARRAY-MD" else ct_path, recon_hash if item["primaryAudit"] == "BTARRAY-MD" else ct_hash, f"/planRows/{row_index}/proposals/{proposal_index}", "B01-bindings-tarray" if item["primaryAudit"] == "BTARRAY-MD" else ct_batch.get(item["sourcePath"], "default"), runner_blocked))
    for case_index, case in enumerate(ct_data["cases"]):
        if case.get("callables"):
            continue
        contract = case["sourceContract"]
        blockers = []
        if contract.get("diagnostic", {}).get("text") in {None, ""}:
            blockers = raw_blockers([{"code": "exact-diagnostic-evidence-missing", "field": "sourceAssertion.diagnostic", "reason": "The C++ oracle does not preserve exact diagnostic text.", "evidenceNeeded": "Capture the authoritative diagnostic before implementation."}])
        fixture = fixture_record({"kind": "compiler", "identity": "isolated TArray compile-diagnostic module"}, "Runner discards failed module and diagnostics.", True, False, "runner")
        assertion = {"kind": "compile-diagnostic", "exactSourceFacts": [contract.get("invalidDeclarationSite") or case.get("sourceShapeCurrentInventory")], "diagnosticOrState": contract.get("diagnostic") or {"status": "blocked"}, "cleanup": fixture["cleanupActions"][0]}
        vectors = normalize_vectors([{"vectorId": f"{case['caseId']}/compile-diagnostic", "expectedCompileDiagnostic": assertion["diagnosticOrState"]}], case["caseId"], "source-only", fixture["identity"])
        rows.append(base_row(case["sourcePath"], case["sourceSha256"], case["caseId"], None, None, assertion, contract["immediateEnglishComment"], vectors, fixture, coverage_record(ct_path, [case.get("cppEvidence", "")]), blockers, verification_record(case["sourcePath"], None, "Compile-diagnostic-only; no runtime claim."), ct_path, ct_hash, f"/cases/{case_index}/sourceContract", case.get("batch", "default"), True))
    return rows


def inject_duplicate_proposal_blockers(rows: list[dict[str, Any]]) -> None:
    groups: dict[tuple[str, str, str], list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        proposal = row["proposal"]
        if proposal and proposal["declaration"]:
            groups[(row["sourcePath"], proposal["owner"], proposal["declaration"])].append(row)
    for identity, group in groups.items():
        if len(group) < 2:
            continue
        task_names = [f"{row['caseId']}/{row['proposal']['subcaseId']}" for row in group]
        for row in group:
            if not any(blocker["code"] == "signature-unresolved" for blocker in row["blockers"]):
                row["blockers"].append(
                    {
                        "rawCode": "duplicate-proposed-declaration-resolution-required",
                        "code": "signature-unresolved",
                        "field": "proposal.declaration",
                        "reason": f"The proposed owner-qualified declaration collides with other planned rows in the same source: {task_names}.",
                        "evidenceNeeded": "Merge only after proving identical coverage, or choose a surface-specific semantic name/signature; do not append an ordinal suffix.",
                    }
                )
            row["status"] = status_record(row["blockers"], row["status"]["runtime"] == "runner-blocked")


def assign_ids(rows: list[dict[str, Any]]) -> None:
    batch_maps: dict[str, dict[str, int]] = {}
    for domain in DOMAIN_FILES:
        names = sorted({row["_batchRaw"] for row in rows if domain_for(row["sourcePath"]) == domain})
        batch_maps[domain] = {name: index for index, name in enumerate(names, start=1)}
    file_maps: dict[tuple[str, int], dict[str, int]] = {}
    for domain in DOMAIN_FILES:
        for batch_number in batch_maps[domain].values():
            sources = sorted({row["sourcePath"] for row in rows if domain_for(row["sourcePath"]) == domain and batch_maps[domain][row["_batchRaw"]] == batch_number})
            file_maps[(domain, batch_number)] = {source: index for index, source in enumerate(sources, start=1)}
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        grouped[row["sourcePath"]].append(row)
    for source_path, source_rows in grouped.items():
        domain = domain_for(source_path)
        wave_number = DOMAIN_ORDER[domain]
        batch_number = batch_maps[domain][source_rows[0]["_batchRaw"]]
        file_number = file_maps[(domain, batch_number)][source_path]
        file_id = f"W{wave_number:02d}.B{batch_number:02d}.F{file_number:04d}"
        source_rows.sort(key=lambda row: ((row["current"] or {}).get("line", 0), (row["current"] or {}).get("identity", ""), (row["proposal"] or {}).get("subcaseId", "")))
        callable_index = 0
        for row in source_rows:
            row["wave"] = f"W{wave_number:02d}"
            row["batch"] = f"B{batch_number:02d}"
            row["fileTaskId"] = file_id
            if row["sourceOnly"]:
                row["taskId"] = f"{file_id}.S000"
            else:
                callable_index += 1
                row["taskId"] = f"{file_id}.C{callable_index:04d}"
            row["planRowId"] = f"PR-{hashlib.sha256((source_path + '|' + row['taskId'] + '|' + (row['proposal'] or {}).get('subcaseId','source-only')).encode('utf-8')).hexdigest()[:16].upper()}"
            for blocker_index, blocker in enumerate(row["blockers"], start=1):
                blocker["resolutionTaskId"] = re.sub(r"\.(?:C\d{4}|S\d{3})$", f".D{blocker_index:03d}", row["taskId"])
                blocker.pop("rawCode", None)
            row.pop("_batchRaw", None)
            row["provenance"]["normalizedRowSha256"] = "0" * 64
            row_hash = sha256_bytes(canonical_bytes(row))
            row["provenance"]["normalizedRowSha256"] = row_hash


def validate_rows(rows: list[dict[str, Any]], schema: dict[str, Any], reconciliation: dict[str, Any]) -> dict[str, Any]:
    validator = Draft202012Validator(schema)
    diagnostics: list[str] = []
    for row in rows:
        errors = sorted(validator.iter_errors(row), key=lambda error: list(error.path))
        if errors:
            first = errors[0]
            diagnostics.append(f"{row['sourcePath']} {row['taskId']} schema {list(first.path)}: {first.message}")
        proposal = row["proposal"]
        if proposal and proposal["declaration"]:
            text = f"{proposal['semanticName']} {proposal['declaration']}"
            if LEGACY_PATTERN.search(text):
                diagnostics.append(f"legacy proposed name: {row['taskId']} {text}")
            if PLACEHOLDER_PATTERN.search(text):
                diagnostics.append(f"placeholder proposed name/declaration: {row['taskId']} {text}")
            if re.search(r"\b(?:Expected|bExpect)[A-Za-z0-9_]*\b", proposal["declaration"]):
                diagnostics.append(f"Expected parameter: {row['taskId']} {proposal['declaration']}")
        if not row["vectors"] and not (proposal and proposal["disposition"] == "retire-with-replacement") and not any(blocker["code"] == "vector-unresolved" for blocker in row["blockers"]):
            diagnostics.append(f"empty vectors without vector blocker: {row['taskId']}")
    task_ids = [row["taskId"] for row in rows]
    plan_ids = [row["planRowId"] for row in rows]
    if len(task_ids) != len(set(task_ids)):
        diagnostics.append("duplicate task IDs")
    if len(plan_ids) != len(set(plan_ids)):
        diagnostics.append("duplicate plan row IDs")
    sources = {row["sourcePath"] for row in rows}
    expected_sources = {item["sourcePath"] for item in reconciliation["sources"]}
    if sources != expected_sources:
        diagnostics.append(f"source set drift missing={len(expected_sources-sources)} extra={len(sources-expected_sources)}")
    current_identities = {row["current"]["identity"] for row in rows if row["current"]}
    if len(current_identities) != reconciliation["summary"]["currentCallables"]:
        diagnostics.append(f"current identity coverage drift expected={reconciliation['summary']['currentCallables']} actual={len(current_identities)}")
    source_only = [row for row in rows if row["sourceOnly"]]
    if len(source_only) != 249:
        diagnostics.append(f"source-only drift expected=249 actual={len(source_only)}")
    proposed: dict[tuple[str, str, str], list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        if row["proposal"] and row["proposal"]["declaration"]:
            proposed[(row["sourcePath"], row["proposal"]["owner"], row["proposal"]["declaration"])].append(row)
    duplicate_groups = [group for group in proposed.values() if len(group) > 1]
    for group in duplicate_groups:
        if not all(any(blocker["code"] == "signature-unresolved" for blocker in row["blockers"]) for row in group):
            diagnostics.append(f"unblocked duplicate proposal: {[row['taskId'] for row in group]}")
    return {
        "passed": not diagnostics,
        "diagnostics": diagnostics,
        "sourceFiles": len(sources),
        "currentCallableIdentities": len(current_identities),
        "normalizedRows": len(rows),
        "proposedCallablesOrRetirements": len([row for row in rows if not row["sourceOnly"]]),
        "sourceAssertions": len(source_only),
        "duplicateProposedIdentityGroups": len(duplicate_groups),
    }


def build(change: Path) -> tuple[list[dict[str, Any]], dict[str, Any], dict[str, bytes]]:
    contracts = change / "attachments" / "contracts"
    normalized = contracts / "normalized"
    paths = {
        "reconciliation": contracts / "audit-coverage-reconciliation.json",
        "bco": contracts / "bco-plan-resolution.json",
        "ldf": contracts / "ldf-plan-resolution.json",
        "wghfd": contracts / "wghfd-plan-resolution.json",
        "ct": contracts / "containers-tarray-contract-audit.json",
        "schema": normalized / "plan-row-schema.json",
    }
    hashes = {name: sha256_file(path) for name, path in paths.items()}
    reconciliation = load_json(paths["reconciliation"])
    rows = []
    rows.extend(adapt_bco(load_json(paths["bco"]), "attachments/contracts/bco-plan-resolution.json", hashes["bco"]))
    rows.extend(adapt_ldf(load_json(paths["ldf"]), "attachments/contracts/ldf-plan-resolution.json", hashes["ldf"]))
    rows.extend(adapt_wghfd(load_json(paths["wghfd"]), "attachments/contracts/wghfd-plan-resolution.json", hashes["wghfd"]))
    rows.extend(adapt_tarrays(reconciliation, load_json(paths["ct"]), "attachments/contracts/audit-coverage-reconciliation.json", hashes["reconciliation"], "attachments/contracts/containers-tarray-contract-audit.json", hashes["ct"]))
    complete_signature_channels(rows)
    inject_quality_blockers(rows)
    inject_duplicate_proposal_blockers(rows)
    for row in rows:
        row["status"] = status_record(row["blockers"], row["status"]["runtime"] == "runner-blocked" or bool(row["blockers"]))
    assign_ids(rows)
    schema = load_json(paths["schema"])
    validation = validate_rows(rows, schema, reconciliation)
    if not validation["passed"]:
        raise ValueError("normalized plan validation failed:\n" + "\n".join(validation["diagnostics"][:100]))
    by_domain: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        by_domain[domain_for(row["sourcePath"])].append(row)
    domain_bytes: dict[str, bytes] = {}
    domain_entries: list[dict[str, Any]] = []
    for domain in sorted(DOMAIN_FILES, key=lambda value: DOMAIN_ORDER[value]):
        ordered = sorted(by_domain[domain], key=lambda row: row["taskId"])
        data = b"".join(canonical_bytes(row) for row in ordered)
        filename = DOMAIN_FILES[domain]
        domain_bytes[filename] = data
        domain_entries.append({"domain": domain, "path": filename, "rows": len(ordered), "sha256": sha256_bytes(data)})
    blocker_counts = Counter(blocker["code"] for row in rows for blocker in row["blockers"])
    status_counts = Counter(row["status"]["design"] for row in rows)
    counts = {
        "sourceFiles": 3041,
        "currentCallables": 11987,
        "sourceOnlyFiles": len([row for row in rows if row["sourceOnly"]]),
        "proposedCallables": len([row for row in rows if not row["sourceOnly"] and row["proposal"]["declaration"] is not None]),
        "retirements": len([row for row in rows if not row["sourceOnly"] and row["proposal"]["declaration"] is None]),
        "sourceAssertions": len([row for row in rows if row["sourceOnly"]]),
        "normalizedRows": len(rows),
        "blockedRows": status_counts["blocked"],
        "reviewReadyRows": status_counts["review-ready"],
        "runnerBlockedRows": len([row for row in rows if row["status"]["runtime"] == "runner-blocked"]),
    }
    counts["blockerTasks"] = sum(blocker_counts.values())
    counts["basePlanTasks"] = 20
    counts["totalChecklistTasks"] = (
        counts["basePlanTasks"]
        + counts["proposedCallables"]
        + counts["retirements"]
        + counts["sourceAssertions"]
        + counts["sourceFiles"]
        + counts["blockerTasks"]
    )
    semantic_payload = {
        "planRevision": PLAN_REVISION,
        "inputHashes": hashes,
        "counts": counts,
        "blockerCounts": dict(sorted(blocker_counts.items())),
        "domainFiles": domain_entries,
        "validation": validation,
    }
    manifest_content_hash = sha256_bytes(canonical_bytes(semantic_payload))
    manifest = {
        "schemaVersion": "testsource-contract-v2-normalized-manifest-v1",
        "planRevision": PLAN_REVISION,
        "generatedOn": GENERATED_ON,
        "inputHashes": hashes,
        "counts": counts,
        "blockerCounts": dict(sorted(blocker_counts.items())),
        "domainFiles": domain_entries,
        "validation": validation,
        "hashes": {
            "semanticPlanSha256": sha256_bytes(b"".join(domain_bytes[name] for name in [DOMAIN_FILES[d] for d in sorted(DOMAIN_FILES, key=lambda value: DOMAIN_ORDER[value])])),
            "manifestContentSha256": manifest_content_hash,
            "tasksSha256": "",
        },
    }
    tasks_text = renderer._render_rows(manifest, rows)
    manifest["hashes"]["tasksSha256"] = sha256_bytes(tasks_text.encode("utf-8"))
    tasks_text = renderer._render_rows(manifest, rows)
    if sha256_bytes(tasks_text.encode("utf-8")) != manifest["hashes"]["tasksSha256"]:
        raise ValueError("tasks projection changed after non-rendered tasks hash insertion")
    outputs = dict(domain_bytes)
    outputs["manifest.json"] = canonical_bytes(manifest)
    outputs["tasks.md"] = tasks_text.encode("utf-8")
    return rows, manifest, outputs


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--change", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    change = args.change.resolve()
    normalized = change / "attachments" / "contracts" / "normalized"
    rows, manifest, outputs = build(change)
    targets = {name: (change / "tasks.md" if name == "tasks.md" else normalized / name) for name in outputs}
    if args.check:
        drift = [str(path) for name, path in targets.items() if not path.exists() or path.read_bytes() != outputs[name]]
        if drift:
            raise ValueError("generated plan drift:\n" + "\n".join(drift))
        print(f"PASS sources={manifest['counts']['sourceFiles']} current={manifest['counts']['currentCallables']} rows={len(rows)} proposed={manifest['counts']['proposedCallables']} sourceOnly={manifest['counts']['sourceOnlyFiles']} tasksSha256={manifest['hashes']['tasksSha256']}")
        return 0
    normalized.mkdir(parents=True, exist_ok=True)
    for name, data in outputs.items():
        targets[name].write_bytes(data)
    print(f"WROTE sources={manifest['counts']['sourceFiles']} current={manifest['counts']['currentCallables']} rows={len(rows)} proposed={manifest['counts']['proposedCallables']} sourceOnly={manifest['counts']['sourceOnlyFiles']} tasksSha256={manifest['hashes']['tasksSha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
