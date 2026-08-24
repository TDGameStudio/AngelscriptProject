// Theme: Definitions.UFunction. NegativeDiagnostic: unknown UFUNCTION specifier.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case unknown function specifier.
// Expected diagnostic: "Unknown function specifier DefinitelyUnknownSpecifier on method ACoverageUFunctionUnknownSpecifierActor::UnknownSpecifier."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionUnknownSpecifierActor : AActor
{
	UFUNCTION(DefinitelyUnknownSpecifier)
	void UnknownSpecifier()
	{
	}
}
