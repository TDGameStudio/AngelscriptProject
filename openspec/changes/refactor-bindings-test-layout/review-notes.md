## Second Review Notes

Status: superseded by the full-directory audit in `file-audit.md`. This note is retained to show why the OpenSpec scope changed from a stale modified-file set to all C++ test files under `Plugins/Angelscript/Source/AngelscriptTest/Bindings`.

The previous pass proved that the Bindings prefix still executed (`285/285`), but it did not prove the refactor satisfied the unit-test layout and inline AS rules. The audit was too narrow because it focused on `R"AS(...)AS"` fixtures and missed legacy `TEXT(R"(... )"` fixtures.

### Confirmed Example: AssetRegistry

`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptAssetRegistryBindingsTests.cpp` still violates the refactor rules:

- Uses `const FString Script = TEXT(R"(` and `FString Script = TEXT(R"(` instead of `ASTEST_AS(R"AS(... )AS")`.
- Inline AS starts at column 0, for example `int VerifyTopLevelPathRoundTrip()` and `{`.
- Several AS `if` statements still use single-line bodies without braces.
- `TestRunner->AddExpectedError(...)` and `static const FName EngineMaterialsPath(...)` are not indented inside the `TEST_METHOD`.
- `AFTER_ALL()` is still one line instead of the standard multi-line lifecycle form.
- `ExpectGlobalInt(...)` calls in `QueryFilters` are invoked without consuming the returned boolean result.

### Legacy Raw-String Files In The Modified Set

The modified Bindings set still contains direct legacy inline AS sources in these files:

- `AngelscriptAssetRegistryBindingsTests.cpp`
- `AngelscriptClassBindingsTests.cpp`
- `AngelscriptCompatBindingsTests.cpp`
- `AngelscriptConsoleBindingsTests.cpp`
- `AngelscriptCoreMiscBindingsTests.cpp`
- `AngelscriptEngineBindingsTests.cpp`
- `AngelscriptEnhancedInputBindingsTests.cpp`
- `AngelscriptForeachBindingsTests.cpp`
- `AngelscriptGameInstanceLocalPlayerBindingsTests.cpp`
- `AngelscriptIntVectorBindingsTests.cpp`
- `AngelscriptMapBindingsTests.cpp`
- `AngelscriptObjectBindingsTests.cpp`
- `AngelscriptSetBindingsTests.cpp`
- `AngelscriptStringTableBindingsTests.cpp`
- `AngelscriptTArrayBindingsTests.cpp`
- `AngelscriptTArraySyntaxCompatBindingsTests.cpp`
- `AngelscriptUObjectBindingsTests.cpp`
- `AngelscriptWorldBindingsTests.cpp`

The full per-file matrix lives in `file-audit.md`; keep this note focused on the second-review root cause and examples.

### Ignored Expectation Result Files

The second review found ignored `ExpectGlobal*` results in modified files including:

- `AngelscriptAssetRegistryBindingsTests.cpp`
- `AngelscriptCompatBindingsTests.cpp`
- `AngelscriptCoreMiscBindingsTests.cpp`
- `AngelscriptEngineBindingsTests.cpp`
- `AngelscriptEnhancedInputBindingsTests.cpp`
- `AngelscriptFileAndDelegateBindingsTests.cpp`
- `AngelscriptIntVectorBindingsTests.cpp`
- `AngelscriptObjectBindingsTests.cpp`
- `AngelscriptPrimitiveComponentBindingsTests.cpp`
- `AngelscriptStringTableBindingsTests.cpp`
- `AngelscriptTimespanBindingsTests.cpp`

### Required Audit Scope

The final cleanup pass must audit all raw string variants in every Bindings `.cpp` and `.h` file:

```powershell
$files = Get-ChildItem Plugins\Angelscript\Source\AngelscriptTest\Bindings -Recurse -File |
    Where-Object { $_.Extension -in '.cpp', '.h' }
foreach ($file in $files) {
    $path = $file.FullName
    rg -n 'TEXT\(R"\(|TEXT\(R"AS\(|FString::Printf\(TEXT\(R"\(|=\s*R"\(' $path
}
```

Expected final result: no matches unless a line-sensitive test documents why raw layout is intentionally preserved.
