/**
 * Assigning an int to a bool is rejected: an integer is not implicitly
 * truthy, so the comparison has to be written out. This file is the illegal
 * program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitIntToBool
 * @Harness CompileReject
 * @Tag Language.Casting.ImplicitIntToBool
 * @Kind CompileReject
 * @Covers Casting.ImplicitConversion
 * @Inputs bool B = X where X is an int
 * @Return does not compile; diagnostic "implicit int to bool conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 */

void Test()
{
	int X = 1;
	bool B = X;
}
