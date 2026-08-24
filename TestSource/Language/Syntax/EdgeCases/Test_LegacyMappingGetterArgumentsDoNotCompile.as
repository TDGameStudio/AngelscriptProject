// Theme: Language.Syntax.EdgeCases. Isolated compile-fail despite CSV Positive.
// C++: AngelscriptInputFunctionLibraryTests.cpp::LegacyMappingGetterArgumentsDoNotCompile
// CompileAndExpectFailure for argument-taking mapping getters.
// sha256=baf232dcfd1d565198cefa95647bed0addc9f433221b638401a80d1969a9091d; lines 65-71.
// Expected diagnostic contains "GetEngineDefinedActionMappings" and "GetEngineDefinedAxisMappings".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

void UseLegacyMappingArguments(UPlayerInput PlayerInput)
{
	PlayerInput.GetEngineDefinedActionMappings(n"LegacyAction");
	PlayerInput.GetEngineDefinedAxisMappings(n"LegacyAxis");
}
