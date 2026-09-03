/**
 * Casting a primitive value is rejected: Cast applies to object handles, not
 * to numeric conversions. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.OnPrimitive
 * @Harness CompileReject
 * @Tag Language.Casting.CastOnPrimitive
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<float>(X) where X is an int
 * @Return does not compile; diagnostic "Cast on primitive type should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast on primitive type should fail".
 */

/** */
void Test()
{
	int X = 5;
	auto Y = Cast<float>(X);
}
