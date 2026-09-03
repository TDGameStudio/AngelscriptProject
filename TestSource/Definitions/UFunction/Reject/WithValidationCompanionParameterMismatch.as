/**
 * A WithValidation companion must use the same parameters as the RPC. The
 * validate method takes FString while the server method takes int. This file
 * is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.WithValidationCompanionParameterMismatch
 * @Harness CompileReject
 * @Tag Definitions.UFunction.WithValidationCompanionParameterMismatch
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs ServerBadValidateParams(int) with _Validate(FString)
 * @Return does not compile; diagnostic "UFUNCTION() ServerBadValidateParams in class ACoverageUFunctionBadValidateParamsActor has a _Validate function but the parameters don't match!"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: _Validate companion parameters must match.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case validate parameter mismatch.
 * @Provenance Expected compile failure: "UFUNCTION() ServerBadValidateParams in class ACoverageUFunctionBadValidateParamsActor has a _Validate function but the parameters don't match!"
 */

UCLASS()
class ACoverageUFunctionBadValidateParamsActor : AActor
{
	default SetReplicates(true);

	/**
	 * Server WithValidation UFUNCTION whose companion parameters do not match.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION(Server, WithValidation)
	void ServerBadValidateParams(int Value)
	{
	}

	/**
	 * Illegal _Validate companion whose parameter type is FString instead of int.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs FString Value
	 * @Return does not compile
	 */
	UFUNCTION()
	bool ServerBadValidateParams_Validate(FString Value)
	{
		return !Value.IsEmpty();
	}
}
