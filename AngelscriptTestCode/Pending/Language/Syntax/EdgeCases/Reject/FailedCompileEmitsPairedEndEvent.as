/**
 * @version v1
 * @summary A function whose return statement carries no expression is rejected, and the compiler's paired End compilation event fires on that failure. This file is the illegal program itself; do not supply a return value, since the.
 * @topic Language
 */
/**
 * @version root
 * @summary A function whose return statement carries no expression is rejected, and the compiler's paired End compilation event fires on that failure. This file is the illegal program itself; do not supply a return value, since the.
 * @topic Negative
 */
/**
 * A function returning nothing despite declaring an int return type.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Entry()
{
	return ;
}
/** @end */
