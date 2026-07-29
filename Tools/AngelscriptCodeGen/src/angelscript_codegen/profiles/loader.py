from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from angelscript_codegen.model.types import TypeKind, TypeSpec


class ProfileValidationError(ValueError):
    """Raised for an invalid or unresolved declarative generation profile."""


@dataclass(frozen=True)
class CallableSpec:
    name: str
    return_type: str
    parameters: tuple[str, ...]
    requires: tuple[str, ...] = ()
    evidence: tuple[str, ...] = ()


@dataclass(frozen=True)
class FragmentSpec:
    id: str
    requires: tuple[str, ...]
    source: str
    cleanup: str = ""
    evidence: tuple[str, ...] = ()


@dataclass(frozen=True)
class Profile:
    id: str
    harness: str
    types: dict[str, TypeSpec]
    callables: tuple[CallableSpec, ...]
    fragments: tuple[FragmentSpec, ...]
    invalid_rules: tuple[str, ...]
    limits: dict[str, int]
    contexts: tuple[str, ...] = ()
    evidence: tuple[str, ...] = ()


def built_in_profile_directory() -> Path:
    return Path(__file__).with_name("data")


def load_profile(profile_id: str, directory: Path) -> Profile:
    return _load_profile(profile_id, directory, ())


def _load_profile(profile_id: str, directory: Path, ancestry: tuple[str, ...]) -> Profile:
    if profile_id in ancestry:
        chain = " -> ".join((*ancestry, profile_id))
        raise ProfileValidationError(f"Profile inheritance cycle: {chain}")

    path = directory / f"{profile_id}.json"
    if not path.is_file():
        raise ProfileValidationError(f"Profile '{profile_id}' was not found at '{path}'.")

    document = _read_document(path)
    if document.get("schema_version") != 1:
        raise ProfileValidationError(f"Profile '{profile_id}' must use schema_version 1.")
    if document.get("id") != profile_id:
        raise ProfileValidationError(f"Profile file '{path.name}' must declare id '{profile_id}'.")

    parent_id = document.get("extends")
    if parent_id is not None and not isinstance(parent_id, str):
        raise ProfileValidationError(f"Profile '{profile_id}' has a non-string extends value.")
    parent = _load_profile(parent_id, directory, (*ancestry, profile_id)) if parent_id else None

    harness = _string(document.get("harness"), "harness", profile_id)
    contexts = _merge_unique(
        parent.contexts if parent else (),
        (harness, *tuple(_string_list(document.get("contexts", []), "contexts", profile_id))),
    )

    types = dict(parent.types) if parent else {}
    for type_document in _list(document, "types", profile_id):
        type_spec = _parse_type(type_document, profile_id)
        if type_spec.name in types:
            raise ProfileValidationError(f"Profile '{profile_id}' redefines type '{type_spec.name}'.")
        types[type_spec.name] = type_spec

    callables = list(parent.callables) if parent else []
    for callable_document in _list(document, "callables", profile_id):
        callable_spec = _parse_callable(callable_document, profile_id)
        _validate_callable_types(callable_spec, types, profile_id)
        _validate_required_contexts(callable_spec.requires, contexts, profile_id, f"callable '{callable_spec.name}'")
        if any(existing.name == callable_spec.name for existing in callables):
            raise ProfileValidationError(f"Profile '{profile_id}' redefines callable '{callable_spec.name}'.")
        callables.append(callable_spec)

    fragments = list(parent.fragments) if parent else []
    for fragment_document in _list(document, "fragments", profile_id):
        fragment = _parse_fragment(fragment_document, profile_id)
        _validate_required_contexts(fragment.requires, contexts, profile_id, f"fragment '{fragment.id}'")
        if any(existing.id == fragment.id for existing in fragments):
            raise ProfileValidationError(f"Profile '{profile_id}' redefines fragment '{fragment.id}'.")
        fragments.append(fragment)

    invalid_rules = _merge_unique(
        parent.invalid_rules if parent else (),
        tuple(_string_list(document.get("invalid_rules", []), "invalid_rules", profile_id)),
    )
    evidence = _merge_unique(
        parent.evidence if parent else (),
        tuple(_string_list(document.get("evidence", []), "evidence", profile_id)),
    )
    limits = dict(parent.limits) if parent else {}
    limits.update(_limits(document.get("limits", {}), profile_id))

    return Profile(
        id=profile_id,
        harness=harness,
        types=types,
        callables=tuple(callables),
        fragments=tuple(fragments),
        invalid_rules=invalid_rules,
        limits=limits,
        contexts=contexts,
        evidence=evidence,
    )


def _read_document(path: Path) -> dict[str, Any]:
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ProfileValidationError(f"Profile '{path.name}' contains invalid JSON: {error.msg}") from error
    if not isinstance(document, dict):
        raise ProfileValidationError(f"Profile '{path.name}' must contain a JSON object.")
    return document


def _parse_type(document: Any, profile_id: str) -> TypeSpec:
    if not isinstance(document, dict):
        raise ProfileValidationError(f"Profile '{profile_id}' has a non-object type declaration.")
    name = _string(document.get("name"), "type name", profile_id)
    kind_name = _string(document.get("kind"), f"type '{name}' kind", profile_id)
    try:
        kind = TypeKind(kind_name)
    except ValueError as error:
        raise ProfileValidationError(f"Profile '{profile_id}' has unknown type kind '{kind_name}'.") from error
    is_handle = document.get("is_handle", False)
    if not isinstance(is_handle, bool):
        raise ProfileValidationError(f"Profile '{profile_id}' type '{name}' has non-boolean is_handle.")
    return TypeSpec(name, kind, is_handle)


def _parse_callable(document: Any, profile_id: str) -> CallableSpec:
    if not isinstance(document, dict):
        raise ProfileValidationError(f"Profile '{profile_id}' has a non-object callable declaration.")
    name = _string(document.get("name"), "callable name", profile_id)
    return CallableSpec(
        name=name,
        return_type=_string(document.get("return_type"), f"callable '{name}' return_type", profile_id),
        parameters=tuple(_string_list(document.get("parameters", []), "parameters", profile_id)),
        requires=tuple(_string_list(document.get("requires", []), "requires", profile_id)),
        evidence=tuple(_string_list(document.get("evidence", []), "evidence", profile_id)),
    )


def _parse_fragment(document: Any, profile_id: str) -> FragmentSpec:
    if not isinstance(document, dict):
        raise ProfileValidationError(f"Profile '{profile_id}' has a non-object fragment declaration.")
    fragment_id = _string(document.get("id"), "fragment id", profile_id)
    return FragmentSpec(
        id=fragment_id,
        requires=tuple(_string_list(document.get("requires", []), "requires", profile_id)),
        source=_string(document.get("source"), f"fragment '{fragment_id}' source", profile_id),
        cleanup=_optional_string(document.get("cleanup", ""), f"fragment '{fragment_id}' cleanup", profile_id),
        evidence=tuple(_string_list(document.get("evidence", []), "evidence", profile_id)),
    )


def _validate_callable_types(callable_spec: CallableSpec, types: dict[str, TypeSpec], profile_id: str) -> None:
    referenced_types = (callable_spec.return_type, *callable_spec.parameters)
    for type_name in referenced_types:
        if type_name != "void" and type_name not in types:
            raise ProfileValidationError(
                f"Profile '{profile_id}' callable '{callable_spec.name}' references unknown type '{type_name}'."
            )


def _list(document: dict[str, Any], key: str, profile_id: str) -> list[Any]:
    value = document.get(key, [])
    if not isinstance(value, list):
        raise ProfileValidationError(f"Profile '{profile_id}' key '{key}' must be a list.")
    return value


def _string(value: Any, field: str, profile_id: str) -> str:
    if not isinstance(value, str) or not value:
        raise ProfileValidationError(f"Profile '{profile_id}' requires a non-empty {field}.")
    return value


def _optional_string(value: Any, field: str, profile_id: str) -> str:
    if not isinstance(value, str):
        raise ProfileValidationError(f"Profile '{profile_id}' field '{field}' must be a string.")
    return value


def _string_list(value: Any, field: str, profile_id: str) -> list[str]:
    if not isinstance(value, list) or any(not isinstance(item, str) or not item for item in value):
        raise ProfileValidationError(f"Profile '{profile_id}' key '{field}' must be a list of non-empty strings.")
    return value


def _limits(value: Any, profile_id: str) -> dict[str, int]:
    if not isinstance(value, dict) or any(not isinstance(item, int) or item < 0 for item in value.values()):
        raise ProfileValidationError(f"Profile '{profile_id}' limits must map names to non-negative integers.")
    return value


def _merge_unique(parent: tuple[str, ...], child: tuple[str, ...]) -> tuple[str, ...]:
    return tuple(dict.fromkeys((*parent, *child)))


def _validate_required_contexts(
    required: tuple[str, ...],
    contexts: tuple[str, ...],
    profile_id: str,
    subject: str,
) -> None:
    unresolved = tuple(context for context in required if context not in contexts)
    if unresolved:
        names = ", ".join(unresolved)
        raise ProfileValidationError(
            f"Profile '{profile_id}' {subject} requires undeclared context(s): {names}."
        )
