# AS Inline Code Formatting Rule

## Scope

This rule governs the formatting of **AngelScript code embedded in C++ test files** via raw string literals. It applies to all files under:

- `Plugins/Angelscript/Source/AngelscriptTest/`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
- `Plugins/Angelscript/Source/AngelscriptEditor/Tests/`

Any new or modified inline AS code must conform to this rule.

## Rule Summary

| Aspect | Requirement |
|--------|-------------|
| Wrapper | Use `ASTEST_AS(...)` for `FString` / `TCHAR` test helpers and `ASTEST_AS_ANSI(...)` for ASSDK / `const char*` test helpers |
| String delimiter | Prefer `R"AS(...)AS"` for all inline AS snippets; this makes the embedded language obvious and avoids delimiter conflicts with UE-style macros |
| Visual column origin | Inline AS content must follow the surrounding C++ indentation and must not start at column 0 |
| Closing delimiter | The closing raw-string delimiter line, such as `)AS");`, must also follow the surrounding C++ indentation and must not start at column 0 |
| Source normalization | The wrapper must trim the raw-string envelope and dedent common visual indentation before the source reaches the AS compiler |
| Comments | Use C++ comments to explain the test role of the snippet; use AS comments when they are part of the script behavior, diagnostics, markers, or feature documentation |
| Variable naming | Use `ScriptSource` only when a test has one obvious snippet; use scenario-specific names when a test has multiple snippets |
| Indentation | Preserve relative AS indentation inside the snippet; use the same indentation unit as the surrounding test file |
| Brace style | Allman: opening braces appear on their own line, including single-line function bodies |
| Function spacing | One blank line between every function or method |
| Property spacing | One blank line after each `UPROPERTY()` + declaration pair |
| Class spacing | One blank line between multiple `UCLASS` definitions |
| ASSDK tests | Must use raw string literals, not `"\n"` string concatenation |

## Detailed Rules

### 1. Wrapper and Raw String Delimiter

- Inline AS source must be wrapped in a dedenting helper:
  ```cpp
  const FString ScriptSource = ASTEST_AS(R"AS(
        ...
        )AS");
  ```

- ASSDK-layer tests and raw SDK helpers that require `const char*` should use the ANSI helper:
  ```cpp
  const std::string Source = ASTEST_AS_ANSI(R"AS(
        ...
        )AS");
  ```

- Prefer `R"AS(...)AS"` even for global functions. The `AS` delimiter improves scanability and avoids conflicts with `)` inside AS source.

- Do not pass a visually indented raw string directly to an AS compiler helper unless it has first gone through the dedenting wrapper. Without the wrapper, C++ indentation becomes part of the actual AS source and can shift diagnostic columns.

### 2. Visual Column Origin

AS snippets are embedded code blocks inside C++ tests. They should look embedded, not like a separate file pasted at the far left of the C++ file.

Required layout:

```cpp
// Inline AS source is visually indented with the surrounding C++ test.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class AInlineFormattingActor : AActor
        {
                UPROPERTY()
                int Value = 40;

                UFUNCTION()
                int AddTwo()
                {
                        return Value + 2;
                }
        }
        )AS");
```

Rules:

- The first AS source line after `R"AS(` must be indented relative to the C++ statement.
- The closing delimiter line, such as `)AS");`, must use the same visual outer indentation as the AS block.
- Neither AS content nor the closing delimiter may start at column 0.
- The raw-string opening line may follow normal C++ wrapping rules.

### 3. Comment Placement

Use comments to make embedded AS blocks easy to scan, but keep the comments at the right layer:

- Prefer a short C++ comment before the source variable explaining the test role of the AS snippet.
- AS comments are allowed and expected when they are part of the tested script behavior, markers, preprocessor behavior, expected diagnostics, or meaningful script-side feature documentation.
- Do not add decorative comments inside AS source merely to label the raw string block; that belongs in the surrounding C++ comment.
- For long tests with multiple snippets, name each source variable after the scenario, such as `ValidActorSource`, `BrokenSyntaxSource`, or `ReloadV2Source`.

Preferred:

```cpp
// Script under test: actor exposes one UFUNCTION used by the reflection assertion.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class AReflectionProbeActor : AActor
        {
                UFUNCTION()
                int AddTwo()
                {
                        return 40 + 2;
                }
        }
        )AS");
```

AS-side comments are appropriate when they are part of the feature under test:

```cpp
// Script under test: comment metadata should remain attached to the generated function.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class ACommentMetadataActor : AActor
        {
                // Function comment intentionally lives in AS; the test inspects generated docs.
                UFUNCTION()
                int AddTwo()
                {
                        return 40 + 2;
                }
        }
        )AS");
```

Avoid AS comments that only duplicate the C++ label:

```cpp
const FString ScriptSource = ASTEST_AS(R"AS(
        // Script under test: actor exposes one UFUNCTION used by the reflection assertion.
        UCLASS()
        class AReflectionProbeActor : AActor
        {
                UFUNCTION()
                int AddTwo()
                {
                        return 40 + 2;
                }
        }
        )AS");
```

### 4. Variable Naming

The source variable name should identify the AS snippet's role in the test:

- `ScriptSource` is acceptable only when the test has one obvious AS snippet.
- Use scenario-specific names when a test has multiple snippets, such as `ValidActorSource`, `BrokenSyntaxSource`, `ReloadV1Source`, `ReloadV2Source`, `HelperSectionSource`, or `EntrySectionSource`.
- Use the `Source` suffix for `FString` snippets and `AnsiSource` only when both `FString` and `std::string` variants exist in the same scope.
- Avoid generic names like `Source1`, `Source2`, `Text`, or `Script` when the test has more than one script block.

Single-snippet test:

```cpp
// Script under test: actor exposes one UFUNCTION used by the reflection assertion.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class AReflectionProbeActor : AActor
        {
                UFUNCTION()
                int AddTwo()
                {
                        return 40 + 2;
                }
        }
        )AS");
```

Multi-snippet test:

```cpp
// Script under test: first hot-reload version exposes the original return value.
const FString ReloadV1Source = ASTEST_AS(R"AS(
        UCLASS()
        class AHotReloadProbeActor : AActor
        {
                UFUNCTION()
                int GetValue()
                {
                        return 1;
                }
        }
        )AS");

// Script under test: second hot-reload version changes the return value.
const FString ReloadV2Source = ASTEST_AS(R"AS(
        UCLASS()
        class AHotReloadProbeActor : AActor
        {
                UFUNCTION()
                int GetValue()
                {
                        return 2;
                }
        }
        )AS");
```

### 5. Source Normalization Contract

`ASTEST_AS(...)` and `ASTEST_AS_ANSI(...)` must produce compiler input as if the AS source had been written without the surrounding C++ visual indentation.

The wrapper must:

- Remove the single leading blank line created by the raw-string opening.
- Remove the trailing whitespace-only line created by indenting the closing raw-string delimiter.
- Dedent the minimum common indentation across non-empty AS lines.
- Preserve relative indentation inside the AS code.
- Preserve intentional blank lines inside the AS block.

For the required layout above, the AS compiler should receive:

```angelscript
UCLASS()
class AInlineFormattingActor : AActor
{
        UPROPERTY()
        int Value = 40;

        UFUNCTION()
        int AddTwo()
        {
                return Value + 2;
        }
}
```

### 6. Indentation Inside AS

- Keep AS indentation visually consistent inside the snippet.
- Class members, property declarations, method signatures, `UPROPERTY()` and `UFUNCTION()` macros are indented one level inside the class.
- Method body code is indented one additional level inside the method.
- Nested control-flow blocks add one indentation level per nesting level.
- Do not mix whitespace styles inside a single AS snippet.

### 7. Brace Style

The opening brace `{` always appears on its own line, aligned with the owning statement. No K&R single-line exceptions.

Wrong:

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Add() { return 2 + 3; }
        )AS");
```

Correct:

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Add()
        {
                return 2 + 3;
        }
        )AS");
```

### 8. Blank Line Rules

- Between functions or member methods: one blank line.
- Between `UPROPERTY()` groups: one blank line after the declaration.
- Between a `UFUNCTION()` method and the next `UFUNCTION()`: one blank line after the closing `}`.
- Between multiple `UCLASS` definitions: one blank line between the closing `}` of one class and the next `UCLASS()`.

### 9. Opening and Closing Lines

- The opening delimiter line ends immediately after `R"AS(`.
- AS content starts on the next line.
- The closing delimiter occupies its own line.
- The closing delimiter is visually indented with the AS block and is removed from compiler input by the wrapper normalization.

## Correct Examples

### UCLASS Script

```cpp
// Script under test: lifecycle callbacks update counters read by the C++ assertion.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class AMyTestActor : AActor
        {
                UPROPERTY()
                int EventCount = 0;

                UPROPERTY()
                float TotalTime = 0.f;

                UFUNCTION(BlueprintOverride)
                void BeginPlay()
                {
                        EventCount += 1;
                }

                UFUNCTION(BlueprintOverride)
                void Tick(float DeltaTime)
                {
                        TotalTime += DeltaTime;
                }
        }
        )AS");
```

### Global Functions

```cpp
// Script under test: global functions exercise return values and string binding.
const FString ScriptSource = ASTEST_AS(R"AS(
        int Add(int A, int B)
        {
                return A + B;
        }

        int Multiply(int A, int B)
        {
                return A * B;
        }

        FString BuildGreeting(const FString& in Name)
        {
                return "Hello, " + Name + "!";
        }
        )AS");
```

### ASSDK / Raw SDK Source

```cpp
// Script under test: raw SDK builder should register one const global and one function.
const std::string BuilderFunctionsSource = ASTEST_AS_ANSI(R"AS(
        const int Base = 40;

        int AddTwo()
        {
                return Base + 2;
        }
        )AS");

if (!AddBuilderSection(*TestRunner, *Module, "BuilderFunctions", BuilderFunctionsSource.c_str()))
{
        return;
}
```

### Multiple UCLASS Definitions

```cpp
// Script under test: derived AS class overrides a method from another AS class.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class ABaseActor : AActor
        {
                UFUNCTION()
                int GetValue()
                {
                        return 1;
                }
        }

        UCLASS()
        class ADerivedActor : ABaseActor
        {
                UFUNCTION()
                int GetValue()
                {
                        return 2;
                }
        }
        )AS");
```

### Nested Control Flow

```cpp
// Script under test: nested control flow updates a reflected property.
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class AComplexActor : AActor
        {
                UPROPERTY()
                int Result = 0;

                UFUNCTION(BlueprintOverride)
                void BeginPlay()
                {
                        for (int i = 0; i < 10; ++i)
                        {
                                if (i % 2 == 0)
                                {
                                        Result += i;
                                }
                        }
                }
        }
        )AS");
```

## Incorrect Examples

### Wrong: AS Code Starts at Column 0

```cpp
const FString ScriptSource = ASTEST_AS(R"AS(
UCLASS()
class AMyActor : AActor
{
}
        )AS");
```

Must be:

```cpp
const FString ScriptSource = ASTEST_AS(R"AS(
        UCLASS()
        class AMyActor : AActor
        {
        }
        )AS");
```

### Wrong: Closing Delimiter Starts at Column 0

```cpp
const FString ScriptSource = ASTEST_AS(R"AS(
        int Add()
        {
                return 42;
        }
)AS");
```

Must be:

```cpp
const FString ScriptSource = ASTEST_AS(R"AS(
        int Add()
        {
                return 42;
        }
        )AS");
```

### Wrong: Visually Indented Raw String Without Wrapper

```cpp
const FString ScriptSource = TEXT(R"AS(
        int Add()
        {
                return 42;
        }
        )AS");
```

Must use a dedenting wrapper:

```cpp
const FString ScriptSource = ASTEST_AS(R"AS(
        int Add()
        {
                return 42;
        }
        )AS");
```

### Wrong: Embedded Raw String Inside a Compound Guard

```cpp
if (!TestRunner->TestNotNull(TEXT("Module should exist"), Module) ||
        !AddBuilderSection(*TestRunner, *Module, "BuilderFunctions", ASTEST_AS_ANSI(R"AS(
        int Add()
        {
                return 42;
        }
        )AS").c_str()))
{
        return;
}
```

Prefer a named source variable and a separate guard:

```cpp
if (!TestRunner->TestNotNull(TEXT("Module should exist"), Module))
{
        return;
}

const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Add()
        {
                return 42;
        }
        )AS");

if (!AddBuilderSection(*TestRunner, *Module, "BuilderFunctions", Source.c_str()))
{
        return;
}
```

### Wrong: K&R Single-Line

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Add() { return 2 + 3; }
        )AS");
```

Must be:

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Add()
        {
                return 2 + 3;
        }
        )AS");
```

### Wrong: Missing Blank Line Between Functions

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Foo()
        {
                return 1;
        }
        int Bar()
        {
                return 2;
        }
        )AS");
```

Must be:

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Foo()
        {
                return 1;
        }

        int Bar()
        {
                return 2;
        }
        )AS");
```

### Wrong: `\n` String Concatenation (ASSDK Legacy)

```cpp
"int Multiply(int A, int B)  \n"
"{                           \n"
"  return A * B;             \n"
"}                           \n"
```

Must be migrated to raw string literal format with the ANSI wrapper:

```cpp
const std::string Source = ASTEST_AS_ANSI(R"AS(
        int Multiply(int A, int B)
        {
                return A * B;
        }
        )AS");
```

## Line and Column Sensitive Tests

Some tests intentionally verify raw source offsets, diagnostic rows / columns, debug markers, or `asCScriptCode::ConvertPosToRowCol` behavior. These tests still must not make the C++ file visually start AS code at column 0.

For those tests:

- Use an explicit preserve/raw helper when one is available, such as `ASTEST_AS_PRESERVE_LINES(...)` or `ASTEST_AS_ANSI_PRESERVE_LINES(...)`.
- Document in the test why exact source layout matters.
- Do not silently switch a line-sensitive test to the default dedenting wrapper without checking the expected line and column semantics.

## Enforcement

- This rule is enforced for all new and modified inline AS code.
- Existing code that does not conform should be updated when the containing `TEST_METHOD` or test case is modified for other reasons.
- AI agents must apply this rule automatically when generating or editing inline AS code in test files.
