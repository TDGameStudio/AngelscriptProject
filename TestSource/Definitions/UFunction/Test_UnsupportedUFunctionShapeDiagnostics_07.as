// Theme: Definitions.UFunction. NegativeDiagnostic: static UFUNCTION cannot use network specifiers.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case static network specifier.
// Expected diagnostic: "Static UFUNCTION()s cannot use network specifiers"
// Isolate this failing program. DiagnosticOnly.

UFUNCTION(Server)
void StaticServerAction()
{
}
