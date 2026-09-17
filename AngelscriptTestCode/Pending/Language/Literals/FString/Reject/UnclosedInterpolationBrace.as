/**
 * @version v1
 * @summary An interpolated string whose brace is never closed is rejected: the interpolation needs a matching closing brace. This file is the illegal program itself; do not add the brace, since the unclosed interpolation is the.
 * @topic Language
 */
/**
 * @version root
 * @summary An interpolated string whose brace is never closed is rejected: the interpolation needs a matching closing brace. This file is the illegal program itself; do not add the brace, since the unclosed interpolation is the.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 5;
	FString S = f"Value is {X";
}
/** @end */
