"""Immutable values shared by the projection pipeline."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


class CodegenError(ValueError):
    """An authored-input or synchronization-boundary error."""

    def __init__(
        self,
        message: str,
        diagnostics: tuple["CodegenDiagnostic", ...] = (),
    ) -> None:
        super().__init__(message)
        self.diagnostics = diagnostics


@dataclass(frozen=True)
class CodegenDiagnostic:
    code: str
    source_path: str
    line: int
    byte_offset: int
    version_tag: str | None
    message: str


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
class ParsedPoint:
    name: str
    offset: int


@dataclass(frozen=True)
class ParsedBreakpoint:
    name: str
    offset: int


@dataclass(frozen=True)
class ParsedRange:
    name: str
    begin: int
    end: int


@dataclass(frozen=True)
class OriginSpan:
    clean_begin: int
    authored_begin: int
    length: int


@dataclass(frozen=True)
class ParsedAnnotations:
    points: tuple[ParsedPoint, ...] = ()
    breakpoints: tuple[ParsedBreakpoint, ...] = ()
    ranges: tuple[ParsedRange, ...] = ()


@dataclass(frozen=True)
class ParsedVersion:
    tag: str
    parent: str | None
    summary: str
    topics: tuple[str, ...]
    body: bytes
    authored_body_line: int
    authored_body_offset: int
    authored_offsets: tuple[int, ...] = ()
    clean_source: bytes = b""
    annotations: ParsedAnnotations = ParsedAnnotations()
    origin_spans: tuple[OriginSpan, ...] = ()
    authored_end: int = 0


@dataclass(frozen=True)
class ParsedFile:
    source: SourceInput
    format_version: str
    summary: str
    topics: tuple[str, ...]
    versions: tuple[ParsedVersion, ...]


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
