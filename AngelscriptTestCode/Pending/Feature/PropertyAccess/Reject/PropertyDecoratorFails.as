/**
 * @version v1
 * @summary Isolated compile-fail: the removed `property` decorator on GetHealth. C++ PropertyDecoratorFails AssertFailsWithError "The 'property' decorator has been removed".
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: the removed `property` decorator on GetHealth. C++ PropertyDecoratorFails AssertFailsWithError "The 'property' decorator has been removed".
 * @topic Negative
 */
class AActorPAProperty : AActor
{
	/**
	 * The isolated failing program: GetHealth still uses the removed property decorator.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.PropertyDecoratorFails
	 * @Inputs none
	 * @Return does not compile; "The 'property' decorator has been removed"
	 */
	int GetHealth() property
	{
		return 100;
	}
}
/** @end */
