/**
 * @version v1
 * @summary The retired Haze NetFunction specifier is unknown. It is not a legal UFUNCTION specifier on this fork. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary The retired Haze NetFunction specifier is unknown. It is not a legal UFUNCTION specifier on this fork. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionHazeNetFunctionActor : AActor
{
	/**
	 * Illegal UFUNCTION using the retired NetFunction specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(NetFunction)
	 * @Return does not compile
	 */
	UFUNCTION(NetFunction)
	void HazeNetFunction()
	{
	}
}
/** @end */
