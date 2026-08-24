// Theme: Definitions.UFunction. NegativeDiagnostic: WithValidation requires Server or Client.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case validation without endpoint.
// Expected diagnostic: "UFUNCTION() ValidateOnly has the WithValidation property without the Server or Client property!"
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionValidationWithoutEndpointActor : AActor
{
	UFUNCTION(WithValidation)
	void ValidateOnly()
	{
	}
}
