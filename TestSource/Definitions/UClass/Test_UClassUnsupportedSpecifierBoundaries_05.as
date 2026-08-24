// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier ProjectUserConfig.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier ProjectUserConfig.
// DiagnosticOnly. Do not drop ProjectUserConfig; that would make the program compile.

UCLASS(ProjectUserConfig)
class UCoverageUClassUnsupportedProjectUserConfigObject : UObject
{
}
