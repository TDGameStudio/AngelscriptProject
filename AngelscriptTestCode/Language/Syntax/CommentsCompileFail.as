/**
 * @version v1
 * @summary Compile-fail cases for Comments.
 * @topic Language
 * @topic Syntax
 *
 * invalid-unterminated-block-comment    // A block comment must close.
 */
/**
 * @begin invalid-unterminated-block-comment
 * @summary A block comment must close.
 * @topic Negative
 */
int Test()
{
	/* unterminated
	return 1;
}
/** @end */
