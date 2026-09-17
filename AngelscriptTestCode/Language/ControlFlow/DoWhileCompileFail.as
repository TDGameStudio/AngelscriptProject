/**
 * @version v1
 * @summary Compile-fail cases for DoWhile.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-do-without-while
 * invalid-do-while-integer-condition
 * invalid-do-while-missing-semicolon
 * invalid-do-while-empty-condition
 * invalid-do-while-missing-parens
 */
/**
 * @begin invalid-do-without-while
 * @summary A do body must be followed by while.
 * @topic Negative
 */
void Test()
{
	do
	{
		return;
	}
}
/** @end */
/**
 * @begin invalid-do-while-integer-condition
 * @summary Compile-rejection form retained from legacy do while integer condition.
 * @topic Negative
 */
void Test()
{
	do
	{
	} while (1);
}
/** @end */
/**
 * @begin invalid-do-while-missing-semicolon
 * @summary Compile-rejection form retained from legacy do while missing semicolon.
 * @topic Negative
 */
void Test()
{
	do
	{
	} while (true)
}
/** @end */
/**
 * @begin invalid-do-while-empty-condition
 * @summary Do-while condition cannot be empty.
 * @topic Negative
 */
void Test()
{
	do
	{
	}
	while ();
}
/** @end */
/**
 * @begin invalid-do-while-missing-parens
 * @summary Do-while condition must be parenthesized.
 * @topic Negative
 */
void Test()
{
	do
	{
	}
	while true;
}
/** @end */
