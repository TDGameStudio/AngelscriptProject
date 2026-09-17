/**
 * @version v1
 * @summary Empty function bodies without observation wrappers.
 * @topic Language
 * @topic Syntax
 *
 * empty-function                 // An empty void function and an empty int function that still returns.
 * empty-void-no-statements       // A void function whose body contains no statements.
 * empty-inner-block              // A function whose only statement is an empty block.
 * empty-void-trailing-comment    // An empty void function followed by a trailing comment.
 * empty-global-void              // An empty void function at global scope.
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
/**
 * @begin empty-void-trailing-comment
 * @summary An empty void function followed by a trailing comment.
 * @topic Syntax
 */
void EmptyTrailing()
{
} // trailing
/** @end */
/**
 * @begin empty-global-void
 * @summary An empty void function at global scope.
 * @topic Syntax
 */
void GlobalEmpty()
{
}
/** @end */
