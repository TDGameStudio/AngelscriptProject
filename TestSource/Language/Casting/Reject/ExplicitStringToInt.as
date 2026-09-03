/**
 * Converting an FString to an int with an explicit conversion is rejected:
 * string parsing is not a conversion constructor here. This file is the
 * illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitStringToInt
 * @Harness CompileReject
 * @Tag Language.Casting.ExplicitStringToInt
 * @Kind CompileReject
 * @Covers Casting.ExplicitConversion
 * @Inputs int(S) where S is an FString
 * @Return does not compile; diagnostic "string to int conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
 */

/** */
void Test()
{
	FString S = "hello";
	int X = int(S);
}
