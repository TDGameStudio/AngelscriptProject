"""Repository roots and reversible authored/generated path mapping."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path, PurePosixPath

from .model import CodegenError


@dataclass(frozen=True)
class CodegenPaths:
    repository_root: Path
    author_root: Path
    generated_root: Path

    @classmethod
    def from_tool_file(cls, tool_file: Path) -> "CodegenPaths":
        tool_root = tool_file.resolve().parent
        author_root = tool_root.parent
        repository_root = author_root.parent
        return cls(
            repository_root=repository_root,
            author_root=author_root,
            generated_root=repository_root
            / "Plugins"
            / "Angelscript"
            / "Source"
            / "AngelscriptTest"
            / "TestCode"
            / "Generated",
        )


def derive_source_identity(relative_path: str) -> tuple[str, str]:
    if not relative_path or "\\" in relative_path:
        raise CodegenError(
            f"Authored source path must be a nonempty forward-slash relative path: {relative_path!r}"
        )

    segments = relative_path.split("/")
    pure_path = PurePosixPath(relative_path)
    if (
        pure_path.is_absolute()
        or any(segment in ("", ".", "..") for segment in segments)
        or not relative_path.endswith(".as")
        or relative_path == ".as"
    ):
        raise CodegenError(f"Invalid authored .as source path: {relative_path!r}")

    file_tag = relative_path[:-3]
    return file_tag, f"{file_tag}.generated.cpp"
