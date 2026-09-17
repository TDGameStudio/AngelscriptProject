/**
 * @version v1
 * @summary A function whose parameter type does not exist is rejected. This file is the illegal program itself; do not replace the type, since the unknown name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A function whose parameter type does not exist is rejected. This file is the illegal program itself; do not replace the type, since the unknown name is the point.
 * @topic Negative
 */
/**
 * A function whose parameter type was never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(NonExistentType X)
{
}
/** @end */
