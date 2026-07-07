## Binding Test Refactor File Audit

Scope: all C++ test files under `Plugins/Angelscript/Source/AngelscriptTest/Bindings`.

- Files audited: `95`.
- `.cpp` files: `90`.
- `.h` files: `5`.
- Source files with implementation edits: `88` `.cpp` files plus `AngelscriptConsoleBindingsSections.h`.
- Runtime/editor files in scope: none.

The previous 39-file audit was superseded after review clarified that this change must cover the whole Bindings test directory, not only files modified in an earlier pass.

## Audit Result

| Audit | Result |
|---|---|
| Raw-string/source-variable audit | `issue_files=0` |
| Inline AS style audit | `issue_files=0` |
| AS control-flow brace audit | `issue_files=0` |
| Helper-result audit | `issue_files=0` |
| C++ `TEST_CLASS_WITH_FLAGS` column-zero audit | `issue_files=0` |
| C++ `TEST_METHOD` column-zero audit | `issue_files=0` |

## Checks Covered

- Direct raw AS strings outside `ASTEST_AS(...)` / `ASTEST_AS_ANSI(...)`.
- Generic inline AS source variables such as `Script`, `Source`, or `Text` when assigned directly from normalized AS source helpers.
- `FString::Printf(ASTEST_AS(...))` dynamic-source builders.
- Column-zero AS content or closing raw-string delimiters.
- K&R braces and single-line AS `if` / `for` / `while` bodies.
- AS control-flow statements whose next non-empty line is not `{`.
- Missing blank lines between AS functions/classes and missing spacing after `UPROPERTY()` declaration pairs.
- Ignored `ExpectGlobal*`, `Execute*`, collision parity, and math verification helper return values.
- Column-zero C++ statements inside `TEST_CLASS_WITH_FLAGS` / `TEST_METHOD` bodies.

## Current Notes

- The full-directory audit found no remaining normalized-wrapper or inline AS style exceptions.
- The helper-result audit found no remaining ignored helper returns in the full Bindings directory.
- `AngelscriptCollisionValueBindingsTests.cpp` is included in the implementation scope and now uses normalized inline AS fixtures and matcher-backed expectation consumption.
- `AngelscriptJsonObjectConverterBindingsTests.cpp` had one remaining AS control-flow brace violation in `Error_MalformedJsonRejected`; the final pass fixed it and reran the strengthened audit.
- `AngelscriptContainerBindingsTests.cpp` is the only unchanged `.cpp`; it is an empty deprecated migration placeholder with no test registration or inline AS fixture.
- The remaining unchanged headers are pure C++ test fixture/helper headers with no inline AS fixture to normalize: `AngelscriptDataTableBindingTestTypes.h`, `AngelscriptGameplayFunctionLibraryTestTypes.h`, `AngelscriptMathBindingsTestCompare.h`, and `AngelscriptWorldCollisionBindingsTestHelpers.h`. Stage 2 removed the obsolete `AngelscriptTArrayBindingsTestHelpers.h` after the TArray syntax-compat matrix was reduced to local contract smokes.
- The shared `AngelscriptConsoleBindingsSections.h` remains a header boundary because the console tests share section helpers across split Bindings test files.

## Audit Commands

These checks were run from the repository root over `Plugins/Angelscript/Source/AngelscriptTest/Bindings`:

```powershell
# Raw-string/source-variable audit
python - <<'PY'
from pathlib import Path
import re
root = Path('Plugins/Angelscript/Source/AngelscriptTest/Bindings')
files = sorted(p for p in root.rglob('*') if p.suffix in ('.cpp', '.h'))
raw_start = re.compile(r'R"[A-Za-z_]*\(')
normalized = re.compile(r'ASTEST_AS(?:_ANSI)?\s*\(\s*R"AS\(')
generic = re.compile(r'\b(?:const\s+)?(?:FString|std::string)\s+(Script|Source|Text)\s*=\s*(?:ASTEST_AS|ASTEST_AS_ANSI|ScriptTemplate|BuildLocTableScript)')
printf_astest = re.compile(r'FString::Printf\s*\(\s*ASTEST_AS')
rows = []
for path in files:
    lines = path.read_text(encoding='utf-8', errors='replace').splitlines()
    raw = [i for i, line in enumerate(lines, 1) if raw_start.search(line) and not normalized.search(line)]
    gen = [i for i, line in enumerate(lines, 1) if generic.search(line)]
    printf = [i for i, line in enumerate(lines, 1) if printf_astest.search(line)]
    if raw or gen or printf:
        rows.append(path)
print(f'issue_files={len(rows)}')
PY
```

The inline AS style, helper-result, and C++ class-body audits are recorded as repeatable Python scans in the working session and were rerun after the final source cleanup.
