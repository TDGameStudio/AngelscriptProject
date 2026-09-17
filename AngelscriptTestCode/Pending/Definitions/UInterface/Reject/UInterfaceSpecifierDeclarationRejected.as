/**
 * @version v1
 * @summary UINTERFACE(BlueprintType) plus a UFUNCTION method is rejected. The specifier list is parsed as a call, so compilation stops on the opening parenthesis. Do not drop BlueprintType or the UFUNCTION.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UINTERFACE(BlueprintType) plus a UFUNCTION method is rejected. The specifier list is parsed as a call, so compilation stops on the opening parenthesis. Do not drop BlueprintType or the UFUNCTION.
 * @topic Negative
 */
UINTERFACE(BlueprintType)
interface ICoverageUnsupportedBlueprintTypeInterface
{
	/**
	 * A reflected getter whose UFUNCTION annotation sits inside the unsupported interface.
	 *
	 * @Covers UInterface.UInterfaceSpecifierDeclarationRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION(BlueprintCallable)
	int GetValue();
}
/** @end */
