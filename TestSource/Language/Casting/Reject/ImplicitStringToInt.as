/**
 * Assigning an FString to an int is rejected: string parsing is not an
 * implicit conversion. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitStringToInt
 * @Harness CompileReject
 * @Tag Language.Casting.ImplicitStringToInt
 * @Kind CompileReject
 * @Covers Casting.ImplicitConversion
 * @Inputs int X = S where S is an FString
 * @Return does not compile; diagnostic "implicit string to int conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 */

/** */
void Test()
{
	FString S = "5";
	int X = S;
}
