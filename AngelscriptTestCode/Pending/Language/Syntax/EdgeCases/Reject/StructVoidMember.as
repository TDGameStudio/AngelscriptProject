/**
 * @version v1
 * @summary A struct member of type void is rejected. This file is the illegal program itself; do not replace void with int, since the void declaration is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A struct member of type void is rejected. This file is the illegal program itself; do not replace void with int, since the void declaration is the point.
 * @topic Negative
 */
/**
 * A struct whose member type is void.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FStructVoidMember
{
	/**
	 * The member whose void type is the point.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void X;
}
/** @end */
