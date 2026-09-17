/**
 * @version v1
 * @summary String text that looks like a directive but is only source characters.
 * @topic Language
 * @topic Preprocessor
 *
 * directive-in-string        // A string literal contains #if text that is not a directive.
 * elif-in-string             // Elif text inside quotes remains a string payload.
 * endif-in-string            // Endif text inside quotes is not a directive.
 * if-in-line-comment         // A line comment may contain #if text.
 * if-in-block-comment        // A block comment may contain #endif text.
 * define-looking-string      // Define text inside quotes remains a string payload.
 * include-looking-comment    // A line comment may contain #include text.
 */
/**
 * @begin directive-in-string
 * @summary A string literal contains #if text that is not a directive.
 * @topic SourceOnly
 */
int CountLiteral()
{
	string Text = "#if 0 this is not a directive";
	return Text.length();
}
/** @end */
/**
 * @begin elif-in-string
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
 * @begin endif-in-string
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
 * @begin if-in-line-comment
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
 * @begin if-in-block-comment
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
 * @begin define-looking-string
 * @summary Define text inside quotes remains a string payload.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int DefineLiteral()
{
	string Text = "#define LOOKS_LIKE";
	return Text.length();
}
/** @end */
/**
 * @begin include-looking-comment
 * @summary A line comment may contain #include text.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Count()
{
	// #include "looks.as"
	return 1;
}
/** @end */
