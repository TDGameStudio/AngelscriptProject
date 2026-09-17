/**
 * @version v1
 * @summary The retired Haze DevFunction specifier is unknown. It is not a legal UFUNCTION specifier on this fork. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary The retired Haze DevFunction specifier is unknown. It is not a legal UFUNCTION specifier on this fork. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionHazeDevFunctionActor : AActor
{
	/**
	 * Illegal UFUNCTION using the retired DevFunction specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(DevFunction)
	 * @Return does not compile
	 */
	UFUNCTION(DevFunction)
	void HazeDevFunction()
	{
	}
}
/** @end */
