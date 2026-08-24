// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier NonTransient.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier NonTransient.
// DiagnosticOnly. Do not drop NonTransient; that would make the program compile.

UCLASS(NonTransient)
class UCoverageUClassUnsupportedNonTransientObject : UObject
{
}
