/**
 * @version v1
 * @summary Compile-fail cases for DirectiveInString.
 * @topic Language
 * @topic Preprocessor
 *
 * invalid-directive-outside-string    // A bare unknown directive token is not valid source.
 * invalid-include-directive           // Include is not a supported source directive in this corpus.
 */
/**
 * @begin invalid-directive-outside-string
 * @summary A bare unknown directive token is not valid source.
 * @topic Negative
 * @topic SourceOnly
 */
int Test()
{
#unknown
	return 1;
}
/** @end */
/**
 * @begin invalid-include-directive
 * @summary Include is not a supported source directive in this corpus.
 * @topic Negative
 * @topic SourceOnly
 */
#include "Missing.as"
int Test()
{
	return 1;
}
/** @end */
