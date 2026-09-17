/**
 * @version v1
 * @summary Calling a private Init method from outside the declaring class is rejected. This file is the illegal program itself; do not make Init public, since the outside call is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Calling a private Init method from outside the declaring class is rejected. This file is the illegal program itself; do not make Init public, since the outside call is the point.
 * @topic Negative
 */
/**
 * An actor whose Init method is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Init is called from outside
 */
class AActorPrivStatic : AActor
{
	/**
	 * A private Init method that outsiders must not call.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return nothing; the outside call is rejected first
	 */
	private void Init()
	{
	}
}

/**
 * Attempt to call the private Init method from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivStatic A;
	A.Init();
}
/** @end */
