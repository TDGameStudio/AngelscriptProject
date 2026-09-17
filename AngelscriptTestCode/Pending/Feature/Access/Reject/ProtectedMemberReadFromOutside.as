/**
 * @version v1
 * @summary Reading a protected member from a free function is rejected. This file is the illegal program itself; do not make ProtVal public, since the outside read is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Reading a protected member from a free function is rejected. This file is the illegal program itself; do not make ProtVal public, since the outside read is the point.
 * @topic Negative
 */
/**
 * An actor whose only member is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once ProtVal is read from outside
 */
class AActorProtOut : AActor
{
	protected int ProtVal = 10;
}

/**
 * Attempt to read the protected member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorProtOut A;
	int X = A.ProtVal;
}
/** @end */
