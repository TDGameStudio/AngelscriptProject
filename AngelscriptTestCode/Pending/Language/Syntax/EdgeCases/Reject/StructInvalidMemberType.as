/**
 * @version v1
 * @summary A struct member whose type does not exist is rejected. This file is the illegal program itself; do not replace the member type with int, since the unknown type is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A struct member whose type does not exist is rejected. This file is the illegal program itself; do not replace the member type with int, since the unknown type is the point.
 * @topic Negative
 */
/**
 * A struct whose member type was never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FStructBadMember
{
	/**
	 * The member whose unknown type is the point.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	NonExistentType X;
}
/** @end */
