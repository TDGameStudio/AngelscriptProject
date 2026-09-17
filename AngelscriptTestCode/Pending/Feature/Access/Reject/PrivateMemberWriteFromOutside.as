/**
 * @version v1
 * @summary Writing a private member from outside the declaring class is rejected. This file is the illegal program itself; do not make X public, since the outside write is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Writing a private member from outside the declaring class is rejected. This file is the illegal program itself; do not make X public, since the outside write is the point.
 * @topic Negative
 */
/**
 * An actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once X is written from outside
 */
class AActorPrivWrite : AActor
{
	private int X = 0;
}

/**
 * Attempt to write the private member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivWrite A;
	A.X = 5;
}
/** @end */
