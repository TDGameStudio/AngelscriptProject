/**
 * @version v1
 * @summary Shift-assigning a float is rejected: shift operators apply to integers only. This file is the illegal program itself; do not convert the operand, since the non-integer operand is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Shift-assigning a float is rejected: shift operators apply to integers only. This file is the illegal program itself; do not convert the operand, since the non-integer operand is the point.
 * @topic Negative
 */
/** */
void Test()
{
	float X = 1.0f;
	X <<= 2;
}
/** @end */
