/**
 * @version v1
 * @summary A UPROPERTY on a function is rejected. This file is the illegal program itself; do not move the specifier onto a member variable.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY on a function is rejected. This file is the illegal program itself; do not move the specifier onto a member variable.
 * @topic Negative
 */
class AUPropOnFuncActor : AActor
{
	/**
	 * The isolated failing program: UPROPERTY is not valid on a function.
	 *
	 * @Kind CompileReject
	 * @Covers UProperty.UPropertyOnFunction
	 * @Inputs a function marked UPROPERTY
	 * @Return does not compile
	 */
	UPROPERTY()
	void Foo()
	{
	}
}
/** @end */
