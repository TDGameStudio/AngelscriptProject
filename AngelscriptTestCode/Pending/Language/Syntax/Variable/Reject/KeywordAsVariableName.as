/**
 * @version v1
 * @summary A reserved keyword cannot serve as a variable name, so such a local is rejected. This file is the illegal program itself; do not rename the variable, since the keyword collision is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A reserved keyword cannot serve as a variable name, so such a local is rejected. This file is the illegal program itself; do not rename the variable, since the keyword collision is the point.
 * @topic Negative
 */
/**
 * Attempt to declare a local named with a reserved keyword.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int class = 0;
}
/** @end */
