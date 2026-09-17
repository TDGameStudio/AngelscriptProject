/**
 * @version v1
 * @summary An unknown UFUNCTION specifier on a generated method is rejected. DefinitelyUnknownSpecifier is not a legal function specifier. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An unknown UFUNCTION specifier on a generated method is rejected. DefinitelyUnknownSpecifier is not a legal function specifier. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionUnknownSpecifierActor : AActor
{
	/**
	 * Illegal UFUNCTION using DefinitelyUnknownSpecifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(DefinitelyUnknownSpecifier)
	 * @Return does not compile
	 */
	UFUNCTION(DefinitelyUnknownSpecifier)
	void UnknownSpecifier()
	{
	}
}
/** @end */
