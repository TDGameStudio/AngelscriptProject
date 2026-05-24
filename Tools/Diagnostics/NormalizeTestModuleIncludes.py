"""Drop Shared/ prefix from #includes under AngelscriptTest (requires Shared in Build.cs PrivateIncludePaths)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TEST_ROOT = ROOT / "Plugins/Angelscript/Source/AngelscriptTest"

PREFIX_REPLACEMENTS = [
    ('#include "Shared/', '#include "'),
]


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    original = text
    for old, new in PREFIX_REPLACEMENTS:
        text = text.replace(old, new)
    if text != original:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
        return True
    return False


def main() -> None:
    changed = 0
    for path in TEST_ROOT.rglob("*"):
        if path.suffix.lower() not in {".cpp", ".h"}:
            continue
        if process_file(path):
            changed += 1
            print(path.relative_to(ROOT))
    print(f"updated {changed} files")


if __name__ == "__main__":
    main()
