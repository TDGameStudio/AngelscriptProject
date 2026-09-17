/**
 * @version v1
 * @summary Assigning to a const value parameter is rejected: the parameter is const for the whole body, so it cannot be used as a scratch variable. This file is the illegal program itself; do not drop the const to make it compile.
 * @topic Language
 * @topic Const
 */
/**
 * @version root
 * @summary Assigning to a const value parameter is rejected: the parameter is const for the whole body, so it cannot be used as a scratch variable. This file is the illegal program itself; do not drop the const to make it compile.
 * @topic Negative
 */
/** */
void Test(const int Value)
{
	Value = 2;
}
/** @end */
/**
 * @version invalid-const-param-compound
 * @parent root
 * @summary A const value parameter cannot be the target of a compound assignment.
 * @topic Negative
 */
void Test(const int Value)
{
	Value += 1;
}
/** @end */
/**
 * @version invalid-const-param-increment
 * @parent root
 * @summary A const value parameter cannot be incremented.
 * @topic Negative
 */
void Test(const int Value)
{
	Value++;
}
/** @end */
