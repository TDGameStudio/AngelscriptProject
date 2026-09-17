/**
 * @version v1
 * @summary An interface method carrying a body is rejected. This file is the illegal program itself; do not strip the method body, since its presence is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An interface method carrying a body is rejected. This file is the illegal program itself; do not strip the method body, since its presence is the point.
 * @topic Negative
 */
interface UIntfBody
{
	/**
	 * The method whose concrete body inside an interface is illegal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void DoSomething()
	{
	}
}
/** @end */
