/**
 * @version v1
 * @summary Isolated compile-fail: the removed `property` decorator on GetStored. C++ concatenates `property` into GetStored() and expects bCompiled==false with the diagnostic "The 'property' decorator has been removed".
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: the removed `property` decorator on GetStored. C++ concatenates `property` into GetStored() and expects bCompiled==false with the diagnostic "The 'property' decorator has been removed".
 * @topic Negative
 */
class FAutoAccessorDecoratorFailure
{
	int Stored = 3;

	/**
	 * The isolated failing program: GetStored still uses the removed property decorator.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.PropertyDecoratorDoesNotCompile
	 * @Inputs Stored default 3
	 * @Return does not compile; "The 'property' decorator has been removed"
	 */
	int GetStored() property
	{
		return Stored;
	}
}
/** @end */
