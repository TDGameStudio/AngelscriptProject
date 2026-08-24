// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier Placeable.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier Placeable.
// DiagnosticOnly. Do not drop Placeable; that would make the program compile.

UCLASS(Placeable)
class ACoverageUClassUnsupportedExplicitPlaceableActor : AActor
{
}
