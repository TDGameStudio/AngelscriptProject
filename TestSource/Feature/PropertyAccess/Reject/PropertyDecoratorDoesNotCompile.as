/**
 * Isolated compile-fail: the removed `property` decorator on GetStored. C++ concatenates
 * `property` into GetStored() and expects bCompiled==false with the diagnostic
 * "The 'property' decorator has been removed".
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.PropertyDecoratorDoesNotCompile
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.PropertyDecoratorDoesNotCompile
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: removed `property` decorator.
 * @Provenance CSV Positive. C++ PropertyDecoratorDoesNotCompile concatenates `property` into
 * @Provenance GetStored(); bCompiled==false. Expected diagnostic:
 * @Provenance "The 'property' decorator has been removed".
 * @Provenance Isolate this failing program. Do not add declarations that would compile it away.
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
