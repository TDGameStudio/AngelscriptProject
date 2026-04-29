================================================================================
ANGELSCRIPT PROJECT - TEST COVERAGE ANALYSIS
Generated: 2026-04-29
================================================================================

OVERALL COVERAGE: 73% (269/369 files well tested)

CRITICAL GAPS - 15 FILES NEEDING TESTS
======================================

EDITOR UI EXTENSIONS (6 files - ZERO TESTS):
  1. ScriptActorMenuExtension.cpp
  2. ScriptAssetMenuExtension.cpp
  3. ScriptEditorMenuExtension.cpp
  4. ScriptEditorMenuExtensionRegistration.cpp
  5. ScriptEditorPrompts.cpp
  6. AngelscriptContentBrowserDataSource.cpp

CODE COVERAGE INFRASTRUCTURE (2 files - NO DEDICATED TESTS):
  7. AngelscriptCodeCoverage.cpp
  8. CoverageReportGenerator.cpp

UTILITY/SPECIALIZED (7 files):
  9. UObjectInWorld.cpp (implicit tests only)
  10. AngelscriptThirdPartyLib.cpp (NO TESTS)
  11. Bind_Deprecations.cpp (deprecated)
  12. AngelscriptEditorCodeGen.cpp (integration only)
  13. ScriptableFactory.cpp (minimal)
  14. AngelscriptAllScriptRootsCommandlet.cpp (CLI only)
  15. AngelscriptTestCommandlet.cpp (CLI only)

MODULE BREAKDOWN
================
AngelscriptRuntime: 301 files
  - 265 Well Tested (88%)
  - 32 Partial (11%)
  - 4 Not Tested (1%)

AngelscriptEditor: 66 files
  - 6 Well Tested (9%)
  - 3 Partial (5%)
  - 57 Not Tested (86%)

AngelscriptLoader: 2 files
  - 0 Well Tested
  - 2 Partial (integration only)

WELL-TESTED SYSTEMS
===================
✓ Bindings: 120+/127 (math, containers, GAS, input, UI)
✓ ClassGenerator: 3/3 (dynamic class generation)
✓ Debugger: 1/1 (DAP debug server)
✓ StaticJIT: 5/5 (bytecode and JIT)
✓ Preprocessor: 1/1 (full pipeline)
✓ Core: 17/23 (engine core and GAS)
✓ HotReload: 2/2 (file watching, class reload)
✓ BlueprintImpact: 2/2 (impact analysis)

TEST FILES LOCATION
==================
All analysis files saved in: D:\Workspace\AngelscriptProject\

Key files:
  - COVERAGE_SUMMARY.txt (quick overview)
  - COVERAGE_FINAL_REPORT.txt (executive summary)
  - TEST_COVERAGE_ANALYSIS_DETAILED.txt (detailed gaps)
  - TEST_COVERAGE_DETAILED_MAPPING.txt (file-by-file mapping)

================================================================================
