/**
 * @version v1
 * @summary Declaring the same local name twice in one scope is rejected. This file is the illegal program itself; do not rename either local, since the collision is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring the same local name twice in one scope is rejected. This file is the illegal program itself; do not rename either local, since the collision is the point.
 * @topic Negative
 */
/**
 * Attempt to declare two locals with the same name in one scope.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int X = 1;
	int X = 2;
}
/** @end */
