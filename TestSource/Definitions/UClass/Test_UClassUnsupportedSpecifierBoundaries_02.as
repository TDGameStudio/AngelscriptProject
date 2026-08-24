// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier NotBlueprintType.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier NotBlueprintType.
// DiagnosticOnly. Do not drop NotBlueprintType; that would make the program compile.

UCLASS(NotBlueprintType)
class UCoverageUClassUnsupportedNotBlueprintTypeObject : UObject
{
}
