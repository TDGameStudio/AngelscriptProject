/**
 * @version v1
 * @summary Reading a local after its block has ended is rejected. This file is the illegal program itself; do not hoist the declaration, since the scope exit is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Reading a local after its block has ended is rejected. This file is the illegal program itself; do not hoist the declaration, since the scope exit is the point.
 * @topic Negative
 */
/**
 * The function reading a variable whose block has closed.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Entry()
{
	{
		int Inner = 2;
	}
	return Inner;
}
/** @end */
