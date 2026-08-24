// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier AutoExpandCategories.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier AutoExpandCategories.
// DiagnosticOnly. Do not drop AutoExpandCategories; that would make the program compile.

UCLASS(AutoExpandCategories="Coverage")
class UCoverageUClassUnsupportedAutoExpandCategoriesObject : UObject
{
}
