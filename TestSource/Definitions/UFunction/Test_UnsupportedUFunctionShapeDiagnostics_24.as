// Theme: Definitions.UFunction. NegativeDiagnostic: TOptional USTRUCT UFUNCTION parameter is unsupported.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case optional parameter.
// Expected diagnostic: "Unknown or invalid parameter type for parameter Value"
// Isolate this failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FUFunctionOptionalParameterPayload
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageUFunctionOptionalParameterActor : AActor
{
	UFUNCTION()
	void AcceptOptional(TOptional<FUFunctionOptionalParameterPayload> Value)
	{
	}
}
