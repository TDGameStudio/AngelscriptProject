/**
 * @version v1
 * @summary A bitwise xor on two booleans is rejected: bitwise operators apply to integers only. This file is the illegal program itself; do not convert the operands, since the boolean operands are the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A bitwise xor on two booleans is rejected: bitwise operators apply to integers only. This file is the illegal program itself; do not convert the operands, since the boolean operands are the point.
 * @topic Negative
 */
/** */
void Test()
{
	bool A = true;
	bool B = false;
	int X = A ^ B;
}
/** @end */
