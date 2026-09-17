/**
 * @version v1
 * @summary The retired Haze CrumbFunction specifier is unknown. It is not a legal UFUNCTION specifier on this fork. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary The retired Haze CrumbFunction specifier is unknown. It is not a legal UFUNCTION specifier on this fork. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionHazeCrumbFunctionActor : AActor
{
	/**
	 * Illegal UFUNCTION using the retired CrumbFunction specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(CrumbFunction)
	 * @Return does not compile
	 */
	UFUNCTION(CrumbFunction)
	void HazeCrumbFunction()
	{
	}
}
/** @end */
