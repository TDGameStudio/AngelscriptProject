/**
 * @version v1
 * @summary UPARAM is not AngelScript parameter syntax. The C++ macro form UPARAM(DisplayName="Input Value") int Value is rejected by the parser. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UPARAM is not AngelScript parameter syntax. The C++ macro form UPARAM(DisplayName="Input Value") int Value is rejected by the parser. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionInvalidUParamActor : AActor
{
	/**
	 * Illegal UFUNCTION using UPARAM macro-style parameter syntax.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs UPARAM(DisplayName="Input Value") int Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable)
	void InvalidUPARAM(UPARAM(DisplayName="Input Value") int Value)
	{
	}
}
/** @end */
