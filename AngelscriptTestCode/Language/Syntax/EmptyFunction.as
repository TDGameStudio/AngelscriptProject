/**
 * @version v1
 * @summary Empty function bodies without observation wrappers.
 * @topic Language
 * @topic Syntax
 *
 * empty-function
 * empty-void-no-statements
 * empty-inner-block
 */
/**
 * @begin empty-function
 * @summary An empty void function and an empty int function that still returns.
 */
void EmptyVoid()
{
}

int EmptyThenReturn()
{
	return 0;
}
/** @end */
/**
 * @begin empty-void-no-statements
 * @summary A void function whose body contains no statements.
 * @topic Syntax
 */
void Empty()
{
}
/** @end */
/**
 * @begin empty-inner-block
 * @summary A function whose only statement is an empty block.
 * @topic Syntax
 */
void EmptyBlock()
{
	{
	}
}
/** @end */
