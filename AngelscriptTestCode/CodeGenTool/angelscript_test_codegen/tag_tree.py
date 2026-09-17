"""File-header tag tree: names, indent parents, and // explanations."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from .model import CodegenDiagnostic

_PARENT_SUFFIX = re.compile(r";\s*parent\s+(\S+)\s*$")
_TAG = re.compile(r"^[A-Za-z][A-Za-z0-9_-]*$")


@dataclass(frozen=True)
class TagTreeEntry:
    tag: str
    depth: int
    comment: str
    inferred_parent: str | None
    line: int


def _make_error(
    code: str,
    message: str,
    source_path: str,
    line: int,
    version_tag: str | None = None,
) -> CodegenDiagnostic:
    return CodegenDiagnostic(
        code=code,
        source_path=source_path,
        line=line,
        byte_offset=0,
        version_tag=version_tag,
        message=message,
    )


def extract_file_header_outline(text: str) -> tuple[TagTreeEntry, ...]:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    start = text.find("/**")
    if start < 0:
        return ()
    end = text.find("*/", start)
    if end < 0:
        return ()
    block = text[start:end]
    entries: list[TagTreeEntry] = []
    ancestors: list[str] = []
    for index, raw in enumerate(block.splitlines(), start=1):
        stripped = raw.strip()
        if stripped in {"/**", "*/", "*"}:
            continue
        if not stripped.startswith("*"):
            continue
        body = stripped[1:]
        if body.startswith(" "):
            body = body[1:]
        if not body or body.startswith("@"):
            continue
        indent_len = len(body) - len(body.lstrip(" \t"))
        rest = body.lstrip(" \t")
        comment = ""
        if "//" in rest:
            left, comment = rest.split("//", 1)
            rest = left.strip()
            comment = comment.strip()
        else:
            rest = rest.strip()
        rest = _PARENT_SUFFIX.sub("", rest).strip()
        if not _TAG.fullmatch(rest):
            continue
        depth = indent_len // 2
        while len(ancestors) > depth:
            ancestors.pop()
        parent = ancestors[depth - 1] if depth > 0 and ancestors else None
        if depth == 0:
            ancestors = [rest]
        else:
            ancestors = ancestors[:depth] + [rest]
        entries.append(
            TagTreeEntry(
                tag=rest,
                depth=depth,
                comment=comment,
                inferred_parent=parent,
                line=index,
            )
        )
    return tuple(entries)


def check_tag_tree(
    outline: tuple[TagTreeEntry, ...],
    versions: tuple[tuple[str, str | None], ...],
    *,
    require_tree: bool = True,
    require_comments: bool = True,
    source_path: str = "",
) -> tuple[CodegenDiagnostic, ...]:
    diagnostics: list[CodegenDiagnostic] = []
    if require_tree and not outline:
        diagnostics.append(
            _make_error(
                "MissingTagTree",
                "The file header must list each @begin tag as a tree with // explanations.",
                source_path,
                1,
            )
        )
        return tuple(diagnostics)

    seen: set[str] = set()
    for entry in outline:
        if entry.tag in seen:
            diagnostics.append(
                _make_error(
                    "TagTreeDuplicateTag",
                    "The file-header tag tree lists a Tag more than once.",
                    source_path,
                    entry.line,
                    entry.tag,
                )
            )
        seen.add(entry.tag)
        if require_comments and not entry.comment:
            diagnostics.append(
                _make_error(
                    "MissingTagTreeComment",
                    "Each tag-tree line must end with a // explanation.",
                    source_path,
                    entry.line,
                    entry.tag,
                )
            )

    version_parents = {tag: parent for tag, parent in versions}
    for entry in outline:
        if entry.tag not in version_parents:
            diagnostics.append(
                _make_error(
                    "TagTreeUnknownTag",
                    "The file-header tag tree lists a Tag that is not a @begin version.",
                    source_path,
                    entry.line,
                    entry.tag,
                )
            )
            continue
        expected_parent = version_parents[entry.tag]
        if entry.inferred_parent != expected_parent:
            diagnostics.append(
                _make_error(
                    "TagTreeParentMismatch",
                    "Tag-tree indent must match the version @parent.",
                    source_path,
                    entry.line,
                    entry.tag,
                )
            )

    outlined = {entry.tag for entry in outline}
    for tag, _parent in versions:
        if tag not in outlined:
            diagnostics.append(
                _make_error(
                    "TagTreeMissingTag",
                    "The file-header tag tree omits a @begin version.",
                    source_path,
                    1,
                    tag,
                )
            )

    return tuple(diagnostics)


def _version_depth(tag: str, parents: dict[str, str | None]) -> int:
    depth = 0
    seen: set[str] = set()
    current = parents.get(tag)
    while current and current not in seen:
        seen.add(current)
        depth += 1
        current = parents.get(current)
    return depth


def render_tag_tree_lines(
    versions: tuple[tuple[str, str | None, str], ...],
    existing: tuple[TagTreeEntry, ...] = (),
) -> tuple[str, ...]:
    parents = {tag: parent for tag, parent, _summary in versions}
    summaries = {tag: summary for tag, _parent, summary in versions}
    existing_comments = {entry.tag: entry.comment for entry in existing if entry.comment}
    ordered: list[str] = [entry.tag for entry in existing if entry.tag in parents]
    for tag, _parent, _summary in versions:
        if tag not in ordered:
            ordered.append(tag)
    widths = [len("  " * _version_depth(tag, parents) + tag) for tag in ordered]
    width = max(widths) if widths else 0
    lines: list[str] = []
    for tag in ordered:
        depth = _version_depth(tag, parents)
        left = ("  " * depth) + tag
        comment = existing_comments.get(tag) or summaries[tag]
        lines.append(f" * {left:<{width}}    // {comment}")
    return tuple(lines)


def replace_file_header_outline(text: str, tree_lines: tuple[str, ...]) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    start = text.find("/**")
    end = text.find("*/", start)
    if start < 0 or end < 0:
        raise ValueError("missing file header")
    header = text[start:end]
    lines = header.splitlines()
    last_directive = 0
    for index, line in enumerate(lines):
        body = line.strip()
        if body.startswith("*"):
            body = body[1:].strip()
        if body.startswith("@"):
            last_directive = index
    prefix = lines[: last_directive + 1]
    rebuilt = "\n".join([*prefix, " *", *tree_lines, " */"]) + "\n"
    rest = text[end + 2 :].lstrip("\n")
    return text[:start] + rebuilt + rest


def _iter_language_authors(author_root: Path):
    import hashlib

    from .container_parser import parse_source_file
    from .model import SourceInput

    language_root = Path(author_root) / "Language"
    if not language_root.is_dir():
        return

    for path in sorted(language_root.rglob("*.as")):
        relative = path.relative_to(author_root).as_posix()
        content = path.read_bytes()
        file_tag = relative[: -len(".as")]
        source = SourceInput(
            full_path=path,
            relative_path=relative,
            file_tag=file_tag,
            output_relative_path=f"{file_tag}.generated.cpp",
            content=content,
            content_sha256=hashlib.sha256(content).hexdigest(),
            symbol_suffix=hashlib.sha256(file_tag.encode("utf-8")).hexdigest()[:12],
        )
        yield path, relative, content, parse_source_file(source)


def rewrite_language_tag_trees(author_root: Path) -> int:
    changed = 0
    for path, _relative, content, parsed in _iter_language_authors(author_root):
        text = content.decode("utf-8")
        existing = extract_file_header_outline(text)
        versions = tuple((version.tag, version.parent, version.summary) for version in parsed.versions)
        rewritten = replace_file_header_outline(text, render_tag_tree_lines(versions, existing))
        if rewritten != text.replace("\r\n", "\n").replace("\r", "\n"):
            path.write_text(rewritten, encoding="utf-8", newline="\n")
            changed += 1
    return changed


def report_author_tag_trees(author_root: Path) -> tuple[CodegenDiagnostic, ...]:
    diagnostics: list[CodegenDiagnostic] = []
    for _path, relative, content, parsed in _iter_language_authors(author_root):
        outline = extract_file_header_outline(content.decode("utf-8"))
        versions = tuple((version.tag, version.parent) for version in parsed.versions)
        diagnostics.extend(
            check_tag_tree(
                outline,
                versions,
                require_tree=True,
                require_comments=True,
                source_path=relative,
            )
        )
    return tuple(diagnostics)
