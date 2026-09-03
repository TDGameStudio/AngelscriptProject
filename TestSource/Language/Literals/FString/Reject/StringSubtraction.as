/**
 * Subtracting one string from another is rejected: subtraction has no meaning
 * for text. This file is the illegal program itself; do not rewrite it with a
 * removal call, since the unsupported operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringSubtraction
 * @Harness CompileReject
 * @Tag Language.Literals.StringSubtraction
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs A - "lo" where A is an FString
 * @Return does not compile; diagnostic "operator '-' is not supported for FString"
 */

void Test()
{
	FString A = "Hello";
	FString B = A - "lo";
}
