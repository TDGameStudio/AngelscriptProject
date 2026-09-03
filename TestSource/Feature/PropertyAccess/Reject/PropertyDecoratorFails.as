/**
 * Isolated compile-fail: the removed `property` decorator on GetHealth. C++
 * PropertyDecoratorFails AssertFailsWithError "The 'property' decorator has been removed".
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.PropertyDecoratorFails
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.PropertyDecoratorFails
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: `property` decorator on GetHealth.
 * @Provenance CSV WorldStory. C++ PropertyDecoratorFails AssertFailsWithError
 * @Provenance "The 'property' decorator has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
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
