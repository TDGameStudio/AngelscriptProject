/**
 * @version v1
 * @summary A const local can be read after it is initialized.
 * @topic Language
 * @topic Const
 */
/**
 * @version root
 * @summary const int X = 3 is readable and returns 3.
 * @topic Baseline
 */
int ReadConst()
{
	const int X = 3;
	return X;
}
/** @end */
/**
 * @version valid-const-in-expression
 * @parent root
 * @summary A const local can be used in an arithmetic expression.
 * @topic Const
 */
int Added()
{
	const int X = 3;
	return X + 1;
}
/** @end */
/**
 * @version valid-const-zero
 * @parent root
 * @summary A const local may be initialized to zero.
 * @topic Const
 */
int Zero()
{
	const int X = 0;
	return X;
}
/** @end */
