/**
 * @version v1
 * @summary Mod-assigning a float is rejected: the remainder operator applies to integers only. This file is the illegal program itself; do not convert the operands, since the non-integer operands are the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Mod-assigning a float is rejected: the remainder operator applies to integers only. This file is the illegal program itself; do not convert the operands, since the non-integer operands are the point.
 * @topic Negative
 */
/** */
void Test()
{
	float X = 1.0f;
	X %= 2.0f;
}
/** @end */
