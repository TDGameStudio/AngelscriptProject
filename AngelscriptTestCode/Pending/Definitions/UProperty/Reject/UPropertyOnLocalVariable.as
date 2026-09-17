/**
 * @version v1
 * @summary A UPROPERTY on a local variable is rejected. This file is the illegal program itself; do not move the specifier onto a member.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY on a local variable is rejected. This file is the illegal program itself; do not move the specifier onto a member.
 * @topic Negative
 */
class AUPropLocalVarActor : AActor
{
	/**
	 * The isolated failing program: UPROPERTY is not valid on a local.
	 *
	 * @Kind CompileReject
	 * @Covers UProperty.UPropertyOnLocalVariable
	 * @Inputs a local marked UPROPERTY
	 * @Return does not compile
	 */
	void Foo()
	{
		UPROPERTY()
		int X = 0;
	}
}
/** @end */
