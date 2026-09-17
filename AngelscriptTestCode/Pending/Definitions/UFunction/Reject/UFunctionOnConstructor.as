/**
 * @version v1
 * @summary UFUNCTION may not annotate a constructor. AUFuncCtorActor() is a constructor, not a reflected method. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UFUNCTION may not annotate a constructor. AUFuncCtorActor() is a constructor, not a reflected method. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncCtorActor : AActor
{
	/**
	 * Illegal UFUNCTION annotating the class constructor.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION() AUFuncCtorActor()
	 * @Return does not compile
	 */
	UFUNCTION()
	AUFuncCtorActor()
	{
	}
}
/** @end */
