/**
 * @version v1
 * @summary An identifier may not begin with a digit, so such a local is rejected. This file is the illegal program itself; do not rename the variable, since the malformed name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An identifier may not begin with a digit, so such a local is rejected. This file is the illegal program itself; do not rename the variable, since the malformed name is the point.
 * @topic Negative
 */
/**
 * Attempt to declare a local whose name starts with a digit.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int 123abc = 0;
}
/** @end */
