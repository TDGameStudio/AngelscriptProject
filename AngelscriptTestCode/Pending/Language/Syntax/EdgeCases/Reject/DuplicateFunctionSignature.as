/**
 * @version v1
 * @summary Declaring the same function signature twice is rejected. This file is the illegal program itself; do not change either signature, since the collision is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring the same function signature twice is rejected. This file is the illegal program itself; do not change either signature, since the collision is the point.
 * @topic Negative
 */
/**
 * The first declaration of the duplicated signature.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(int X)
{
}

/**
 * The second declaration of the same signature.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(int X)
{
}
/** @end */
