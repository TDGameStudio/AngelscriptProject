/**
 * @version v1
 * @summary Declaring a local with a type that does not exist is rejected. This file is the illegal program itself; do not introduce the missing type, since the undeclared name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring a local with a type that does not exist is rejected. This file is the illegal program itself; do not introduce the missing type, since the undeclared name is the point.
 * @topic Negative
 */
/**
 * Attempt to declare a local with a type that does not exist.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	NonExistentType X;
}
/** @end */
