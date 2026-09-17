/**
 * @version v1
 * @summary String text that looks like a directive but is only source characters.
 * @topic Language
 * @topic Preprocessor
 */
/**
 * @version root
 * @summary A string literal contains #if text that is not a directive.
 * @topic Baseline
 * @topic SourceOnly
 */
int CountLiteral()
{
	string Text = "#if 0 this is not a directive";
	return Text.length();
}
/** @end */
/**
 * @version valid-elif-in-string
 * @parent root
 * @summary Elif text inside quotes remains a string payload.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int ElifLiteral()
{
	string Text = "#elif NEVER";
	return Text.length();
}
/** @end */
/**
 * @version invalid-directive-outside-string
 * @parent root
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
 * @version valid-endif-in-string
 * @parent root
 * @summary Endif text inside quotes is not a directive.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Count()
{
	string Text = "#endif";
	return Text.length();
}
/** @end */
/**
 * @version valid-if-in-line-comment
 * @parent root
 * @summary A line comment may contain #if text.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Count()
{
	// #if 0 this is a comment
	return 1;
}
/** @end */
/**
 * @version valid-if-in-block-comment
 * @parent root
 * @summary A block comment may contain #endif text.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Count()
{
	/* #endif */
	return 1;
}
/** @end */
/**
 * @version invalid-include-directive
 * @parent root
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
