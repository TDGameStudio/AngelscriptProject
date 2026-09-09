# Task 4.8 — FText and formatting verification

## Outcome

The detached Runtime binding path now records and installs the complete selected text family: `FText`, `FFormatArgumentValue`, `FNumberFormattingOptions`, and `FStringTableRegistry`. The installed surface retains 41 `FText.Functions`, 9 format-argument, 12 number-options, and 6 string-table contributions; the infrastructure provider intentionally contributes no member records.

Generic `FText::Format` declarations retain `const ?&` as a canonical Wildcard type use. Syntax parsing, qualifier identity, metadata signature admission, frozen identity reconstruction, and draft application all preserve the wildcard as `ttQuestion`. Metadata limits it to referenced function parameters.

The recording path avoids Engine queries while providers execute. Runtime-only `FText` type-info and ToString registry access remain deferred. Ordered/named formatting and wildcard conversion use an exported checked helper with an explicit invalid-type diagnostic. Culture-sensitive cases select `en` and restore the previous culture. The missing string-table case consumes the provider warning and proves the registry remains absent before and after lookup.

## Behavioral RED

- Run `171eeaab51d442778a912dbf10e6dd16`: setup reached an Engine-only ToString helper and crashed on a null target Engine; the provider was gated during recording.
- Run `b3e0ec387c024fd992ca4b51911f4bc4`: five of seven cases passed; the extracted parser rejected `EDateTimeStyle::Type`, and the initial missing-table expectation did not match Unreal's placeholder behavior. The declaration spelling and independently observed contract were corrected.
- Run `d7adb76bfbab41b0846a576a8dcf4261`: unconditional fixture declarations conflicted with catalog-provided types; dependencies became conditional.
- Run `d2af96a8cd4a430f928dc574a5563515`: six of seven cases passed. The complete-provider case rejected five real `const ?&` generic format declarations at wildcard bytes 40..41.
- Run `49d0e58358dc440b813a8206852d2415`: after parser, canonical identity and apply support, six cases still passed and the complete-provider case advanced to metadata signature admission, which rejected `ttQuestion` transactionally.

The two hidden ownership boundaries are recorded in the applied wildcard type and metadata replans. No provider declaration or test was removed to obtain GREEN.

## Final build and exact proof

- Harness build `34411e7bf0c5485eb3c552b68e251e06`: `AngelscriptProjectEditor Win64 Development`, succeeded, 106/106 actions observed.
- Built Runtime DLL SHA-256: `d6e6560e1415ba159a6b9453a00be0f3061f94cac1f3c13f08b6918abf0eecb`.
- Plugin base commit: `edc13e98d7a63fa22b76620302d1294fe6126641`; the task is verified from the preserved uncommitted Change workspace.
- Exact test run `faea5d54d8d84d24911a783354cf9b97`: complete report, 7/7 succeeded, zero warnings, zero errors, exit 0. Summary SHA-256: `a84a9df032a2c1ab610ce4f3cf00522fcbe8548fb0265c3ebc5efcb2ef3cb39d`.

Exact cases:

1. `CompleteTextFormattingFamilyIsRecorded`
2. `OrderedFormatSubstitutesSeven`
3. `NamedFormatSubstitutesSeven`
4. `TextAndStringConversionPreservesHello`
5. `NumberFormattingOptionsSurviveCopy`
6. `InvalidFormatArgumentReportsExplicitTypeDiagnostic`
7. `MissingStringTableEntryIsEmptyWithoutCreatingGlobalFixture`

## Impact-related regression proof

- Runtime value families run `ab5a197f5cc147d6b0dd1fb828501dc7`: complete report, 46/46 succeeded, zero warnings/errors, exit 0; summary SHA-256 `af0e9dfbd4d9962f25797ebf6893aeebf9c2962d20c7705602a01ef47832ee00`.
- Detached declaration parser run `b6eaa5be55944d2690395bdae10ba552`: complete report, 8/8 succeeded, zero warnings/errors, exit 0; summary SHA-256 `7eb675c705e717522bf43fce2ae9cfcb9908c01970993b7c536a637d425ed805`.
- Metadata image run `e6230f25381144b0ba5ee5324bec641b`: complete report, 23/23 succeeded, zero warnings/errors, exit 0; summary SHA-256 `9482fbaa35d4edc00d9715072248a5cee0f9a29460b6499fcf6853bd12db8d8c`.
- `git diff --check` completed without whitespace errors; Git emitted only line-ending conversion notices for the existing dirty workspace.

The full NativeEngine selector and full RuntimeBindings selector remain terminal gates in tasks 8.4 and 8.2. This task ran the narrower shared parser, metadata, and value-family scopes demonstrated by its impact.
