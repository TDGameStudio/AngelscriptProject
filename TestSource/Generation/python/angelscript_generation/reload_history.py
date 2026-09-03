"""Parse SourceHistory .as files whose version tree lives in comment markers.

The AngelScript body is @version root. Child versions are @change snapshots in
the trailing block comment. Unified diffs are generated from those snapshots
for C++ import; they are not hand-written.
"""

from __future__ import annotations

from dataclasses import dataclass
import difflib
from pathlib import Path
import re


RELOAD_HISTORY_SUFFIX = ".reload.as"
ROOT_VERSION = "root"
SOURCE_HISTORY_HARNESS = "@Harness SourceHistory"

FILE_MARKERS = frozenset({"Theme", "Subject", "Harness", "Tag", "Module", "Identity", "Provenance"})
VERSION_MARKERS = frozenset(
    {
        "version",
        "parent",
        "compile",
        "expect",
        "retain",
        "replace",
        "oracle",
        "onto",
        "path",
        "change",
        "diff",
        "end",
    }
)


def is_reload_history_path(path: Path) -> bool:
    if path.name.endswith(RELOAD_HISTORY_SUFFIX):
        return True
    if path.suffix != ".as":
        return False
    try:
        with path.open(encoding="utf-8-sig") as handle:
            head = handle.read(4096)
    except OSError:
        return False
    return SOURCE_HISTORY_HARNESS in head


class ReloadHistoryError(ValueError):
    def __init__(self, code: str, message: str) -> None:
        super().__init__(message)
        self.code = code


@dataclass(frozen=True)
class ReloadVersion:
    tag: str
    parent: str | None
    compile: str
    expect: str
    retain: tuple[str, ...]
    oracles: tuple[str, ...]
    change: str
    diff: str
    onto_failed: bool = False


@dataclass(frozen=True)
class ReloadHistory:
    source_path: str
    header: str
    origin: str
    versions: tuple[ReloadVersion, ...]

    @property
    def commits(self) -> tuple[ReloadVersion, ...]:
        return tuple(item for item in self.versions if item.tag != ROOT_VERSION)


_VERSION_START = re.compile(r"^@version\s+(\S+)\s*$")
_FIELD = re.compile(r"^@(parent|compile|expect|retain|replace|oracle|onto|path)\s+(.*)$")
_TAG = re.compile(r"^[A-Za-z][A-Za-z0-9_-]*$")


def parse_reload_history(text: str, source_path: str = "") -> ReloadHistory:
    normalized = text.replace("\r\n", "\n").replace("\r", "\n")
    header, origin, tree = _split_reload_document(normalized, source_path)
    versions = _parse_version_tree(tree, source_path)
    roots = [item for item in versions if item.tag == ROOT_VERSION]
    if len(roots) != 1:
        raise ReloadHistoryError("root_count", f"{source_path}: need exactly one @version root")
    if roots[0].change.strip() or roots[0].diff.strip():
        raise ReloadHistoryError("root_change", f"{source_path}: @version root must not have @change/@diff")
    if roots[0].parent is not None:
        raise ReloadHistoryError("root_parent", f"{source_path}: @version root must not have @parent")
    tags = [item.tag for item in versions]
    if len(tags) != len(set(tags)):
        raise ReloadHistoryError("duplicate_version", f"{source_path}: duplicate @version tag")
    by_tag = {item.tag: item for item in versions}
    filled: list[ReloadVersion] = []
    sources = {ROOT_VERSION: _with_trailing_newline(origin)}
    for item in versions:
        if item.tag == ROOT_VERSION:
            filled.append(item)
            continue
        if item.parent is None or item.parent not in by_tag:
            raise ReloadHistoryError("missing_parent", f"{source_path}: @{item.tag} missing @parent")
        if not item.change.strip():
            raise ReloadHistoryError("missing_change", f"{source_path}: @{item.tag} missing @change")
        if not item.compile:
            raise ReloadHistoryError("missing_compile", f"{source_path}: @{item.tag} missing @compile")
        if item.parent not in sources:
            raise ReloadHistoryError(
                "parent_order",
                f"{source_path}: @{item.tag} parent @{item.parent} must appear first",
            )
        child = _with_trailing_newline(item.change)
        parent_source = sources[item.parent]
        diff = generate_unified_diff(parent_source, child, item.tag)
        applied = apply_unified_diff(parent_source, diff)
        if applied != child:
            raise ReloadHistoryError(
                "generated_diff_mismatch",
                f"{source_path}: generated diff for @{item.tag} does not reconstruct @change",
            )
        sources[item.tag] = child
        filled.append(
            ReloadVersion(
                tag=item.tag,
                parent=item.parent,
                compile=item.compile,
                expect=item.expect,
                retain=item.retain,
                oracles=item.oracles,
                change=child,
                diff=diff,
                onto_failed=item.onto_failed,
            )
        )
        by_tag[item.tag] = filled[-1]
    if not origin.strip():
        raise ReloadHistoryError("empty_origin", f"{source_path}: AngelScript body (root) is empty")
    return ReloadHistory(source_path=source_path, header=header, origin=origin, versions=tuple(filled))


def extract_version(history: ReloadHistory, tag: str) -> str:
    by_tag = {item.tag: item for item in history.versions}
    if tag not in by_tag:
        raise ReloadHistoryError("unknown_version", f"{history.source_path}: no @version {tag}")
    cache: dict[str, str] = {ROOT_VERSION: history.origin}

    def resolve(name: str) -> str:
        if name in cache:
            return cache[name]
        node = by_tag[name]
        assert node.parent is not None
        parent_source = resolve(node.parent)
        if node.change.strip():
            child = _with_trailing_newline(node.change)
        else:
            child = apply_unified_diff(parent_source, node.diff)
        reversed_source = apply_unified_diff(child, reverse_unified_diff(node.diff))
        if reversed_source != parent_source:
            raise ReloadHistoryError(
                "diff_not_reversible",
                f"@{node.tag}: reverse(diff) did not restore @{node.parent}",
            )
        if child == parent_source and node.compile != "NoChange":
            raise ReloadHistoryError("empty_state_change", f"@{node.tag}: diff did not change the source")
        cache[name] = child
        return child

    return resolve(tag)


def replay_history(history: ReloadHistory) -> tuple["ReplayStep", ...]:
    steps: list[ReplayStep] = []
    for node in history.commits:
        assert node.parent is not None
        before = extract_version(history, node.parent)
        after = extract_version(history, node.tag)
        steps.append(
            ReplayStep(
                slug=node.tag,
                before=before,
                after=after,
                compile=node.compile,
                expect=node.expect,
                oracles=node.oracles,
            )
        )
    return tuple(steps)


def _split_reload_document(text: str, source_path: str) -> tuple[str, str, str]:
    stripped = text.lstrip()
    if not stripped.startswith("/**"):
        raise ReloadHistoryError("missing_header", f"{source_path}: file must start with /** file markers */")
    header_close = stripped.find("*/")
    if header_close < 0:
        raise ReloadHistoryError("unclosed_header", f"{source_path}: unclosed file-marker comment")
    header = stripped[3:header_close]
    rest = stripped[header_close + 2 :]
    tree_at = rest.rfind("\n/*")
    if tree_at < 0:
        raise ReloadHistoryError("missing_tree", f"{source_path}: missing trailing /* version tree */")
    origin = rest[:tree_at].strip("\n") + "\n"
    tree_block = rest[tree_at + 1 :].strip()
    if not tree_block.startswith("/*") or not tree_block.endswith("*/"):
        raise ReloadHistoryError("bad_tree_comment", f"{source_path}: version tree must be a block comment")
    tree = tree_block[2:-2]
    _assert_known_file_markers(header, source_path)
    return header.strip("\n"), origin, tree


def _assert_known_file_markers(header: str, source_path: str) -> None:
    for raw in header.split("\n"):
        line = raw.strip()
        if line.startswith("*"):
            line = line[1:].strip()
        if line.startswith("@"):
            name = line[1:].split(None, 1)[0]
            if name not in FILE_MARKERS:
                raise ReloadHistoryError("unknown_file_marker", f"{source_path}: unknown file marker @{name}")


def _parse_version_tree(tree: str, source_path: str) -> list[ReloadVersion]:
    raw_lines = tree.replace("\r\n", "\n").split("\n")
    versions: list[ReloadVersion] = []
    idx = 0
    while idx < len(raw_lines) and _tree_line(raw_lines[idx]) == "":
        idx += 1
    while idx < len(raw_lines):
        match = _VERSION_START.match(_tree_line(raw_lines[idx]))
        if match is None:
            if _tree_line(raw_lines[idx]) == "":
                idx += 1
                continue
            raise ReloadHistoryError(
                "expected_version",
                f"{source_path}: expected @version, found {_tree_line(raw_lines[idx])!r}",
            )
        tag = match.group(1)
        if not _TAG.fullmatch(tag):
            raise ReloadHistoryError("bad_version_tag", f"{source_path}: invalid @version {tag}")
        idx += 1
        parent: str | None = None
        compile_mode = ""
        expect = ""
        retain: list[str] = []
        oracles: list[str] = []
        onto_failed = False
        change = ""
        diff = ""
        while idx < len(raw_lines) and not _VERSION_START.match(_tree_line(raw_lines[idx])):
            line = _tree_line(raw_lines[idx])
            if line == "" or line.startswith("//"):
                idx += 1
                continue
            if line in {"@change", "@diff"}:
                kind = line[1:]
                idx += 1
                payload: list[str] = []
                while idx < len(raw_lines) and _tree_line(raw_lines[idx]) != "@end":
                    payload.append(raw_lines[idx])
                    idx += 1
                if idx >= len(raw_lines) or _tree_line(raw_lines[idx]) != "@end":
                    raise ReloadHistoryError("missing_diff_end", f"{source_path}: @{tag} missing @end")
                idx += 1
                text = "\n".join(payload) + ("\n" if payload else "")
                if kind == "change":
                    change = text
                else:
                    diff = text
                continue
            field = _FIELD.match(line)
            if field is None:
                if line.startswith("@"):
                    name = line[1:].split(None, 1)[0]
                    raise ReloadHistoryError(
                        "unknown_version_marker",
                        f"{source_path}: unknown version marker @{name}",
                    )
                raise ReloadHistoryError("unknown_commit_field", f"{source_path}: unexpected line {line!r} in @{tag}")
            name, value = field.group(1), field.group(2).strip()
            if name == "parent":
                parent = value
            elif name == "compile":
                compile_mode = value
            elif name == "expect":
                expect = value
            elif name == "retain":
                retain = [part.strip() for part in value.split(",") if part.strip()]
            elif name == "oracle":
                oracles.append(value)
            elif name == "onto":
                onto_failed = value == "failed"
            idx += 1
        if tag == ROOT_VERSION:
            compile_mode = compile_mode or "Initial"
            expect = expect or "compile-ok"
            parent = None
        versions.append(
            ReloadVersion(
                tag=tag,
                parent=parent,
                compile=compile_mode,
                expect=expect,
                retain=tuple(retain),
                oracles=tuple(oracles),
                change=change,
                diff=diff,
                onto_failed=onto_failed,
            )
        )
    if not versions:
        raise ReloadHistoryError("empty_tree", f"{source_path}: version tree has no @version")
    return versions


def _tree_line(raw: str) -> str:
    line = raw.strip()
    if line.startswith("*"):
        line = line[1:].lstrip()
    return line


def _join_source(lines: list[str]) -> str:
    if not lines:
        return ""
    return "\n".join(lines) + "\n"


def _with_trailing_newline(text: str) -> str:
    if not text.endswith("\n"):
        return text + "\n"
    return text


def generate_unified_diff(parent: str, child: str, name: str) -> str:
    left = _with_trailing_newline(parent).splitlines(keepends=True)
    right = _with_trailing_newline(child).splitlines(keepends=True)
    return "".join(difflib.unified_diff(left, right, fromfile=f"a/{name}", tofile=f"b/{name}"))


def apply_unified_diff(source: str, diff: str) -> str:
    """Apply a single-file unified diff. Context must match exactly."""
    source_lines = source.splitlines(keepends=True)
    hunks = _parse_hunks(diff)
    if not hunks:
        raise ReloadHistoryError("empty_diff", "unified diff has no hunks")

    result: list[str] = []
    cursor = 0
    for old_start, old_count, new_count, hunk_lines in hunks:
        old_index = old_start - 1
        if old_index < cursor:
            raise ReloadHistoryError("overlapping_hunk", f"hunk starts at {old_start} before {cursor + 1}")
        result.extend(source_lines[cursor:old_index])
        consumed = 0
        produced = 0
        read_at = old_index
        for raw in hunk_lines:
            if not raw:
                tag, body = " ", ""
            else:
                tag, body = raw[0], raw[1:]
            payload = body + "\n"
            if tag == " ":
                if read_at >= len(source_lines) or source_lines[read_at] != payload:
                    actual = source_lines[read_at] if read_at < len(source_lines) else "<eof>"
                    raise ReloadHistoryError(
                        "context_mismatch",
                        f"context failed at line {read_at + 1}: expected {payload!r} got {actual!r}",
                    )
                result.append(source_lines[read_at])
                read_at += 1
                consumed += 1
                produced += 1
            elif tag == "-":
                if read_at >= len(source_lines) or source_lines[read_at] != payload:
                    actual = source_lines[read_at] if read_at < len(source_lines) else "<eof>"
                    raise ReloadHistoryError(
                        "delete_mismatch",
                        f"delete failed at line {read_at + 1}: expected {payload!r} got {actual!r}",
                    )
                read_at += 1
                consumed += 1
            elif tag == "+":
                result.append(payload)
                produced += 1
            elif tag == "\\":
                continue
            else:
                raise ReloadHistoryError("bad_diff_line", f"unsupported diff line {raw!r}")
        if old_count and consumed != old_count:
            raise ReloadHistoryError(
                "hunk_old_count",
                f"hunk old count {old_count} but consumed {consumed}",
            )
        if new_count and produced != new_count:
            raise ReloadHistoryError(
                "hunk_new_count",
                f"hunk new count {new_count} but produced {produced}",
            )
        cursor = read_at
    result.extend(source_lines[cursor:])
    text = "".join(result)
    if source.endswith("\n") and not text.endswith("\n"):
        text += "\n"
    return text


def reverse_unified_diff(diff: str) -> str:
    reversed_lines: list[str] = []
    for line in diff.splitlines():
        if line.startswith("@@"):
            match = re.match(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$", line)
            if match is None:
                raise ReloadHistoryError("bad_hunk_header", f"cannot reverse {line!r}")
            old_start, old_count, new_start, new_count, suffix = match.groups()
            reversed_lines.append(
                f"@@ -{new_start},{new_count or '1'} +{old_start},{old_count or '1'} @@{suffix}"
            )
        elif line.startswith("---"):
            reversed_lines.append("+++ " + line[4:] if line.startswith("--- ") else line.replace("---", "+++", 1))
        elif line.startswith("+++"):
            reversed_lines.append("--- " + line[4:] if line.startswith("+++ ") else line.replace("+++", "---", 1))
        elif line.startswith("-"):
            reversed_lines.append("+" + line[1:])
        elif line.startswith("+"):
            reversed_lines.append("-" + line[1:])
        else:
            reversed_lines.append(line)
    return "\n".join(reversed_lines) + ("\n" if diff.endswith("\n") else "")


@dataclass(frozen=True)
class ReplayStep:
    slug: str
    before: str
    after: str
    compile: str
    expect: str
    oracles: tuple[str, ...]


_HUNK_HEADER = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")


def _parse_hunks(diff: str) -> list[tuple[int, int, int, list[str]]]:
    lines = diff.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    hunks: list[tuple[int, int, int, list[str]]] = []
    idx = 0
    while idx < len(lines):
        line = lines[idx]
        if line.startswith("---") or line.startswith("+++") or line == "":
            idx += 1
            continue
        match = _HUNK_HEADER.match(line)
        if match is None:
            raise ReloadHistoryError("bad_hunk_header", f"expected @@ hunk, found {line!r}")
        old_start = int(match.group(1))
        old_count = int(match.group(2) or "1")
        new_count = int(match.group(4) or "1")
        idx += 1
        hunk_lines: list[str] = []
        while idx < len(lines) and not lines[idx].startswith("@@") and not lines[idx].startswith("---"):
            hunk_lines.append(lines[idx])
            idx += 1
        while hunk_lines and hunk_lines[-1] == "":
            hunk_lines.pop()
        hunks.append((old_start, old_count, new_count, hunk_lines))
    return hunks
