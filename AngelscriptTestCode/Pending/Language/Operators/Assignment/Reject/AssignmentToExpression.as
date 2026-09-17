/**
 * @version v1
 * @summary Assigning to an arithmetic expression is rejected: the result of an addition is not an lvalue. This file is the illegal program itself; do not assign to one of the operands instead, since the expression target is the.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning to an arithmetic expression is rejected: the result of an addition is not an lvalue. This file is the illegal program itself; do not assign to one of the operands instead, since the expression target is the.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 0;
	int Y = 0;
	(X + Y) = 5;
}
/** @end */
