/**
 * @version v1
 * @summary Declaring a default argument from a string literal for an FText parameter is rejected: the literal is an FString and does not convert to text implicitly. This file is the illegal program itself; do not rewrite the.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring a default argument from a string literal for an FText parameter is rejected: the literal is an FString and does not convert to text implicitly. This file is the illegal program itself; do not rewrite the.
 * @topic Negative
 */
/**
 * Declare the failing string-literal default argument for an FText parameter.
 */
FString TextDefaultLiteral(FText text = "DefaultText")
{
	return text.ToString();
}

/**
 * Invoke the failing default argument implicitly.
 */
FString TextDefaultLiteralImplicit()
{
	return TextDefaultLiteral();
}
/** @end */
