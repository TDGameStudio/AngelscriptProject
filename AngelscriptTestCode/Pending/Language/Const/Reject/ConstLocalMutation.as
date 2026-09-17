/**
 * @version v1
 * @summary Assigning to a const local is rejected: a const binding cannot be written through, even from the scope that declared it. This file is the illegal program itself; do not drop the const to make it compile.
 * @topic Language
 * @topic Const
 */
/**
 * @version root
 * @summary Assigning to a const local is rejected: a const binding cannot be written through, even from the scope that declared it. This file is the illegal program itself; do not drop the const to make it compile.
 * @topic Negative
 */
/** */
void Test()
{
	const int Value = 1;
	Value = 2;
}
/** @end */
/**
 * @version invalid-const-local-compound
 * @parent root
 * @summary A const local cannot be the target of a compound assignment.
 * @topic Negative
 */
void Test()
{
	const int Value = 1;
	Value += 1;
}
/** @end */
/**
 * @version invalid-const-local-increment
 * @parent root
 * @summary A const local cannot be incremented.
 * @topic Negative
 */
void Test()
{
	const int Value = 1;
	Value++;
}
/** @end */
