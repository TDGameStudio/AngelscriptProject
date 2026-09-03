/**
 * WithValidation requires a matching _Validate companion UFUNCTION. Server
 * ServerMissingValidate has no ServerMissingValidate_Validate. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.WithValidationMissingCompanion
 * @Harness CompileReject
 * @Tag Definitions.UFunction.WithValidationMissingCompanion
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(Server, WithValidation) void ServerMissingValidate(int Value)
 * @Return does not compile; diagnostic "UFUNCTION() ServerMissingValidate in class ACoverageUFunctionMissingValidateActor is marked as WithValidate but no _Validate function provided! Is it marked as UFUNCTION()?"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: WithValidation without _Validate companion.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case missing validate companion.
 * @Provenance Expected compile failure: "UFUNCTION() ServerMissingValidate in class ACoverageUFunctionMissingValidateActor is marked as WithValidate but no _Validate function provided! Is it marked as UFUNCTION()?"
 */

UCLASS()
class ACoverageUFunctionMissingValidateActor : AActor
{
	default SetReplicates(true);

	/**
	 * Illegal Server WithValidation UFUNCTION with no _Validate companion.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, WithValidation) void ServerMissingValidate(int Value)
	 * @Return does not compile
	 */
	UFUNCTION(Server, WithValidation)
	void ServerMissingValidate(int Value)
	{
	}
}
