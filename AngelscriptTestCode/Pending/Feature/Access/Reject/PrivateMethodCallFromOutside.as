/**
 * @version v1
 * @summary Calling a private method from outside the declaring class is rejected. This file is the illegal program itself; do not make SecretMethod public, since the outside call is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Calling a private method from outside the declaring class is rejected. This file is the illegal program itself; do not make SecretMethod public, since the outside call is the point.
 * @topic Negative
 */
/**
 * An actor whose only method is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once SecretMethod is called from outside
 */
class AActorPrivMethod : AActor
{
	/**
	 * A private method that outsiders must not call.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return nothing; the outside call is rejected first
	 */
	private void SecretMethod()
	{
	}
}

/**
 * Attempt to call the private method from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivMethod A;
	A.SecretMethod();
}
/** @end */
