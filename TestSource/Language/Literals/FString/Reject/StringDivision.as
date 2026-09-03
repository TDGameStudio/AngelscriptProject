/**
 * Dividing one string by another is rejected: division has no meaning for
 * text. This file is the illegal program itself; do not rewrite it with a
 * split call, since the unsupported operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringDivision
 * @Harness CompileReject
 * @Tag Language.Literals.StringDivision
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs A / "World" where A is an FString
 * @Return does not compile; diagnostic "operator '/' is not supported for FString"
 */

/** */
void Test()
{
	FString A = "Hello";
	FString B = A / "World";
}
