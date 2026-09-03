/**
 * Converting a bool to an FString with an explicit conversion is rejected:
 * formatting a bool as text is not a conversion constructor here. This file
 * is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitBoolToFString
 * @Harness CompileReject
 * @Tag Language.Casting.ExplicitBoolToFString
 * @Kind CompileReject
 * @Covers Casting.ExplicitConversion
 * @Inputs FString(B) where B is a bool
 * @Return does not compile; diagnostic "bool to FString conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
 */

void Test()
{
	bool B = true;
	FString S = FString(B);
}
