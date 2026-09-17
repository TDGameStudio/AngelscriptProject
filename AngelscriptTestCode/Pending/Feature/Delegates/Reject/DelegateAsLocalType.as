/**
 * @version v1
 * @summary A delegate type declared as a local inside a function is rejected. Delegate types belong at script scope, not inside Foo.
 * @topic Feature
 */
/**
 * @version root
 * @summary A delegate type declared as a local inside a function is rejected. Delegate types belong at script scope, not inside Foo.
 * @topic Negative
 */
class ADelLocalActor : AActor
{
	/**
	 * The isolated failing program: a delegate type declared as a local.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return does not compile; delegate types are not locals
	 */
	void Foo()
	{
		delegate void FOnActionLocal();
	}
}
/** @end */
