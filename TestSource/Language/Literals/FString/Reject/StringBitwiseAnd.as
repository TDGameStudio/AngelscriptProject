/**
 * Applying a bitwise and to two strings is rejected: bitwise operators do not
 * apply to text. This file is the illegal program itself; do not rewrite it
 * with a concatenation, since the unsupported operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringBitwiseAnd
 * @Harness CompileReject
 * @Tag Language.Literals.StringBitwiseAnd
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs A & "World" where A is an FString
 * @Return does not compile; diagnostic "operator '&' is not supported for FString"
 */

void Test()
{
	FString A = "Hello";
	auto X = A & "World";
}
