from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BINDINGS = ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Bindings"

REPLACEMENTS = [
    ('#include "AngelscriptBindingsAssertions.h"', '#include "AngelscriptTestExecute.h"'),
    ('#include "Shared/AngelscriptBindingsAssertions.h"', '#include "AngelscriptTestExecute.h"'),
    ('#include "AngelscriptBindingsModuleBuilder.h"', '#include "AngelscriptTestModuleScope.h"'),
    ('#include "Shared/AngelscriptBindingsModuleBuilder.h"', '#include "AngelscriptTestModuleScope.h"'),
    ('#include "AngelscriptGlobalFunctionInvoker.h"', '#include "AngelscriptTestExecute.h"'),
    ('#include "Shared/AngelscriptGlobalFunctionInvoker.h"', '#include "AngelscriptTestExecute.h"'),
]

MODULE_SCOPE_MARKER = '#include "AngelscriptTestModuleScope.h"'

FCOVERAGE_REPLACEMENTS = [
    ("FCoverageModuleScope", "FScopedAngelscriptModule"),
]


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    original = text
    for old, new in REPLACEMENTS:
        if old in text and new not in text:
            text = text.replace(old, new)
    if '#include "AngelscriptTestExecute.h"' in text and MODULE_SCOPE_MARKER not in text:
        if "FScopedAngelscriptModule" in text or "ExpectGlobal" in text or "ExecuteAndExpect" in text:
            text = text.replace(
                '#include "AngelscriptTestExecute.h"',
                '#include "AngelscriptTestExecute.h"\n#include "AngelscriptTestModuleScope.h"',
                1,
            )
    for old, new in FCOVERAGE_REPLACEMENTS:
        text = text.replace(old, new)
    if text != original:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
        return True
    return False


def main() -> None:
    changed = 0
    for path in BINDINGS.rglob("*"):
        if path.suffix.lower() not in {".cpp", ".h"}:
            continue
        if process_file(path):
            changed += 1
            print(path.relative_to(ROOT))
    template = ROOT / "Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp"
    if template.exists() and process_file(template):
        changed += 1
        print(template.relative_to(ROOT))
    print(f"updated {changed} files")


if __name__ == "__main__":
    main()
