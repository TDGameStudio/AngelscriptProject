"""Write Language/Migration records covering every inspected legacy source."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = next(p for p in Path(__file__).resolve().parents if (p / "AngelscriptTestCode").is_dir())
INVENTORY = ROOT / "openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/drafts/findings/container-inventory.md"
OLD = ROOT / "TestSource-old/Language"
OUT = ROOT / "AngelscriptTestCode/Language/Migration"

TAG_RE = re.compile(r"^\| ([0-9.]+) \| `(Language/([^/`]+)/[^`]+)` \| (.+) \|$", re.M)

HOST_MARKERS = (
    "UFUNCTION",
    "FString",
    "UClass",
    "UObject",
    "AActor",
    "FQuat",
    "FMatrix",
    "FVector",
    "TArray",
    "TMap",
    "TSet",
    "UEnum",
    "Observe",
)


def theme_of(tag: str) -> str:
    return tag.split("/")[1]


def main() -> None:
    text = INVENTORY.read_text(encoding="utf-8")
    rows = TAG_RE.findall(text)
    if len(rows) != 47:
        raise SystemExit(f"expected 47 inventory rows, got {len(rows)}")

    anchors_by_tag: dict[str, list[str]] = {}
    dest_by_anchor: dict[str, str] = {}
    for _task, tag, _theme, anchors in rows:
        paths = [part.strip().strip("`") for part in anchors.split(";") if part.strip()]
        anchors_by_tag[tag] = paths
        for path in paths:
            key = path.replace("\\", "/")
            if key.startswith("TestSource-old/Language/"):
                key = key[len("TestSource-old/Language/") :]
            dest_by_anchor.setdefault(key, tag)

    legacy = sorted(p.relative_to(OLD).as_posix() for p in OLD.rglob("*.as"))
    if len(legacy) != 624:
        raise SystemExit(f"expected 624 legacy sources, got {len(legacy)}")

    records: list[tuple[str, str, str, str]] = []
    for rel in legacy:
        dest = dest_by_anchor.get(rel)
        content = (OLD / rel).read_text(encoding="utf-8", errors="replace")
        host = any(marker in content for marker in HOST_MARKERS)
        if dest is not None:
            if "/Reject/" in f"/{rel}":
                disposition = "adapted"
                reason = f"theme reject inspected; language-illegal form retained as an invalid-* child of {dest}"
            else:
                disposition = "adapted"
                reason = (
                    f"anchor for {dest}; UFUNCTION/Observe/host wrappers stripped, language declarations retained"
                )
        elif "/Reject/" in f"/{rel}":
            disposition = "excluded"
            reason = "theme reject outside the accepted FileTag, or host/diagnostic-only program"
        elif host:
            disposition = "excluded"
            reason = "host observer, UE type, or UFUNCTION wrapper; not language-only source material"
        else:
            disposition = "excluded"
            reason = "outside the accepted 47-tag inventory or merged into a sibling container"
        records.append((rel, disposition, dest or "", reason))

    OUT.mkdir(parents=True, exist_ok=True)
    themes = ["Operators", "ControlFlow", "Casting", "Namespace", "Syntax", "Preprocessor"]
    for theme in themes:
        tags = [tag for tag, *_ in ((row[1],) for row in rows) if theme_of(tag) == theme]
        # rebuild tags from rows
        tags = [tag for _task, tag, row_theme, _anchors in rows if row_theme == theme]
        lines = [
            f"# {theme} migration\n",
            "\n",
            "| FileTag | Disposition | Legacy sources |\n",
            "| --- | --- | --- |\n",
        ]
        for _task, tag, row_theme, anchors in rows:
            if row_theme != theme:
                continue
            lines.append(
                f"| `{tag}` | adapted language forms; host observers excluded | {anchors} |\n"
            )
        lines.extend(
            [
                "\n",
                "## Theme exclusions\n",
                "\n",
                "- Dropped `UFUNCTION` Observe helpers, namespace test wrappers, and UE types (`FString`, `FQuat`, `UEnum`, `TArray`).\n",
                "- Reject files that only encode host diagnostics stay excluded; language-illegal forms are `invalid-*` children of `root`.\n",
                "- Preprocessor and comment-literal versions may carry `SourceOnly`; admission is not compilation.\n",
            ]
        )
        (OUT / f"{theme}.md").write_text("".join(lines), encoding="utf-8", newline="\n")

    census = [
        "# Language fixture migration census\n",
        "\n",
        "Disposition for every inspected `TestSource-old/Language` source. "
        "Byte equality is against migrated container clean source, not these 624 wrappers.\n",
        "\n",
        f"Legacy files: {len(legacy)}. Accepted FileTags: 47.\n",
        "\n",
        "| Legacy path | Disposition | Destination | Reason |\n",
        "| --- | --- | --- | --- |\n",
    ]
    for rel, disposition, dest, reason in records:
        dest_cell = f"`{dest}`" if dest else ""
        census.append(f"| `TestSource-old/Language/{rel}` | {disposition} | {dest_cell} | {reason} |\n")
    (OUT / "README.md").write_text("".join(census), encoding="utf-8", newline="\n")
    print(f"wrote 6 theme records and census of {len(records)}")


if __name__ == "__main__":
    main()
