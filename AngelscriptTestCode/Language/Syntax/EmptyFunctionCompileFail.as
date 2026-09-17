/**
 * @version v1
 * @summary Compile-fail cases for EmptyFunction.
 * @topic Language
 * @topic Syntax
 *
 * invalid-function-without-body
 * invalid-function-missing-braces
 */
/**
 * @begin invalid-function-without-body
 * @summary A function declaration without a body is invalid in this corpus.
 * @topic Negative
 */
void MissingBody();
/** @end */
/**
 * @begin invalid-function-missing-braces
 * @summary A function body cannot be a bare semicolon.
 * @topic Negative
 */
void MissingBraces();
int Test()
{
	return 0
}
/** @end */
