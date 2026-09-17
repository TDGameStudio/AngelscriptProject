/**
 * @version v1
 * @summary Reading a private member from outside the declaring class is rejected. This file is the illegal program itself; do not make Secret public, since the outside read is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Reading a private member from outside the declaring class is rejected. This file is the illegal program itself; do not make Secret public, since the outside read is the point.
 * @topic Negative
 */
/**
 * An actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Secret is read from outside
 */
class AActorPrivRead : AActor
{
	private int Secret = 42;
}

/**
 * Attempt to read the private member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivRead A;
	int X = A.Secret;
}
/** @end */
