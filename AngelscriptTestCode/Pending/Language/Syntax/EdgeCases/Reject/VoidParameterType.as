/**
 * @version v1
 * @summary Using void as a parameter type is rejected. This file is the illegal program itself; do not give the parameter a real type, since the void declaration is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Using void as a parameter type is rejected. This file is the illegal program itself; do not give the parameter a real type, since the void declaration is the point.
 * @topic Negative
 */
/**
 * A function declaring a parameter of type void.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(void X)
{
}
/** @end */
