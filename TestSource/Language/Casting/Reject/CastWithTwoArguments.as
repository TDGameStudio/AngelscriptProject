/**
 * Casting with two source arguments is rejected: Cast converts one handle, so
 * a second argument has no meaning. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.WithTwoArguments
 * @Harness CompileReject
 * @Tag Language.Casting.CastWithTwoArguments
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<APawn>(A, B) with two source arguments
 * @Return does not compile; diagnostic "Cast with two arguments should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast with two arguments should fail".
 */

/** */
void Test(AActor A, AActor B)
{
	auto X = Cast<APawn>(A, B);
}
