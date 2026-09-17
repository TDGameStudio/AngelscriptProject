/**
 * @version v1
 * @summary Writing a protected member from a free function is rejected. This file is the illegal program itself; do not make ProtVal public, since the outside write is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Writing a protected member from a free function is rejected. This file is the illegal program itself; do not make ProtVal public, since the outside write is the point.
 * @topic Negative
 */
/**
 * An actor whose only member is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once ProtVal is written from outside
 */
class AActorProtWrite : AActor
{
	protected int ProtVal = 0;
}

/**
 * Attempt to write the protected member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorProtWrite A;
	A.ProtVal = 99;
}
/** @end */
