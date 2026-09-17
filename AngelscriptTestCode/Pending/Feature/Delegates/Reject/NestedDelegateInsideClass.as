/**
 * @version v1
 * @summary A delegate type nested inside a class is rejected. Delegate types belong at script scope, not as members of ADelNestedActor.
 * @topic Feature
 */
/**
 * @version root
 * @summary A delegate type nested inside a class is rejected. Delegate types belong at script scope, not as members of ADelNestedActor.
 * @topic Negative
 */
class ADelNestedActor : AActor
{
	/**
	 * The isolated failing program: a delegate type nested in a class.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return does not compile; delegate types are not class members
	 */
	delegate void FOnActionNested();
}
/** @end */
