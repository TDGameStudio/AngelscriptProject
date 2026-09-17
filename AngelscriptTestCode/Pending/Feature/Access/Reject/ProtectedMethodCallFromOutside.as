/**
 * @version v1
 * @summary Calling a protected method from a free function is rejected. This file is the illegal program itself; do not make InternalMethod public, since the outside call is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Calling a protected method from a free function is rejected. This file is the illegal program itself; do not make InternalMethod public, since the outside call is the point.
 * @topic Negative
 */
/**
 * An actor whose only method is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once InternalMethod is called from outside
 */
class AActorProtMethodOut : AActor
{
	/**
	 * A protected method that free functions must not call.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return nothing; the outside call is rejected first
	 */
	protected void InternalMethod()
	{
	}
}

/**
 * Attempt to call the protected method from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorProtMethodOut A;
	A.InternalMethod();
}
/** @end */
