#!/usr/bin/env python3
"""Audit semantic quality that schema validation alone cannot prove.

This OpenSpec-local tool reads normalized planning rows only. It never reads or
writes TestSource and deliberately treats a finding as a review blocker rather
than inventing a replacement signature or oracle.
"""

from __future__ import annotations

import argparse
from collections import Counter
import json
from pathlib import Path
import re
from typing import Any, Iterable


GENERIC_COMMENT = re.compile(
    r"(?:"
    r"\bis the (?:function|method|event|delegate|import|mixin|operator|constructor|destructor|lambda) surface owned by\b"
    r"|\bPurpose\s*:\s*[^.;]+\bcovers\b"
    r"|\bRole\s*:\s*semantic operation/reader\b"
    r"|\bBoundary and expected values live in typed vectors\b"
    r")",
    re.IGNORECASE,
)
DERIVED_CONDITION_NAME = re.compile(
    r"^(?:(?:First|Second|Third|Fourth|Fifth|Sixth|Seventh|Eighth|Ninth|Tenth))?ObservedCondition(?:\d+)?$",
    re.IGNORECASE,
)
EXTERNAL_ORACLE_EVIDENCE = re.compile(
    r"(?:Preprocessor|Compiler[^/\\]*Tests|Metadata)", re.IGNORECASE
)
ORDINAL_SEMANTIC_NAME = re.compile(
    r"(?:ForSubcase\d+$|^(?:Run|Compile).+\d+$|^(?:Handler|Listener|ServerAction|ClientNotify|MulticastEvent|ServerValidated)\d+$|^LambdaAtLine\d+$)",
    re.IGNORECASE,
)
PSEUDO_TYPED_LITERAL = re.compile(r"^(?:nominal|default)\s*\([^)]*\)$", re.IGNORECASE)
HIGH_RISK_ENGINE_DISPATCH = re.compile(
    r"(?:timers?\b|delegates?\b|NewObject|DefaultComponent|Blueprint\s+CDO|ProcessEvent)",
    re.IGNORECASE,
)
GENERIC_ENGINE_DRIVER = re.compile(
    r"^(?:typed contract runner|runner/engine/native/reflection according to vector phase)$",
    re.IGNORECASE,
)
GENERIC_VECTOR_PHASES = {"invoke", "call", "runner-oracle", "dispatch runner phase"}


def finding(
    code: str,
    field: str,
    reason: str,
    evidence_needed: str,
    severity: str = "error",
) -> dict[str, str]:
    return {
        "code": code,
        "field": field,
        "reason": reason,
        "evidenceNeeded": evidence_needed,
        "severity": severity,
    }


def _input_parameter_names(proposal: dict[str, Any]) -> set[str]:
    return {
        str(parameter.get("name") or "")
        for parameter in proposal.get("parameters", [])
        if parameter.get("direction") in {"value", "in", "inout"}
        and str(parameter.get("name") or "")
    }


def _json_contains_non_null_key(value: Any, keys: set[str]) -> bool:
    if isinstance(value, dict):
        for key, nested in value.items():
            if key in keys and nested is not None and nested != "" and nested != [] and nested != {}:
                return True
            if _json_contains_non_null_key(nested, keys):
                return True
    elif isinstance(value, list):
        return any(_json_contains_non_null_key(item, keys) for item in value)
    return False


def _json_contains_pseudo_literal(value: Any) -> bool:
    if isinstance(value, dict):
        return any(_json_contains_pseudo_literal(nested) for nested in value.values())
    if isinstance(value, list):
        return any(_json_contains_pseudo_literal(item) for item in value)
    return isinstance(value, str) and bool(PSEUDO_TYPED_LITERAL.match(value.strip()))


def _json_contains_null_oracle(value: Any) -> bool:
    oracle_keys = {
        "expectedReturn",
        "expectedRawReturn",
        "rawReturn",
        "expectedCompileDiagnostic",
        "expectedDiagnostic",
        "expectedException",
    }
    if isinstance(value, dict):
        for key, nested in value.items():
            if key in oracle_keys and nested is None:
                return True
            if _json_contains_null_oracle(nested):
                return True
    elif isinstance(value, list):
        return any(_json_contains_null_oracle(item) for item in value)
    return False


def _split_parameters(value: str) -> list[str]:
    result: list[str] = []
    start = 0
    depths = {"(": 0, "[": 0, "{": 0, "<": 0}
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
        elif character in depths:
            depths[character] += 1
        elif character in closing:
            opener = closing[character]
            depths[opener] = max(0, depths[opener] - 1)
        elif character == "," and not any(depths.values()):
            result.append(value[start:index].strip())
            start = index + 1
    result.append(value[start:].strip())
    return [item for item in result if item]


def _parse_declaration_signature(declaration: str) -> dict[str, Any] | None:
    text = declaration.replace("\r", "\n")
    text = re.sub(
        r"(?m)^\s*(?:UFUNCTION|UPROPERTY|UCLASS|USTRUCT|UENUM|UMETA)\s*(?:\([^\n]*\))?\s*$",
        "",
        text,
    )
    text = " ".join(part.strip() for part in text.splitlines() if part.strip())
    text = re.sub(
        r"^\s*(?:UFUNCTION|UPROPERTY|UCLASS|USTRUCT|UENUM|UMETA)\s*(?:\([^)]*\))?\s*",
        "",
        text,
    )
    open_index = text.find("(")
    if open_index < 0:
        return None
    name_match = re.search(r"([A-Za-z_][A-Za-z0-9_:~]*)\s*$", text[:open_index])
    if not name_match:
        return None
    name = name_match.group(1)
    prefix = text[: name_match.start()].strip()
    prefix = re.sub(
        r"^(?:(?:event|mixin|import|shared|private|protected|final|override)\s+)+",
        "",
        prefix,
        flags=re.IGNORECASE,
    )
    depth = 0
    close_index = -1
    for index in range(open_index, len(text)):
        if text[index] == "(":
            depth += 1
        elif text[index] == ")":
            depth -= 1
            if depth == 0:
                close_index = index
                break
    if close_index < 0:
        return None
    parameters: list[dict[str, str]] = []
    parameter_text = text[open_index + 1 : close_index].strip()
    if parameter_text and parameter_text != "void":
        for raw in _split_parameters(parameter_text):
            without_default = raw.split("=", 1)[0].strip()
            parameter_match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*$", without_default)
            if not parameter_match:
                return None
            parameters.append(
                {
                    "name": parameter_match.group(1),
                    "declaration": raw,
                    "type": without_default[: parameter_match.start()].strip(),
                }
            )
    return {"name": name, "returnType": prefix or None, "parameters": parameters}


def _is_failure_vector(vector: dict[str, Any]) -> bool:
    return _json_contains_non_null_key(
        vector.get("expected") or {},
        {
            "expectedDiagnostic",
            "expectedCompileDiagnostic",
            "diagnostic",
            "diagnostics",
            "expectedException",
            "exception",
        },
    )


def _expected_writeback_names(vector: dict[str, Any]) -> set[str]:
    expected = vector.get("expected") or {}
    names: set[str] = set()
    raw_expectations = expected.get("rawExpectations") or []
    if isinstance(raw_expectations, list):
        names.update(
            str(item.get("name") or "")
            for item in raw_expectations
            if isinstance(item, dict) and item.get("name")
        )
    expected_writebacks = expected.get("expectedWritebacks") or expected.get("writebacks") or {}
    if isinstance(expected_writebacks, dict):
        names.update(str(name) for name in expected_writebacks)
    elif isinstance(expected_writebacks, list):
        names.update(
            str(item.get("name") or "")
            for item in expected_writebacks
            if isinstance(item, dict) and item.get("name")
        )
    return names


def audit_row(row: dict[str, Any]) -> list[dict[str, str]]:
    findings: list[dict[str, str]] = []
    proposal = row.get("proposal")
    if not proposal or proposal.get("declaration") is None:
        return findings

    comment = str((row.get("comment") or {}).get("exactText") or "")
    if GENERIC_COMMENT.search(comment):
        findings.append(
            finding(
                "generic-purpose-comment",
                "comment.exactText",
                "The adjacent comment enumerates channels but describes the callable only as a surface owned by an owner.",
                "Replace the tautology with the concrete operation, state transition, external dispatch, or diagnostic purpose of this exact callable.",
            )
        )

    if proposal.get("disposition") == "required-name" and not str(
        proposal.get("requiredNameReason") or ""
    ).strip():
        findings.append(
            finding(
                "required-name-reason-missing",
                "proposal.requiredNameReason",
                "A fixed name is proposed without identifying the engine, reflection, delegate, import, discovery, or external-runner protocol that requires it.",
                "Cite the exact protocol and lookup/dispatch site that would fail if the declaration name changed.",
            )
        )

    for writeback in proposal.get("writebacks", []):
        name = str(writeback.get("name") or "")
        raw_expression = str(writeback.get("rawExpression") or "").strip()
        derived_expression = bool(
            re.search(r"(?:^!|==|!=|<=|>=|&&|\|\|)", raw_expression)
            or re.search(r"(?<!<)<(?!<)|(?<!>)>(?!>)", raw_expression)
        )
        if DERIVED_CONDITION_NAME.match(name) or derived_expression:
            findings.append(
                finding(
                    "derived-condition-output",
                    f"proposal.writebacks.{name}",
                    "The plan exposes a generated pass/fail condition instead of the underlying raw value, object identity, state, API bool result, or exception channel.",
                    "Redesign the exact declaration around raw channels. If the tested API itself returns bool, give that result a semantic API-derived name; otherwise return the compared operand(s) and keep expected values in vectors.",
                )
            )

    vectors = row.get("vectors", [])
    if (row.get("fixture") or {}).get("executionMode") == "DiagnosticOnly" and not any(
        _json_contains_non_null_key(
            vector,
            {"expectedDiagnostic", "expectedCompileDiagnostic", "diagnostic", "diagnostics"},
        )
        for vector in vectors
    ):
        findings.append(
            finding(
                "diagnostic-only-runtime-contract",
                "fixture.executionMode",
                "A compile-success/runtime callable is marked DiagnosticOnly even though none of its vectors expects a diagnostic.",
                "Change the fixture to the exact runtime/world/framework mode, or add the authoritative diagnostic vector if this is genuinely a negative case.",
            )
        )

    return_type = str(proposal.get("returnType") or "void")
    if return_type != "void" and not any(
        _json_contains_non_null_key(
            vector,
            {"expectedReturn", "rawReturn", "return", "returnValue", "expectedRawReturn"},
        )
        for vector in vectors
    ):
        findings.append(
            finding(
                "raw-return-oracle-missing",
                "vectors.expectedReturn",
                f"The declaration returns {return_type}, but no vector records its typed raw return relation.",
                "Record the exact returned AngelScript type/value/identity/relation for nominal and boundary vectors; unrelated state expectations do not cover the return channel.",
            )
        )

    input_names = _input_parameter_names(proposal)
    if input_names and (row.get("status") or {}).get("design") == "review-ready":
        structured = False
        for vector in row.get("vectors", []):
            arguments = vector.get("arguments") or {}
            omitted = set(vector.get("omittedArguments") or [])
            fixture_inputs = vector.get("fixtureInputs") or {}
            supplied = set(arguments) | omitted
            if isinstance(fixture_inputs, dict):
                supplied |= set(fixture_inputs.get("arguments") or {})
            if input_names <= supplied:
                structured = True
                break
        if not structured:
            findings.append(
                finding(
                    "unstructured-input-vector",
                    "vectors.arguments",
                    f"The review-ready declaration has typed inputs {sorted(input_names)}, but no vector maps every input to a typed argument, omission, or fixture-provided argument.",
                    "Record at least one exact nominal/boundary/negative invocation object with a value and AngelScript type for every input; prose evidence is not an argument vector.",
                )
            )

    writeback_names = {
        str(writeback.get("name") or "") for writeback in proposal.get("writebacks", [])
    }
    for parameter in proposal.get("parameters", []):
        if parameter.get("direction") in {"out", "inout"}:
            name = str(parameter.get("name") or "")
            if name and name not in writeback_names:
                findings.append(
                    finding(
                        "writeback-channel-missing",
                        f"proposal.parameters.{name}",
                        f"Parameter {name} is {parameter.get('direction')} in the exact declaration but has no matching post-call writeback contract.",
                        "Add the exact post-call type/value/state relation for this parameter to proposal.writebacks and every applicable vector.",
                    )
                )

    evidence = "\n".join(
        str(value) for value in (row.get("coverage") or {}).get("cppEvidence", [])
    )
    fixture = row.get("fixture") or {}
    invocation_driver = str(fixture.get("invocationDriver") or "")
    if (
        EXTERNAL_ORACLE_EVIDENCE.search(evidence)
        and not row.get("sourceOnly")
        and not re.search(
            r"(?:preprocessor|compiler|metadata|reflection|external)",
            invocation_driver,
            re.IGNORECASE,
        )
    ):
        findings.append(
            finding(
                "external-oracle-classification-required",
                "fixture.invocationDriver",
                "The cited C++ oracle tests preprocessing, compilation, or metadata, while the row is modeled as a generic runtime callable contract.",
                "Decide whether the observer is retired in favor of a source/external-driver assertion or record the exact external driver and the raw state channel that makes the callable relevant.",
            )
        )

    high_risk = "\n".join(
        str(value) for value in (row.get("coverage") or {}).get("highRiskDirectives", [])
    )
    if re.search(r"\bNewObject\b", high_risk, re.IGNORECASE):
        stale_names = {
            "bManualCompNullptr",
            "NotActorNewObjectCreated",
            "NotActorOwnerBeforeRegisterMatched",
            "NotActorWorldBeforeRegisterMatched",
            "NotActorTaggedAfterRegister",
            "NotActorActiveAfterActivate",
            "NotActorInactiveAfterDeactivate",
        }
        for vector in vectors:
            expected_text = json.dumps(vector.get("expected") or {}, ensure_ascii=False)
            if any(name in expected_text for name in stale_names):
                findings.append(
                    finding(
                        "known-lifecycle-oracle-contradiction",
                        "vectors.expected.rawExpectations",
                        "The NewObject lifecycle vector preserves the pre-BeginPlay/null/false pseudo-oracle instead of the post-engine-dispatch created component identity and state.",
                        "Use separate pre-BeginPlay and post-BeginPlay vectors. The post-dispatch reader must expose the component handle plus created/owner/world/tag/active-transition/custom-method raw state with the authoritative positive values.",
                    )
                )
                break

    if re.search(r"DirectCallback", str(proposal.get("semanticName") or ""), re.IGNORECASE) and any(
        "direct-call" in str(value).lower() for value in proposal.get("prohibitedCalls", [])
    ):
        findings.append(
            finding(
                "direct-dispatch-contract-contradiction",
                "proposal.semanticName",
                "The proposed semantic name advertises direct callback invocation while the same contract prohibits bypassing the real timer/delegate/lifecycle dispatcher.",
                "Rename/restructure the case around bind, real dispatch/advance/broadcast, raw post-dispatch state, and cleanup; retain a direct call only in an explicitly negative control case.",
            )
        )

    return findings


def _is_state_reader(row: dict[str, Any]) -> bool:
    proposal = row.get("proposal") or {}
    if proposal.get("declaration") is None:
        return False
    name = str(proposal.get("semanticName") or "")
    publishes_state = str(proposal.get("returnType") or "void") != "void" or bool(
        proposal.get("writebacks")
    )
    return publishes_state and bool(
        re.match(r"^(?:Read|Get|Is|Has|Count|Capture|Snapshot|Query)", name)
    )


def audit_file_rows(
    rows: list[dict[str, Any]],
) -> list[tuple[dict[str, Any], dict[str, str]]]:
    """Audit relationships that cannot be proven by one callable row in isolation."""
    if not rows:
        return []
    results: list[tuple[dict[str, Any], dict[str, str]]] = []
    anchor = rows[0]
    source_path = str(anchor.get("sourcePath") or "")
    proposals = [row.get("proposal") or {} for row in rows]
    names = {str(proposal.get("semanticName") or "") for proposal in proposals}
    has_reader = any(_is_state_reader(row) for row in rows)

    has_actor_event_callback = any(
        re.match(r"^OnActor(?:Hit|BeginOverlap|EndOverlap)", name) for name in names
    )
    if has_actor_event_callback and not has_reader:
        results.append(
            (
                anchor,
                finding(
                    "post-dispatch-reader-missing",
                    "filePlan.readerDeclaration",
                    "The file binds engine-dispatched Actor collision/overlap callbacks but has no callable that publishes bound state and post-broadcast counts.",
                    "Add an exact semantic reader, for example a void reader with Actor input and out channels for bDelegatesBound, HitCount, BeginOverlapCount, and EndOverlapCount; vectors must cover pre-BeginPlay zero state and post-broadcast counts.",
                ),
            )
        )

    blueprint_matrix = any(
        "Blueprint child class/CDO/spawned instance matrix"
        in str((row.get("fixture") or {}).get("instanceKind") or "")
        for row in rows
    )
    if blueprint_matrix and not has_reader:
        results.append(
            (
                anchor,
                finding(
                    "blueprint-state-reader-missing",
                    "filePlan.readerDeclaration",
                    "The Blueprint/CDO/spawned-instance story mutates or dispatches state but has no typed reader for the distinct fixture identities.",
                    "Add the exact reader declaration and vectors for script CDO, Blueprint child CDO, spawned script instance, and spawned Blueprint instance as applicable; do not reuse one identity as another.",
                ),
            )
        )

    for row in rows:
        proposal = row.get("proposal") or {}
        if (
            proposal.get("disposition") == "retire-with-replacement"
            and not row.get("retirementTransferTaskIds")
        ):
            results.append(
                (
                    row,
                    finding(
                        "retirement-transfer-link-missing",
                        "retirementTransferTaskIds",
                        "The current callable is retired with replacement, but the normalized row does not name the exact replacement task(s) that inherit every coverage claim.",
                        "Record one or more stable callable/source-assertion task IDs and verify that their accepted vectors cover every transferred observation before deletion.",
                    ),
                )
            )

    process_event_rows = [
        row
        for row in rows
        if re.search(
            r"ProcessEvent",
            "\n".join(
                str(value)
                for value in (row.get("coverage") or {}).get("highRiskDirectives", [])
            ),
            re.IGNORECASE,
        )
    ]
    for row in process_event_rows:
        driver = str((row.get("fixture") or {}).get("invocationDriver") or "")
        if not re.search(r"\bProcessEvent\b", driver, re.IGNORECASE):
            results.append(
                (
                    row,
                    finding(
                        "process-event-driver-missing",
                        "fixture.invocationDriver",
                        "The case claims native/reflected ProcessEvent coverage but records only a generic typed or reflection driver.",
                        "Name the exact native UFunction lookup and UObject::ProcessEvent invocation phase, then freeze the raw parent/child/payload state observed after that dispatch; direct AngelScript invocation is a separate control case.",
                    ),
                )
            )

    return results


def iter_rows(normalized_root: Path) -> Iterable[dict[str, Any]]:
    for path in sorted(normalized_root.glob("*.jsonl")):
        with path.open("r", encoding="utf-8") as handle:
            for line in handle:
                if line.strip():
                    yield json.loads(line)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--normalized-root", type=Path, required=True)
    parser.add_argument("--max-findings", type=int, default=20)
    args = parser.parse_args()

    records: list[dict[str, Any]] = []
    counts: Counter[str] = Counter()
    all_rows = list(iter_rows(args.normalized_root))
    for row in all_rows:
        for item in audit_row(row):
            counts[item["code"]] += 1
            if len(records) < args.max_findings:
                records.append(
                    {
                        "taskId": row["taskId"],
                        "sourcePath": row["sourcePath"],
                        **item,
                    }
                )
    grouped: dict[str, list[dict[str, Any]]] = {}
    for row in all_rows:
        grouped.setdefault(row["sourcePath"], []).append(row)
    for source_rows in grouped.values():
        for anchor, item in audit_file_rows(source_rows):
            counts[item["code"]] += 1
            if len(records) < args.max_findings:
                records.append(
                    {
                        "taskId": anchor["taskId"],
                        "sourcePath": anchor["sourcePath"],
                        **item,
                    }
                )
    result = {
        "rows": len(all_rows),
        "findingCounts": dict(sorted(counts.items())),
        "findings": records,
        "passed": not counts,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
