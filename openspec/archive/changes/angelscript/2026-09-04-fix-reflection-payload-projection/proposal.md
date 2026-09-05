## Why

Post-archive source-to-contract verification found that the reconstructed parser retains the outer reflection annotation but skips every parenthesized argument, and that `UENUM` produces an enum descriptor without typed constants. The current reflection/dependency capability requires concrete descriptor metadata and enum payload to agree with accepted typed semantic objects, so these two omissions must fail closed rather than silently publish incomplete `Resolved` output.

## What Changes

- Parse reflection annotation arguments into typed `Attr` nodes owned by the annotated declaration, including bare flags, direct key/value strings, and nested `Meta=(...)` entries.
- Represent enum constants as concrete typed declaration nodes with deterministic explicit or implicit integer values.
- Project accepted metadata and enum constants into the existing concrete descriptor fields without reparsing source in the descriptor consumer.
- Add focused replacement NativeEngine tests, then rerun only the directly affected Reflection, Declarations, and AST families.

Production routing remains dormant. The fix does not modify the legacy Runtime preprocessor, create UE/Runtime objects, add a generic metadata DTO, or change the current durable requirement text.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This Change repairs the implementation to satisfy the already-current `angelscript/language/frontend/reflection-dependencies` contract.

## Impact

- Submodule: `Plugins/Angelscript` reconstructed frontend and replacement NativeEngine tests.
- Parent repository: this defect Change and verification evidence only; the existing current spec remains semantically unchanged.
- Public Engine, Builder, VM, bytecode, Standalone, and production preprocessing APIs are unaffected.
