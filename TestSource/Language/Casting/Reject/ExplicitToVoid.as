/**
 * Converting to void is rejected: void is not a value type that can hold a
 * converted result. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitToVoid
 * @Harness CompileReject
 * @Tag Language.Casting.ExplicitToVoid
 * @Kind CompileReject
 * @Covers Casting.ExplicitConversion
 * @Inputs void(X) where X is an int
 * @Return does not compile; diagnostic "conversion to void should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
 */

/** */
void Test()
{
	int X = 5;
	void(X);
}
