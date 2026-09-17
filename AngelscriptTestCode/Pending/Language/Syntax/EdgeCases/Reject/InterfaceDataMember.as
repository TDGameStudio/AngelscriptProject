/**
 * @version v1
 * @summary An interface declaring a data member is rejected. This file is the illegal program itself; do not drop the data member, since its presence is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An interface declaring a data member is rejected. This file is the illegal program itself; do not drop the data member, since its presence is the point.
 * @topic Negative
 */
interface UIntfMember
{
	/**
	 * The data member whose presence inside an interface is illegal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	int X;
}
/** @end */
