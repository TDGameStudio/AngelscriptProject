/**
 * An explicit conversion with several arguments is rejected: a conversion
 * takes exactly one value. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitMultipleArguments
 * @Harness CompileReject
 * @Tag Language.Casting.ExplicitMultipleArguments
 * @Kind CompileReject
 * @Covers Casting.ExplicitConversion
 * @Inputs int(1, 2, 3) with three arguments
 * @Return does not compile; diagnostic "conversion with multiple arguments should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
 */

/** */
void Test()
{
	int X = int(1, 2, 3);
}
