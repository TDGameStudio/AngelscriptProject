"""Stable CaseKey, UTF-8 FNV-1a, and C++ symbol derivation."""

from __future__ import annotations

import re

from .splitmix64 import MASK, fnv1a64

AUTHORED_PREFIX = "TestSource/"


class CaseKeyError(ValueError):
    def __init__(self, code: str, message: str) -> None:
        super().__init__(message)
        self.code = code


def fnv1a64_utf8(text: str) -> int:
    return fnv1a64(text.encode("utf-8"))


def case_key_from_authored_path(relative_path: str) -> str:
    path = relative_path.replace("\\", "/")
    if ":" in path or path.startswith("/") or path.startswith("../"):
        raise CaseKeyError("absolute_path", "CaseKey must not use absolute or parent paths")
    if not path.startswith(AUTHORED_PREFIX):
        path = AUTHORED_PREFIX + path.lstrip("/")
    if path.endswith(".as"):
        path = path[: -len(".as")]
    if "//" in path:
        raise CaseKeyError("invalid_case_key", "CaseKey must not contain empty segments")
    return path


def cpp_symbol(case_key: str, declared: str | None = None) -> str:
    if declared:
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", declared):
            raise CaseKeyError("invalid_symbol", f"invalid C++ symbol {declared}")
        return declared
    body = case_key
    if body.startswith(AUTHORED_PREFIX):
        body = body[len(AUTHORED_PREFIX) :]
    for origin in ("NativeSDK/", "Coverage/", "Inline/"):
        if body.startswith(origin):
            body = body[len(origin) :]
            break
    cleaned = re.sub(r"[^A-Za-z0-9]+", "_", body)
    cleaned = cleaned.strip("_")
    if not cleaned:
        raise CaseKeyError("invalid_symbol", "empty C++ symbol")
    if cleaned[0].isdigit():
        cleaned = "TS_" + cleaned
    if not cleaned.startswith("TS_"):
        cleaned = "TS_" + cleaned
    return cleaned.upper()


def hashed_suffix(case_key: str) -> str:
    return f"{fnv1a64_utf8(case_key):016X}"


def validate_unique_symbols(pairs: list[tuple[str, str]]) -> None:
    seen: dict[str, str] = {}
    for case_key, symbol in pairs:
        owner = seen.get(symbol)
        if owner is not None and owner != case_key:
            raise CaseKeyError("symbol_collision", f"{symbol} collides for {owner} and {case_key}")
        seen[symbol] = case_key


def mix_identity(case_key: str, seed: int) -> int:
    return (fnv1a64_utf8(case_key) ^ (seed & MASK)) & MASK
