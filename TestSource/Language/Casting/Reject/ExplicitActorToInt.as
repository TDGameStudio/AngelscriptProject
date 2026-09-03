/**
 * Converting an actor handle to an int is rejected: object handles are not
 * numeric, so there is no numeric conversion to apply. This file is the
 * illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitActorToInt
 * @Harness CompileReject
 * @Tag Language.Casting.ExplicitActorToInt
 * @Kind CompileReject
 * @Covers Casting.ExplicitConversion
 * @Inputs int(A) where A is an actor
 * @Return does not compile; diagnostic "object to int conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
 */

void Test(AActor A)
{
	int X = int(A);
}
