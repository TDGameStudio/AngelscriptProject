#!/usr/bin/env python3
"""Validate and summarize schema-v2 StaticJIT Provider/Route diagnostics."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any


SCHEMA_VERSION = 2
HASH_RE = re.compile(r"^[0-9a-fA-F]{64}$")
ROUTES = {"Native", "Vm"}
MATCH_RESULTS = {
    "Exact",
    "MissingArtifactIdentity",
    "MissingProviderEntry",
    "ContentMismatch",
    "DebugMismatch",
    "ProfileMismatch",
    "EnvironmentMismatch",
    "EntryAbiMismatch",
    "MissingReference",
    "AmbiguousReference",
    "WrongReferenceKind",
    "ReferenceAbiMismatch",
    "StaleProviderGeneration",
    "DuplicateProviderEntry",
    "AmbiguousExactProvider",
    "ArtifactSetMismatch",
    "InvalidProvider",
    "MissingEntryPoint",
}


class ValidationError(ValueError):
    pass


def fail(path: str, message: str) -> None:
    raise ValidationError(f"{path}: {message}")


def expect_type(value: Any, expected: type, path: str) -> Any:
    if expected is int and isinstance(value, bool):
        fail(path, "expected integer, got boolean")
    if not isinstance(value, expected):
        fail(path, f"expected {expected.__name__}, got {type(value).__name__}")
    return value


def expect_field(obj: dict[str, Any], name: str, expected: type, path: str) -> Any:
    if name not in obj:
        fail(path, f"missing required field '{name}'")
    return expect_type(obj[name], expected, f"{path}.{name}")


def expect_hash(value: Any, path: str, *, allow_zero: bool = False) -> str:
    text = expect_type(value, str, path)
    if HASH_RE.fullmatch(text) is None:
        fail(path, "expected exactly 64 hexadecimal characters")
    if not allow_zero and int(text, 16) == 0:
        fail(path, "zero hash is not a valid stable identity")
    return text.lower()


def expect_non_negative(value: Any, path: str) -> int:
    number = expect_type(value, int, path)
    if number < 0:
        fail(path, "expected a non-negative integer")
    return number


def expect_uint_string(value: Any, path: str) -> int:
    text = expect_type(value, str, path)
    if not text.isdigit():
        fail(path, "expected an unsigned decimal string")
    return int(text)


def validate_reference(reference: Any, path: str) -> None:
    obj = expect_type(reference, dict, path)
    expect_non_negative(expect_field(obj, "slotIndex", int, path), f"{path}.slotIndex")
    expect_non_negative(expect_field(obj, "flags", int, path), f"{path}.flags")
    expect_field(obj, "kind", str, path)
    expect_hash(expect_field(obj, "stableKey", str, path), f"{path}.stableKey")
    expect_hash(
        expect_field(obj, "expectedAbi", str, path),
        f"{path}.expectedAbi",
        allow_zero=True,
    )
    expect_field(obj, "resolved", bool, path)


def validate_provider(provider: Any, path: str) -> tuple[tuple[str, str], set[str], int]:
    obj = expect_type(provider, dict, path)
    provider_id = expect_hash(expect_field(obj, "providerId", str, path), f"{path}.providerId")
    generation = expect_hash(
        expect_field(obj, "providerGeneration", str, path),
        f"{path}.providerGeneration",
    )
    for field in ("artifactSetDigest", "artifactProfile", "nativeEnvironment"):
        expect_hash(expect_field(obj, field, str, path), f"{path}.{field}")
    expect_field(obj, "providerName", str, path)
    expect_field(obj, "ownerModuleName", str, path)
    for field in ("compatibleEntryCount", "rejectedEntryCount", "conflictingEntryCount"):
        expect_non_negative(expect_field(obj, field, int, path), f"{path}.{field}")

    modules = expect_field(obj, "modules", list, path)
    module_keys: set[str] = set()
    declared_function_count = 0
    previous_module_key = ""
    for index, module in enumerate(modules):
        module_path = f"{path}.modules[{index}]"
        module_obj = expect_type(module, dict, module_path)
        module_key = expect_hash(
            expect_field(module_obj, "moduleKey", str, module_path),
            f"{module_path}.moduleKey",
        )
        if module_key in module_keys:
            fail(module_path, f"duplicate moduleKey {module_key}")
        if previous_module_key and module_key < previous_module_key:
            fail(module_path, "modules are not sorted by stable module key")
        previous_module_key = module_key
        module_keys.add(module_key)
        source = expect_field(module_obj, "generatedModuleSource", str, module_path)
        if source and (
            not source.endswith(".jit.cpp")
            or source.startswith("Modules/")
            or ".." in Path(source).parts
        ):
            fail(
                f"{module_path}.generatedModuleSource",
                "expected a safe readable .jit.cpp path without the legacy Modules/ root",
            )
        expect_hash(
            expect_field(module_obj, "moduleArtifactDigest", str, module_path),
            f"{module_path}.moduleArtifactDigest",
        )
        declared_function_count += expect_non_negative(
            expect_field(module_obj, "functionCount", int, module_path),
            f"{module_path}.functionCount",
        )

    entries = expect_field(obj, "entries", list, path)
    entry_identities: set[tuple[str, str]] = set()
    entries_per_module: Counter[str] = Counter()
    previous_entry_key: tuple[str, str, int] | None = None
    for index, entry in enumerate(entries):
        entry_path = f"{path}.entries[{index}]"
        entry_obj = expect_type(entry, dict, entry_path)
        entry_index = expect_non_negative(
            expect_field(entry_obj, "providerEntryIndex", int, entry_path),
            f"{entry_path}.providerEntryIndex",
        )
        module_key = expect_hash(
            expect_field(entry_obj, "moduleKey", str, entry_path),
            f"{entry_path}.moduleKey",
        )
        function_key = expect_hash(
            expect_field(entry_obj, "functionKey", str, entry_path),
            f"{entry_path}.functionKey",
        )
        if module_key not in module_keys:
            fail(entry_path, f"entry moduleKey {module_key} is absent from provider.modules")
        identity = (module_key, function_key)
        if identity in entry_identities:
            fail(entry_path, "duplicate module/function identity in copied provider catalog")
        entry_identities.add(identity)
        order_key = (module_key, function_key, entry_index)
        if previous_entry_key is not None and order_key < previous_entry_key:
            fail(entry_path, "entries are not sorted by module/function stable identity")
        previous_entry_key = order_key
        entries_per_module[module_key] += 1
        expect_non_negative(expect_field(entry_obj, "flags", int, entry_path), f"{entry_path}.flags")
        for field in ("executionHash", "debugHash", "artifactProfile", "entryAbiHash", "nativeEnvironment"):
            expect_hash(expect_field(entry_obj, field, str, entry_path), f"{entry_path}.{field}")
        for field in ("hasVmEntry", "hasRawEntry", "hasParmsEntry"):
            expect_field(entry_obj, field, bool, entry_path)
        expect_field(entry_obj, "generatedModuleSource", str, entry_path)
        references = expect_field(entry_obj, "references", list, entry_path)
        previous_slot = -1
        for reference_index, reference in enumerate(references):
            reference_path = f"{entry_path}.references[{reference_index}]"
            validate_reference(reference, reference_path)
            slot = reference["slotIndex"]
            if slot <= previous_slot:
                fail(reference_path, "reference slots must be strictly increasing")
            previous_slot = slot

    if declared_function_count != len(entries):
        fail(path, f"module functionCount total {declared_function_count} does not equal entry count {len(entries)}")
    for module_index, module in enumerate(modules):
        module_key = module["moduleKey"].lower()
        if module["functionCount"] != entries_per_module[module_key]:
            fail(
                f"{path}.modules[{module_index}].functionCount",
                f"expected {entries_per_module[module_key]} entries for module",
            )
    return (provider_id, generation), module_keys, len(entries)


def validate_route(route: Any, path: str, provider_keys: set[tuple[str, str]]) -> str:
    obj = expect_type(route, dict, path)
    for field in ("moduleKey", "functionKey", "executionHash", "debugHash", "artifactProfile"):
        expect_hash(expect_field(obj, field, str, path), f"{path}.{field}", allow_zero=field == "debugHash")
    expect_field(obj, "canonicalDeclaration", str, path)
    expect_field(obj, "numericFunctionId", int, path)
    selected_route = expect_field(obj, "selectedRoute", str, path)
    if selected_route not in ROUTES:
        fail(f"{path}.selectedRoute", f"unsupported route '{selected_route}'")
    match_result = expect_field(obj, "matchResult", str, path)
    if match_result not in MATCH_RESULTS:
        fail(f"{path}.matchResult", f"unsupported match result '{match_result}'")
    for field in (
        "verifiedArtifactIdentity",
        "hasVmEntry",
        "hasRawEntry",
        "hasParmsEntry",
        "immutableCookedDirectDispatch",
    ):
        expect_field(obj, field, bool, path)
    provider_id = expect_hash(
        expect_field(obj, "providerId", str, path),
        f"{path}.providerId",
        allow_zero=True,
    )
    generation = expect_hash(
        expect_field(obj, "providerGeneration", str, path),
        f"{path}.providerGeneration",
        allow_zero=True,
    )
    provider_entry_index = expect_field(obj, "providerEntryIndex", int, path)
    for field in ("referenceSlotCount", "resolvedReferenceSlotCount"):
        expect_non_negative(expect_field(obj, field, int, path), f"{path}.{field}")
    if obj["resolvedReferenceSlotCount"] > obj["referenceSlotCount"]:
        fail(path, "resolvedReferenceSlotCount exceeds referenceSlotCount")
    for field in ("vmExecutionCount", "rawExecutionCount", "parmsExecutionCount"):
        expect_uint_string(expect_field(obj, field, str, path), f"{path}.{field}")

    candidates = expect_field(obj, "candidates", list, path)
    candidate_keys: list[tuple[str, str, int]] = []
    exact_candidates = 0
    for index, candidate in enumerate(candidates):
        candidate_path = f"{path}.candidates[{index}]"
        candidate_obj = expect_type(candidate, dict, candidate_path)
        candidate_id = expect_hash(
            expect_field(candidate_obj, "providerId", str, candidate_path),
            f"{candidate_path}.providerId",
        )
        candidate_generation = expect_hash(
            expect_field(candidate_obj, "providerGeneration", str, candidate_path),
            f"{candidate_path}.providerGeneration",
        )
        candidate_entry = expect_non_negative(
            expect_field(candidate_obj, "providerEntryIndex", int, candidate_path),
            f"{candidate_path}.providerEntryIndex",
        )
        candidate_result = expect_field(candidate_obj, "matchResult", str, candidate_path)
        if candidate_result not in MATCH_RESULTS:
            fail(f"{candidate_path}.matchResult", f"unsupported match result '{candidate_result}'")
        if (candidate_id, candidate_generation) not in provider_keys:
            fail(candidate_path, "candidate references an absent provider generation")
        candidate_keys.append((candidate_id, candidate_generation, candidate_entry))
        exact_candidates += candidate_result == "Exact"
    if candidate_keys != sorted(candidate_keys):
        fail(f"{path}.candidates", "candidates are not sorted by provider stable identity")

    selected_provider = (provider_id, generation)
    if selected_route == "Native":
        if match_result != "Exact":
            fail(path, "Native route must have Exact matchResult")
        if selected_provider not in provider_keys or provider_entry_index < 0:
            fail(path, "Native route does not reference a registered provider entry")
        if exact_candidates != 1:
            fail(path, "Native route must have exactly one exact provider candidate")
    elif match_result == "AmbiguousExactProvider" and exact_candidates < 2:
        fail(path, "AmbiguousExactProvider requires at least two exact candidates")
    return match_result


def validate_dump(data: Any) -> dict[str, Any]:
    root = expect_type(data, dict, "root")
    schema = expect_field(root, "schemaVersion", int, "root")
    if schema != SCHEMA_VERSION:
        fail("root.schemaVersion", f"unsupported schema {schema}; expected {SCHEMA_VERSION}")
    abi = expect_non_negative(
        expect_field(root, "providerAbiRevision", int, "root"),
        "root.providerAbiRevision",
    )
    if abi == 0:
        fail("root.providerAbiRevision", "provider ABI revision must be positive")
    for field in ("hasCurrentEngine", "hasScriptEngine", "queryMatched"):
        expect_field(root, field, bool, "root")
    expect_field(root, "query", str, "root")
    expect_field(root, "targetProfile", str, "root")
    expect_uint_string(expect_field(root, "providerPublicationOrdinal", str, "root"), "root.providerPublicationOrdinal")
    expect_uint_string(expect_field(root, "routeGeneration", str, "root"), "root.routeGeneration")
    vm_count = expect_non_negative(expect_field(root, "vmRouteCount", int, "root"), "root.vmRouteCount")
    native_count = expect_non_negative(expect_field(root, "nativeRouteCount", int, "root"), "root.nativeRouteCount")
    match_counts = expect_field(root, "matchResultCounts", dict, "root")
    for key, value in match_counts.items():
        if key not in MATCH_RESULTS:
            fail(f"root.matchResultCounts.{key}", "unknown match result")
        expect_non_negative(value, f"root.matchResultCounts.{key}")

    providers = expect_field(root, "providers", list, "root")
    provider_keys: set[tuple[str, str]] = set()
    previous_provider_key: tuple[str, str] | None = None
    module_count = 0
    entry_count = 0
    for index, provider in enumerate(providers):
        provider_key, module_keys, provider_entries = validate_provider(
            provider, f"root.providers[{index}]"
        )
        if provider_key in provider_keys:
            fail(f"root.providers[{index}]", "duplicate provider generation")
        if previous_provider_key is not None and provider_key < previous_provider_key:
            fail(f"root.providers[{index}]", "providers are not sorted by stable identity")
        provider_keys.add(provider_key)
        previous_provider_key = provider_key
        module_count += len(module_keys)
        entry_count += provider_entries

    routes = expect_field(root, "routes", list, "root")
    route_match_counts: Counter[str] = Counter()
    previous_route_key: tuple[str, str] | None = None
    actual_vm = 0
    actual_native = 0
    for index, route in enumerate(routes):
        path = f"root.routes[{index}]"
        match_result = validate_route(route, path, provider_keys)
        route_match_counts[match_result] += 1
        route_key = (route["moduleKey"].lower(), route["functionKey"].lower())
        if previous_route_key is not None and route_key < previous_route_key:
            fail(path, "routes are not sorted by module/function stable identity")
        previous_route_key = route_key
        actual_native += route["selectedRoute"] == "Native"
        actual_vm += route["selectedRoute"] == "Vm"
    if actual_vm != vm_count or actual_native != native_count:
        fail(
            "root",
            f"route counts declare Native={native_count}/Vm={vm_count} but contain Native={actual_native}/Vm={actual_vm}",
        )
    for result in MATCH_RESULTS:
        if match_counts.get(result, 0) != route_match_counts.get(result, 0):
            fail(
                f"root.matchResultCounts.{result}",
                f"declares {match_counts.get(result, 0)} but routes contain {route_match_counts.get(result, 0)}",
            )
    if root["query"] and root["queryMatched"] != bool(routes or providers):
        fail("root.queryMatched", "does not agree with filtered provider/route records")
    return {
        "schema": schema,
        "abi": abi,
        "providers": len(providers),
        "modules": module_count,
        "entries": entry_count,
        "routes": len(routes),
        "native": actual_native,
        "vm": actual_vm,
        "mismatches": sum(
            count for result, count in route_match_counts.items() if result != "Exact"
        ),
        "match_counts": route_match_counts,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dump", type=Path, help="schema-v2 JSON dump to inspect")
    parser.add_argument(
        "--fail-on-mismatch",
        action="store_true",
        help="return 2 when a structurally valid dump contains non-Exact routes",
    )
    args = parser.parse_args()

    try:
        with args.dump.open("r", encoding="utf-8-sig") as stream:
            data = json.load(stream)
        summary = validate_dump(data)
    except FileNotFoundError:
        print(f"ERROR: dump not found: {args.dump}", file=sys.stderr)
        return 1
    except json.JSONDecodeError as error:
        print(
            f"ERROR: malformed JSON at line {error.lineno}, column {error.colno}: {error.msg}",
            file=sys.stderr,
        )
        return 1
    except (OSError, ValidationError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(
        "StaticJIT diagnostics: "
        f"schema={summary['schema']} abi={summary['abi']} "
        f"providers={summary['providers']} modules={summary['modules']} "
        f"entries={summary['entries']} routes={summary['routes']} "
        f"native={summary['native']} vm={summary['vm']} "
        f"mismatches={summary['mismatches']}"
    )
    if summary["match_counts"]:
        print(
            "Match results: "
            + ", ".join(
                f"{name}={summary['match_counts'][name]}"
                for name in sorted(summary["match_counts"])
            )
        )
    if args.fail_on_mismatch and summary["mismatches"]:
        print("ERROR: valid dump contains non-Exact routes", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
