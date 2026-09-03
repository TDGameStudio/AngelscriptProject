"""Canonical UTF-8 source and JSON bytes."""

from __future__ import annotations

import json
from typing import Any


class CanonicalError(ValueError):
    pass


def canonical_source_bytes(text: str | bytes) -> bytes:
    if isinstance(text, bytes):
        raw = text
        if raw.startswith(b"\xef\xbb\xbf"):
            raw = raw[3:]
        text = raw.decode("utf-8")
    elif text.startswith("\ufeff"):
        text = text[1:]
    normalized = text.replace("\r\n", "\n").replace("\r", "\n")
    if not normalized.endswith("\n"):
        normalized += "\n"
    else:
        while normalized.endswith("\n\n"):
            normalized = normalized[:-1]
    return normalized.encode("utf-8")


def canonical_json_bytes(value: Any) -> bytes:
    try:
        dumped = json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
            allow_nan=False,
        )
    except (TypeError, ValueError) as exc:
        raise CanonicalError(str(exc)) from exc
    return canonical_source_bytes(dumped)
