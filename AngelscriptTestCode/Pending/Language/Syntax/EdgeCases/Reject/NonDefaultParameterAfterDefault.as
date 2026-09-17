/**
 * @version v1
 * @summary A parameter without a default following one with a default is rejected. This file is the illegal program itself; do not add a default to Y, since the ordering violation is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A parameter without a default following one with a default is rejected. This file is the illegal program itself; do not add a default to Y, since the ordering violation is the point.
 * @topic Negative
 */
/**
 * A function whose defaulted parameter is followed by a plain one.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(int X = 5, int Y)
{
}
/** @end */
