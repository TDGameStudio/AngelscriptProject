/**
 * @version v1
 * @summary Naming a parameter the function does not declare is rejected. This file is the illegal program itself; do not add the missing parameter, since the unknown name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Naming a parameter the function does not declare is rejected. This file is the illegal program itself; do not add the missing parameter, since the unknown name is the point.
 * @topic Negative
 */
/**
 * A function called with a parameter it never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 * @Param A a declared parameter
 * @Param B a declared parameter
 * @Param C a declared parameter
 */
int Mix(int A, int B, int C)
{
	return 0;
}

/**
 * The call site naming the undeclared parameter.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Run()
{
	return Mix(A: 1, D: 2, C: 3);
}
/** @end */
