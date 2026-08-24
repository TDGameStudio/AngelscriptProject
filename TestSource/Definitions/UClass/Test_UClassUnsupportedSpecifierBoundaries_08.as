// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier DontCollapseCategories.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier DontCollapseCategories.
// DiagnosticOnly. Do not drop DontCollapseCategories; that would make the program compile.

UCLASS(DontCollapseCategories)
class UCoverageUClassUnsupportedDontCollapseCategoriesObject : UObject
{
}
