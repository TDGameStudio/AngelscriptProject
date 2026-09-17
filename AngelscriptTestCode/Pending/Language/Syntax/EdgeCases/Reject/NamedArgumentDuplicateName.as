/**
 * @version v1
 * @summary Naming the same parameter twice in one call is rejected. This file is the illegal program itself; do not rename one of the duplicate arguments, since the collision is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Naming the same parameter twice in one call is rejected. This file is the illegal program itself; do not rename one of the duplicate arguments, since the collision is the point.
 * @topic Negative
 */
/**
 * A function whose call site names one parameter twice.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 * @Param A the duplicated parameter name
 * @Param B an unused parameter
 * @Param C a parameter bound after the duplicate
 */
int Mix(int A, int B, int C)
{
	return 0;
}

/**
 * The call site carrying the duplicated name.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Run()
{
	return Mix(A: 1, A: 2, C: 3);
}
/** @end */
