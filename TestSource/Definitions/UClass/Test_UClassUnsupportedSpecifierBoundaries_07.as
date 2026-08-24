// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier CollapseCategories.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier CollapseCategories.
// DiagnosticOnly. Do not drop CollapseCategories; that would make the program compile.

UCLASS(CollapseCategories)
class UCoverageUClassUnsupportedCollapseCategoriesObject : UObject
{
}
