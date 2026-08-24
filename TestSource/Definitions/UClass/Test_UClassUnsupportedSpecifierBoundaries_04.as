// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier GlobalUserConfig.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier GlobalUserConfig.
// DiagnosticOnly. Do not drop GlobalUserConfig; that would make the program compile.

UCLASS(GlobalUserConfig)
class UCoverageUClassUnsupportedGlobalUserConfigObject : UObject
{
}
