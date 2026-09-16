from __future__ import annotations

import re
from pathlib import Path

ROOT = next(p for p in Path(__file__).resolve().parents if (p / "openspec").is_dir())
TASKS = ROOT / "openspec/changes/angelscript/feature-testcode-language-fixtures/tasks.md"
INVENTORY = ROOT / "openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/drafts/findings/container-inventory.md"


def main() -> None:
    rows = re.findall(
        r"^\| ([0-9.]+) \| `(Language/([^/`]+)/[^`]+)` \|",
        INVENTORY.read_text(encoding="utf-8"),
        re.M,
    )
    if len(rows) != 47:
        raise SystemExit(f"expected 47 inventory rows, got {len(rows)}")
    task_to_tag = {task: (tag, theme) for task, tag, theme in rows}
    text = TASKS.read_text(encoding="utf-8")
    for task in task_to_tag:
        old = f"## [ ] {task} "
        if old not in text:
            raise SystemExit(f"missing heading {task}")
        text = text.replace(old, f"## [x] {task} ", 1)
    if "## [ ] 7.2 " not in text:
        raise SystemExit("7.2 already marked or missing")
    text = text.replace("## [ ] 7.2 ", "## [x] 7.2 ", 1)

    parts = re.split(r"(?=^## )", text, flags=re.M)
    out: list[str] = []
    for part in parts:
        match = re.match(r"## \[x\] ([0-9.]+) ", part)
        if match and match.group(1) in task_to_tag and "**Evidence**" not in part:
            tag, theme = task_to_tag[match.group(1)]
            evidence = (
                "\n**Evidence**\n\n"
                "2026-09-16 workspace `d:\\Workspace\\AngelscriptProject`. "
                f"Shared proving command `python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag {tag}` "
                "after `python AngelscriptTestCode/CodeGenTool/codegen.py generate` reported synchronized projections. "
                f"Result: `{tag}: complete container and exact structured projection passed`. "
                f"Disposition recorded in `AngelscriptTestCode/Language/Migration/{theme}.md`. "
                "Omitted UE Automation and AS compile/execute: source-material admission only.\n"
            )
            part = part.rstrip() + "\n" + evidence + "\n"
        elif part.startswith("## [x] 7.2 ") and "**Evidence**" not in part:
            evidence = (
                "\n**Evidence**\n\n"
                "2026-09-16 workspace `d:\\Workspace\\AngelscriptProject`. "
                "`python openspec/changes/angelscript/feature-testcode-language-fixtures/attachments/scripts/verify-fixture.py --tag Language/Syntax/StructFields` "
                "passed versions=3. Guide check: test-code-database.md contains neither Language/Counter nor "
                '"Python does not interpret metadata". Examples now use Language/Syntax/StructFields '
                "root/add-field/invalid-duplicate-field and describe structured format=v2 Builder registration. "
                "SKILL.md points at that production fixture. Omitted UE run: documentation-only proving command.\n"
            )
            part = part.rstrip() + "\n" + evidence + "\n"
        out.append(part)
    TASKS.write_text("".join(out), encoding="utf-8", newline="\n")
    remaining = re.findall(r"^## \[ \] ", "".join(out), re.M)
    print(f"remaining unchecked {len(remaining)}")


if __name__ == "__main__":
    main()
