// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier ConversionRoot.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier ConversionRoot.
// DiagnosticOnly. Do not drop ConversionRoot; that would make the program compile.

UCLASS(ConversionRoot)
class UCoverageUClassUnsupportedConversionRootObject : UObject
{
}
