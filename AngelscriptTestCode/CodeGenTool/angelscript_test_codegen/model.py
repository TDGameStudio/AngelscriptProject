"""Immutable values shared by the projection pipeline."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


class CodegenError(ValueError):
    """An authored-input or synchronization-boundary error."""


@dataclass(frozen=True)
class SourceInput:
    full_path: Path
    relative_path: str
    file_tag: str
    output_relative_path: str
    content: bytes
    content_sha256: str
    symbol_suffix: str


@dataclass(frozen=True)
class Projection:
    source: SourceInput
    output_path: Path
    content: bytes


@dataclass(frozen=True)
class SyncPlan:
    author_root: Path
    generated_root: Path
    projections: tuple[Projection, ...] = ()
    missing: tuple[str, ...] = ()
    changed: tuple[str, ...] = ()
    stale: tuple[str, ...] = ()
    unsafe_extra: tuple[str, ...] = ()

    @property
    def is_clean(self) -> bool:
        return not (self.missing or self.changed or self.stale or self.unsafe_extra)
