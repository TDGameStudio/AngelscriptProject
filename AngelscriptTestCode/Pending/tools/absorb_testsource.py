"""Absorb TestSource-old cases into Pending v1 containers. Run from repo root.

Default leaves existing Pending files in place. Pass --wipe to delete previously
absorbed files (hand-authored Language Class/Inheritance/Destructors/Typedef/Properties stay).
"""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path

REPO = next(p for p in Path(__file__).resolve().parents if (p / "AngelscriptTestCode").is_dir())
OLD = REPO / "TestSource-old"
PENDING = REPO / "AngelscriptTestCode" / "Pending"
LANG_CENSUS = REPO / "AngelscriptTestCode" / "Language" / "Migration" / "README.md"

# Positive-harness folder only. Reject / UClass / Advance / Exception stay in the path.
DROP_FOLDERS = {"function"}
HAND_PREFIXES = (
    "Language/Class/",
    "Language/Inheritance/",
    "Language/Destructors/",
    "Language/Typedef/",
    "Language/Properties/",
    "Language/Mixin/",
    "Language/Auto/",
    "Language/Const/",
    "Language/Syntax/Function/",
)
FILE_META_MARKERS = ("@Theme", "@Harness", "@Tag", "@Subject", "@Provenance", "@Namespace")
PROLOGUE_PREFIXES = (
    "// purpose:",
    "// theme:",
    "// c++:",
    "// retained:",
    "// replaced",
    "// oracle:",
    "// fixture",
    "// as-facing",
    "// inputs:",
    "// expected",
    "// boundary",
    "// sha256",
    "// extra:",
    "// defaultsafe",
    "// source owns",
)


def kebab(text: str) -> str:
    step = re.sub(r"([a-z0-9])([A-Z])", r"\1-\2", text)
    step = re.sub(r"[^A-Za-z0-9]+", "-", step)
    return step.strip("-").lower() or "case"


def one_line(text: str, limit: int = 220) -> str:
    collapsed = re.sub(r"\s+", " ", text).strip()
    if len(collapsed) <= limit:
        return collapsed
    cut = collapsed[: limit + 1].rsplit(" ", 1)[0]
    return cut.rstrip(".,;:") + "."


def adapted_language_paths() -> set[str]:
    paths: set[str] = set()
    if not LANG_CENSUS.is_file():
        return paths
    for line in LANG_CENSUS.read_text(encoding="utf-8").splitlines():
        if "| adapted |" not in line:
            continue
        match = re.search(r"`(TestSource-old/Language/[^`]+)`", line)
        if match:
            paths.add(match.group(1).replace("\\", "/"))
    return paths


def is_hand_authored(relative: str) -> bool:
    posix = relative.replace("\\", "/")
    return any(posix.startswith(prefix) for prefix in HAND_PREFIXES)


def strip_file_prologue(text: str) -> tuple[str, str]:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    if text.startswith("\ufeff"):
        text = text[1:]
    summary = ""
    while text.startswith("/**"):
        end = text.find("*/")
        if end < 0:
            break
        block = text[: end + 2]
        if any(marker in block for marker in FILE_META_MARKERS):
            if not summary:
                body = re.sub(r"^\s*\*\s?", "", block[3:-2], flags=re.M)
                prose: list[str] = []
                for line in body.splitlines():
                    stripped = line.strip()
                    if not stripped:
                        if prose:
                            break
                        continue
                    if stripped.startswith("@"):
                        break
                    prose.append(stripped)
                summary = one_line(" ".join(prose))
            text = text[end + 2 :].lstrip("\n")
            continue
        break
    purpose_lines: list[str] = []
    while True:
        stripped = text.lstrip()
        if not stripped.startswith("//"):
            break
        line, _, rest = stripped.partition("\n")
        lowered = line.lower()
        if any(lowered.startswith(prefix) for prefix in PROLOGUE_PREFIXES):
            value = line.split(":", 1)[1].strip() if ":" in line else ""
            if lowered.startswith("// purpose:"):
                purpose_lines.append(value)
            elif lowered.startswith("// theme:") and not purpose_lines:
                purpose_lines.append(value)
            elif lowered.startswith("// oracle:") and not purpose_lines:
                purpose_lines.append(value)
            text = rest
            continue
        if (
            purpose_lines
            and line.startswith("// ")
            and not purpose_lines[-1].endswith((".", "!", "?"))
        ):
            purpose_lines.append(line[3:].strip())
            text = rest
            continue
        break
    if not summary and purpose_lines:
        summary = one_line(" ".join(purpose_lines))
    return text.strip() + "\n", summary


def binding_leaf(name: str) -> str:
    if name.startswith("Test_"):
        name = name[5:]
    return name


def is_hotreload_pair_leaf(leaf: str) -> bool:
    return leaf in {"Before", "After"} or bool(re.fullmatch(r"Version_\d+", leaf))


def destination_for(relative: str) -> tuple[str, str, str]:
    posix = relative.replace("\\", "/")
    parts = Path(posix).with_suffix("").parts
    theme = parts[0]
    leaf = parts[-1]
    mid = [part for part in parts[1:-1] if part.casefold() not in DROP_FOLDERS]
    harness = "reject" if any(part.casefold() == "reject" for part in parts) else "function"
    if theme == "Bindings":
        leaf = binding_leaf(leaf)
    if theme == "HotReload" and is_hotreload_pair_leaf(leaf):
        dest = "/".join([theme, *mid]) if mid else f"{theme}/{leaf}"
        return dest, leaf, harness
    dest = "/".join([theme, *mid, leaf])
    return dest, leaf, harness


def wrap_container(summary: str, topics: list[str], versions: list[tuple[str, str, list[str], str]]) -> str:
    lines = ["/**\n", " * @version v1\n", f" * @summary {summary}\n"]
    for topic in topics:
        lines.append(f" * @topic {topic}\n")
    lines.append(" */\n")
    for tag, version_summary, version_topics, body in versions:
        lines.append("/**\n")
        lines.append(f" * @version {tag}\n")
        if tag != "root":
            lines.append(" * @parent root\n")
        lines.append(f" * @summary {version_summary}\n")
        for topic in version_topics:
            lines.append(f" * @topic {topic}\n")
        lines.append(" */\n")
        if not body.endswith("\n"):
            body += "\n"
        lines.append(body)
        lines.append("/** @end */\n")
    return "".join(lines)


def version_order(item: tuple[str, str, str, str, str]) -> tuple[int, str]:
    leaf = item[1]
    if leaf == "Before" or leaf == "Version_01":
        return (0, leaf)
    if re.fullmatch(r"Version_\d+", leaf):
        return (1, leaf)
    if leaf == "After":
        return (2, leaf)
    return (3, item[0])


def absorb_destinations() -> set[str]:
    adapted = adapted_language_paths()
    dests: set[str] = set()
    for path in OLD.rglob("*.as"):
        relative = path.relative_to(OLD).as_posix()
        if f"TestSource-old/{relative}" in adapted:
            continue
        dest, _leaf, _harness = destination_for(relative)
        dests.add(f"{dest}.as")
    return dests


def wipe_absorbed() -> int:
    dests = absorb_destinations()
    removed = 0
    for path in PENDING.rglob("*.as"):
        relative = path.relative_to(PENDING).as_posix()
        if is_hand_authored(relative) or relative not in dests:
            continue
        path.unlink()
        removed += 1
        parent = path.parent
        while parent != PENDING and parent.is_dir() and not any(parent.iterdir()):
            parent.rmdir()
            parent = parent.parent
    return removed


def main() -> None:
    removed = wipe_absorbed() if "--wipe" in sys.argv else 0
    adapted = adapted_language_paths()
    existing = {path.relative_to(PENDING).as_posix() for path in PENDING.rglob("*.as")}
    grouped: dict[str, list[tuple[str, str, str, str, str]]] = defaultdict(list)
    skipped_adapted = 0
    empty = 0
    legacy_by_theme: dict[str, int] = defaultdict(int)
    adapted_by_theme: dict[str, int] = defaultdict(int)

    for path in sorted(OLD.rglob("*.as")):
        relative = path.relative_to(OLD).as_posix()
        theme = relative.split("/", 1)[0]
        legacy_by_theme[theme] += 1
        census_key = f"TestSource-old/{relative}"
        if census_key in adapted:
            skipped_adapted += 1
            adapted_by_theme[theme] += 1
            continue
        raw = path.read_text(encoding="utf-8")
        body, summary = strip_file_prologue(raw)
        if not body.strip():
            empty += 1
            continue
        dest, leaf, harness = destination_for(relative)
        grouped[dest].append((relative, leaf, harness, summary, body))

    written = 0
    collisions = 0
    theme_written: dict[str, int] = defaultdict(int)
    merge_rows: list[str] = []

    for dest, items in sorted(grouped.items()):
        out_rel = f"{dest}.as"
        if out_rel in existing:
            collisions += 1
            continue

        theme = dest.split("/", 1)[0]
        items_sorted = sorted(items, key=version_order)
        if len(items_sorted) > 1 and theme != "HotReload":
            raise SystemExit(
                f"non-HotReload destination collision: {out_rel} <- "
                + ", ".join(item[0] for item in items_sorted)
            )

        first_summary = next((item[3] for item in items_sorted if item[3]), "")
        file_summary = first_summary or dest.replace("/", " ")
        versions: list[tuple[str, str, list[str], str]] = []

        if len(items_sorted) == 1:
            _relative, _leaf, harness, summary, body = items_sorted[0]
            topics = ["Negative"] if harness == "reject" else ["Baseline"]
            versions.append(("root", summary or file_summary, topics, body))
        else:
            for index, (_relative, leaf, harness, summary, body) in enumerate(items_sorted):
                if index == 0:
                    tag = "root"
                    topics = ["Baseline"]
                elif leaf == "After":
                    tag = "after"
                    topics = [theme]
                elif re.fullmatch(r"Version_\d+", leaf):
                    tag = kebab(leaf)
                    topics = [theme]
                else:
                    tag = kebab(leaf)
                    topics = ["Negative"] if harness == "reject" else [theme]
                versions.append((tag, summary or leaf, topics, body))
            merge_rows.append(
                f"| `{out_rel}` | {len(items_sorted)} | "
                + ", ".join(f"`{item[0]}`" for item in items_sorted)
                + " |"
            )

        text = wrap_container(file_summary, [theme], versions)
        output = PENDING / Path(out_rel)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(text, encoding="utf-8", newline="\n")
        written += 1
        theme_written[theme] += 1

    theme_lines = [
        "| Theme | Legacy .as | Adapted skipped | Pending containers |",
        "| --- | ---: | ---: | ---: |",
    ]
    for theme in sorted(legacy_by_theme):
        theme_lines.append(
            f"| `{theme}` | {legacy_by_theme[theme]} | {adapted_by_theme.get(theme, 0)} | "
            f"{theme_written.get(theme, 0)} |"
        )
    theme_lines.append(
        f"| **total** | **{sum(legacy_by_theme.values())}** | **{skipped_adapted}** | **{written}** |"
    )

    merge_block = (
        "\n".join(merge_rows)
        if merge_rows
        else "_None._"
    )
    census = PENDING / "CENSUS.md"
    census.write_text(
        "# TestSource-old absorption census\n\n"
        f"Hand-authored Pending files left untouched. Wiped previous absorb: {removed} files. "
        f"Empty after prologue strip: {empty}. Name collisions with hand files: {collisions}.\n\n"
        "One legacy file becomes one Pending container, except HotReload `Before`/`After`/"
        "`Version_N` of the same scenario, which share one file as version tags.\n\n"
        + "\n".join(theme_lines)
        + "\n\n## HotReload merges\n\n"
        "| Destination | Sources | Legacy paths |\n"
        "| --- | ---: | --- |\n"
        + merge_block
        + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(
        f"wiped={removed} written={written} skipped_adapted={skipped_adapted} "
        f"empty={empty} existing={collisions} merges={len(merge_rows)}"
    )


if __name__ == "__main__":
    main()
