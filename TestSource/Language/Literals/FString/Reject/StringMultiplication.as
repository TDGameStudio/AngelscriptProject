/**
 * Multiplying a string by a number is rejected: repetition is not an operator
 * here. This file is the illegal program itself; do not rewrite it with a loop,
 * since the unsupported operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringMultiplication
 * @Harness CompileReject
 * @Tag Language.Literals.StringMultiplication
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs "abc" * 3
 * @Return does not compile; diagnostic "operator '*' is not supported for FString"
 */

void Test()
{
	FString S = "abc" * 3;
}
