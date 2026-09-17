/**
 * @version v1
 * @summary Doubling the braces in an interpolated string is not an escape: this fork reads the doubled brace as malformed rather than as a literal brace. This file is the illegal program itself; do not collapse the braces, since.
 * @topic Language
 */
/**
 * @version root
 * @summary Doubling the braces in an interpolated string is not an escape: this fork reads the doubled brace as malformed rather than as a literal brace. This file is the illegal program itself; do not collapse the braces, since.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 5;
	FString S = f"Value is {{X}}";
}
/** @end */
