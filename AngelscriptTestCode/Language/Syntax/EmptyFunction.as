/**
 * @version v1
 * @summary Empty function bodies without observation wrappers.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary An empty void function and an empty int function that still returns.
 * @topic Baseline
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
 * @version invalid-function-without-body
 * @parent root
 * @summary A function declaration without a body is invalid in this corpus.
 * @topic Negative
 */
void MissingBody();
/** @end */
/**
 * @version valid-empty-void-no-statements
 * @parent root
 * @summary A void function whose body contains no statements.
 * @topic Syntax
 */
void Empty()
{
}
/** @end */
/**
 * @version valid-empty-inner-block
 * @parent root
 * @summary A function whose only statement is an empty block.
 * @topic Syntax
 */
void EmptyBlock()
{
	{
	}
}
/** @end */
/**
 * @version invalid-function-missing-braces
 * @parent root
 * @summary A function body cannot be a bare semicolon.
 * @topic Negative
 */
void MissingBraces();
int Test()
{
	return 0
}
/** @end */
