// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier HideFunctions.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier HideFunctions.
// DiagnosticOnly. Do not drop HideFunctions; that would make the program compile.

UCLASS(HideFunctions="HiddenA")
class UCoverageUClassUnsupportedHideFunctionsObject : UObject
{
}
