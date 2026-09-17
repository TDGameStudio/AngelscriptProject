/**
 * @version v1
 * @summary An interface declaration with no name is rejected. This file is the illegal program itself; do not invent an interface name, since the missing name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An interface declaration with no name is rejected. This file is the illegal program itself; do not invent an interface name, since the missing name is the point.
 * @topic Negative
 */
interface
{
	/**
	 * A method inside the unnamed interface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Foo();
}
/** @end */
