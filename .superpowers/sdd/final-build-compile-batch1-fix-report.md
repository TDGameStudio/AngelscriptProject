# Final build compile-error batch 1 fix report

Status: `DONE`

## Authoritative red evidence

Reviewed:

`Saved/Build/as-native-sdk-comprehensive-final-source/20260727_195709_089_a7ccc448/Build.log`

The log contains exactly nine compiler errors across four source files:

- four cascading declaration/call errors in
  `AngelscriptNativeOverloadedDuplicateDeclarationTests.cpp`;
- one unresolved `ASTEST_AS_ANSI` error in
  `AngelscriptNativeScriptObjectTests.cpp`;
- two unresolved `ASTEST_AS_ANSI` errors in
  `AngelscriptNativeEngineGcCleanupServiceTests.cpp`;
- two unresolved language-case helper errors in
  `AngelscriptNativeFunctionParameterDirectionTests.cpp`.

No build was run during this repair. The retained log is the red
reproduction/evidence source.

## Root-cause hypotheses and evidence

### Generated declaration typo

Line 414 contained:

```cpp
const EOperandFormAvailableOperand =
```

The missing separator merged the type and variable name. That directly
explains the missing type specifier, invalid enum-to-int initialization,
unknown `AvailableOperand`, and resulting wrong `AppendOperatorMethod`
argument-list errors.

### Missing direct macro declarations

The Runtime and Engine owners use `ASTEST_AS_ANSI` but did not include
`AngelscriptTestMacros.h`. Working raw-SDK owners include that header
directly. The macro is declared in
`AngelscriptTest/Shared/AngelscriptTestMacros.h`; relying on unrelated
transitive includes does not provide a stable declaration contract.

### Missing language-case support declarations

The Function Parameter Direction owner calls
`RegisterCoreLanguageTypedef` and `PrintGeneratedAsSource`. Both declarations
are supplied by `AngelscriptNativeLanguageCaseTestSupport.h`, while the owner
omitted that support include. The neighboring Parameter Position owner uses
the direct include.

## Changes

Only four minimal edits were made:

1. Changed the merged declaration to:

   ```cpp
   const EOperandForm AvailableOperand =
   ```

2. Added direct `#include "AngelscriptTestMacros.h"` to:

   - `Runtime/AngelscriptNativeScriptObjectTests.cpp`;
   - `Engine/AngelscriptNativeEngineGcCleanupServiceTests.cpp`.

3. Added:

   ```cpp
   #include "../../Support/AngelscriptNativeLanguageCaseTestSupport.h"
   ```

   to
   `Language/Functions/AngelscriptNativeFunctionParameterDirectionTests.cpp`.

No behavior, assertion, product, case ID, generated AngelScript source, or
test flow was changed.

## Focused checks

The read-only declaration/include guard verified:

- exactly one corrected typed `AvailableOperand` declaration;
- zero remaining merged declaration occurrences;
- exactly one direct macro include in each affected Runtime/Engine owner;
- exactly one direct language-case support include in the Function owner;
- `ASTEST_AS_ANSI` exists in the resolved macro header;
- `RegisterCoreLanguageTypedef` and `PrintGeneratedAsSource` exist in the
  resolved language-case support header;
- zero trailing whitespace in all four files;
- final newline in all four files.

Result:

`FOCUSED_DECL_INCLUDE_PASS declaration=1 macroIncludes=2
languageSupportInclude=1 declarationsResolved=3 whitespace=0 eof=4`

`git diff --check` reported no whitespace error. Git emitted one advisory that
the Runtime file may be converted from LF to CRLF if Git rewrites it; the
current file remains LF and the focused byte check passed.

The exact scoped diff was inspected. The shared workspace already contains
larger pre-existing edits in some of these files; this repair adds only the
one declaration correction and three include lines described above.

## Rejected/failed commands and corrections

The first focused declaration guard looked for
`AngelscriptTestMacros.h` under `AngelscriptTest/` instead of its real
`AngelscriptTest/Shared/` path and stopped with `FileNotFoundError`. No file
was changed and the partial result was not accepted. `rg --files` resolved the
actual header, after which the complete declaration/include/whitespace/EOF
guard was rerun and passed.

No other command failed or required correction.

## Execution boundary

- No build was run.
- No UE Automation test was run.
- No OpenSpec artifact was edited.
- No commit was created.
- No unrelated file was edited.
