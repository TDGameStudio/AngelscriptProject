// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier ShowCategories.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier ShowCategories.
// DiagnosticOnly. Do not drop ShowCategories; that would make the program compile.

UCLASS(ShowCategories="Rendering")
class UCoverageUClassUnsupportedShowCategoriesObject : UObject
{
}
