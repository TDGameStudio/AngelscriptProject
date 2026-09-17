/**
 * @version v1
 * @summary A string literal that opens a quote and never closes it is rejected: the lexer reaches the end of the line without finding the closing quote. This file is the illegal program itself; do not add the missing quote, since.
 * @topic Language
 */
/**
 * @version root
 * @summary A string literal that opens a quote and never closes it is rejected: the lexer reaches the end of the line without finding the closing quote. This file is the illegal program itself; do not add the missing quote, since.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = "unterminated;
}
/** @end */
