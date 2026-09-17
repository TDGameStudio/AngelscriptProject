/**
 * @version v1
 * @summary Assigning to the result of an addition is rejected: the result is not an lvalue. This file is the illegal program itself; do not assign to one of the operands instead, since the expression target is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning to the result of an addition is rejected: the result is not an lvalue. This file is the illegal program itself; do not assign to one of the operands instead, since the expression target is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int A = 1;
	int B = 2;
	(A + B) = 5;
}
/** @end */
