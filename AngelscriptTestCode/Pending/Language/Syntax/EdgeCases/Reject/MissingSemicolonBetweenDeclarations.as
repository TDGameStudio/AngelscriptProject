/**
 * @version v1
 * @summary Two declarations on one line with no separating semicolon are rejected. This file is the illegal program itself; do not insert the omitted semicolon, since the missing separator is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Two declarations on one line with no separating semicolon are rejected. This file is the illegal program itself; do not insert the omitted semicolon, since the missing separator is the point.
 * @topic Negative
 */
/**
 * A function whose two declarations are not separated by a semicolon.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int X = 1 int Y = 2;
}
/** @end */
