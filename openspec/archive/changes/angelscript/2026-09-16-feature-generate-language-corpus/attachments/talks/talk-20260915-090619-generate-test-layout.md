# Generator tests live under FrameworkTests/Generate

## Context

Generator sources already live under `Framework/Generate/`. The plan had placed every generator test TU at the `FrameworkTests/` root, and kept the ForLoop baseline in the generic `GenerateTests.cpp` name. The user asked to nest those tests under `FrameworkTests/Generate/` and to stop using the generic ForLoop filename.

## Evidence

`FrameworkTests/` already owns unrelated framework tests (`SourceTests`, `ParserTests`, `DatabaseTests`, and others). Adding 122 generator TUs plus the corpus test at that root mixes two layers. The accepted product-test convention is already `<ClassWithoutF>Tests.cpp`; only ForLoop still used `GenerateTests.cpp`.

## Options

Leaving tests at the FrameworkTests root keeps the current Files trees but continues to bury generator work among unrelated TUs. A `FrameworkTests/Generate/` directory mirrors `Framework/Generate/` and keeps gold fixtures in `FrameworkTests/Gold/`. Renaming ForLoop to `ForLoopGeneratorTests.cpp` matches every other product file; keeping `GenerateTests.cpp` after the move would still hide the product.

## Settled Decision

All generator test TUs, the corpus test, and the test-only export helper live under `Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/Generate/`. The ForLoop test file is `ForLoopGeneratorTests.cpp`. Checked-in gold stays under `FrameworkTests/Gold/`. ForLoop's Automation identity remains `Angelscript.UnitTest.Framework.ForLoopGenerator`.

## Consequences

Task 1.1 moves or creates `GeneratedCaseExport.h/.cpp` and `ForLoopGeneratorTests.cpp` in the new directory and deletes `FrameworkTests/GenerateTests.cpp`. Later products create `FrameworkTests/Generate/<ClassWithoutF>Tests.cpp`. Include paths become `FrameworkTests/Generate/GeneratedCaseExport.h`. No product, cell count, descriptor, dump, or proving-prefix change.

## Flip Condition

A later module or UBT layout forbids a Generate subdirectory under FrameworkTests. Keep the product-named test files even if the directory has to move again.

## Sources

User request in the current session, [current design](../../design.md), and the existing `<ClassWithoutF>Tests.cpp` convention in [tasks.md](../../tasks.md).
