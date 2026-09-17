/**
 * @version v1
 * @summary Assigning to a variable that was never declared is rejected: a name must be declared before it can be written. This file is the illegal program itself; do not declare the variable, since the undeclared name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning to a variable that was never declared is rejected: a name must be declared before it can be written. This file is the illegal program itself; do not declare the variable, since the undeclared name is the point.
 * @topic Negative
 */
/** */
void Test()
{
	UndeclaredVar = 5;
}
/** @end */
