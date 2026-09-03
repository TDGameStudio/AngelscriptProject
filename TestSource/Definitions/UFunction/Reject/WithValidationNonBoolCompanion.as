/**
 * A WithValidation companion must return bool. ServerBadValidateReturn_Validate
 * returns int. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.WithValidationNonBoolCompanion
 * @Harness CompileReject
 * @Tag Definitions.UFunction.WithValidationNonBoolCompanion
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs ServerBadValidateReturn_Validate returning int
 * @Return does not compile; diagnostic "UFUNCTION() ServerBadValidateReturn in class ACoverageUFunctionBadValidateReturnActor has a _Validate function that is returning a non-bool!"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: _Validate companion must return bool.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case validate non-bool return.
 * @Provenance Expected compile failure: "UFUNCTION() ServerBadValidateReturn in class ACoverageUFunctionBadValidateReturnActor has a _Validate function that is returning a non-bool!"
 */

UCLASS()
class ACoverageUFunctionBadValidateReturnActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server WithValidation UFUNCTION whose companion returns a non-bool.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION(Server, WithValidation)
	void ServerBadValidateReturn(int Value)
	{
	}

	/**
	 * Illegal _Validate companion that returns int instead of bool.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION()
	int ServerBadValidateReturn_Validate(int Value)
	{
		return Value;
	}
}
