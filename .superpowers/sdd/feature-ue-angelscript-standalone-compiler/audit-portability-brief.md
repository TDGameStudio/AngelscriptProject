# Portability audit brief

Read-only task. Do not edit files, commit, build, or change OpenSpec checkboxes.

Determine the smallest realistic Win64 CMake source set that can create an AngelScript engine, compile one module, save/load bytecode, and execute a script using the maintained fork under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript`.

Inspect the actual fork and report:

1. exact source files required for the minimal engine/compiler/module/context path;
2. exact UE headers/types/macros/functions referenced by that source set;
3. which dependencies can be removed by source selection, which need unconditional portable refactors, and which can be isolated behind a narrow platform adapter;
4. whether `AS_MAX_PORTABILITY` avoids native call assembly sources and the required compile definitions;
5. a recommended first TDD slice and expected initial compile failures;
6. risks that contradict OpenSpec Phase 0 task 0.1.

Write the detailed report to `.superpowers/sdd/feature-ue-angelscript-standalone-compiler/audit-portability-report.md`. Return only status plus a one-line summary and concerns.
