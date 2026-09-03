/**
 * Assigning a TArray to an int is rejected: a container has no implicit
 * scalar value. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitArrayToInt
 * @Harness CompileReject
 * @Tag Language.Casting.ImplicitArrayToInt
 * @Kind CompileReject
 * @Covers Casting.ImplicitConversion
 * @Inputs int X = Arr where Arr is a TArray<int>
 * @Return does not compile; diagnostic "implicit container to int conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 */

/** */
void Test()
{
	TArray<int> Arr;
	int X = Arr;
}
