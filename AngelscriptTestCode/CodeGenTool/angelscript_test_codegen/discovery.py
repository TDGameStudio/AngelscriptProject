"""Read-only authored `.as` discovery."""

from __future__ import annotations

import hashlib
from pathlib import Path

from .model import CodegenError, SourceInput
from .paths import derive_source_identity


def _validate_unique_paths(relative_paths: list[str]) -> None:
    by_folded_path: dict[str, str] = {}
    for relative_path in relative_paths:
        folded_path = relative_path.casefold()
        previous = by_folded_path.get(folded_path)
        if previous is not None:
            raise CodegenError(
                "Authored source paths collide under case-insensitive normalization: "
                f"{previous!r} and {relative_path!r}"
            )
        by_folded_path[folded_path] = relative_path


def discover_sources(author_root: Path) -> tuple[SourceInput, ...]:
    author_root = Path(author_root).resolve()
    if not author_root.is_dir():
        raise CodegenError(f"Author root does not exist or is not a directory: {author_root}")

    candidates: list[tuple[str, Path]] = []
    for candidate in author_root.rglob("*"):
        try:
            relative_path = candidate.relative_to(author_root).as_posix()
        except ValueError as error:
            raise CodegenError(f"Discovered source escapes author root: {candidate}") from error

        segments = relative_path.split("/")
        if segments and segments[0].casefold() == "codegentool":
            continue
        if candidate.suffix != ".as" or not candidate.is_file():
            continue

        resolved_candidate = candidate.resolve()
        try:
            resolved_candidate.relative_to(author_root)
        except ValueError as error:
            raise CodegenError(
                f"Authored source resolves outside the author root: {relative_path!r}"
            ) from error
        candidates.append((relative_path, resolved_candidate))

    candidates.sort(key=lambda item: item[0])
    relative_paths = [relative_path for relative_path, _ in candidates]
    _validate_unique_paths(relative_paths)

    sources: list[SourceInput] = []
    for relative_path, full_path in candidates:
        file_tag, output_relative_path = derive_source_identity(relative_path)
        content = full_path.read_bytes()
        sources.append(
            SourceInput(
                full_path=full_path,
                relative_path=relative_path,
                file_tag=file_tag,
                output_relative_path=output_relative_path,
                content=content,
                content_sha256=hashlib.sha256(content).hexdigest(),
                symbol_suffix=hashlib.sha256(file_tag.encode("utf-8")).hexdigest()[:12],
            )
        )
    return tuple(sources)
