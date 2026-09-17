"""Whole-file version topology validation."""

from __future__ import annotations

from .model import CodegenDiagnostic, ParsedVersion


def is_nonempty_text(value: str) -> bool:
    return bool(value.strip())


def is_valid_version_tag(tag: str) -> bool:
    return bool(tag) and all(character not in " \t\r\n/\\" for character in tag)


def validate_topology(
    source_path: str,
    versions: tuple[ParsedVersion, ...],
) -> tuple[CodegenDiagnostic, ...]:
    diagnostics: list[CodegenDiagnostic] = []
    tag_counts: dict[str, int] = {}
    unique_indices: dict[str, int] = {}
    root_count = 0

    for index, version in enumerate(versions):
        if version.tag == "root":
            root_count += 1
        tag_counts[version.tag] = tag_counts.get(version.tag, 0) + 1
        if tag_counts[version.tag] == 1:
            unique_indices[version.tag] = index
        else:
            unique_indices.pop(version.tag, None)
            diagnostics.append(
                CodegenDiagnostic(
                    code="DuplicateVersionTag",
                    source_path=source_path,
                    line=version.authored_body_line,
                    byte_offset=version.authored_body_offset,
                    version_tag=version.tag or None,
                    message="Each version Tag must be unique within a file.",
                )
            )

    if root_count == 0:
        diagnostics.append(
            CodegenDiagnostic(
                code="MissingRoot",
                source_path=source_path,
                line=1,
                byte_offset=0,
                version_tag=None,
                message="A file must contain exactly one root version.",
            )
        )
    elif root_count > 1:
        diagnostics.append(
            CodegenDiagnostic(
                code="MultipleRoots",
                source_path=source_path,
                line=1,
                byte_offset=0,
                version_tag=None,
                message="A file must contain exactly one root version.",
            )
        )

    for version in versions:
        if version.tag == "root" or version.parent is None:
            continue
        if version.parent not in tag_counts:
            diagnostics.append(
                CodegenDiagnostic(
                    code="MissingParent",
                    source_path=source_path,
                    line=version.authored_body_line,
                    byte_offset=version.authored_body_offset,
                    version_tag=version.tag or None,
                    message="The declared Parent does not exist in this file.",
                )
            )

    resolved: set[str] = set()
    for start_tag in unique_indices:
        if start_tag in resolved:
            continue
        path: list[str] = []
        positions: dict[str, int] = {}
        current = start_tag
        while current not in resolved:
            if current in positions:
                diagnostics.append(
                    CodegenDiagnostic(
                        code="VersionCycle",
                        source_path=source_path,
                        line=1,
                        byte_offset=0,
                        version_tag=path[positions[current]],
                        message="Version Parent relationships must not form a cycle.",
                    )
                )
                break
            index = unique_indices.get(current)
            if index is None:
                break
            positions[current] = len(path)
            path.append(current)
            node = versions[index]
            if node.tag == "root" or node.parent is None:
                break
            parent_count = tag_counts.get(node.parent)
            if parent_count is None or parent_count != 1:
                break
            current = node.parent
        resolved.update(path)

    return tuple(diagnostics)
