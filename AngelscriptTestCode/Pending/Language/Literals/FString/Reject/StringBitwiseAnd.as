/**
 * @version v1
 * @summary Applying a bitwise and to two strings is rejected: bitwise operators do not apply to text. This file is the illegal program itself; do not rewrite it with a concatenation, since the unsupported operator is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Applying a bitwise and to two strings is rejected: bitwise operators do not apply to text. This file is the illegal program itself; do not rewrite it with a concatenation, since the unsupported operator is the point.
 * @topic Negative
 */
/** */
void Test()
{
	FString A = "Hello";
	auto X = A & "World";
}
/** @end */
