/**
 * Passing a base handle where a derived type is expected is rejected: the
 * narrowing direction is not implicit, so an explicit Cast is required. This
 * file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitBaseToDerived
 * @Harness CompileReject
 * @Tag Language.Casting.ImplicitBaseToDerived
 * @Kind CompileReject
 * @Covers Casting.ImplicitConversion
 * @Inputs TakePawn(A) where A is an AActor and the parameter is an APawn
 * @Return does not compile; diagnostic "implicit base to derived conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 */

/** */
void TakePawn(APawn P)
{
}

/** */
void Test(AActor A)
{
	TakePawn(A);
}
