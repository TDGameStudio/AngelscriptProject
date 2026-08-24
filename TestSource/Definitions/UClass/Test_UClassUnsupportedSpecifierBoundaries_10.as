// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier AutoCollapseCategories.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier AutoCollapseCategories.
// DiagnosticOnly. Do not drop AutoCollapseCategories; that would make the program compile.

UCLASS(AutoCollapseCategories="Advanced")
class UCoverageUClassUnsupportedAutoCollapseCategoriesObject : UObject
{
}
