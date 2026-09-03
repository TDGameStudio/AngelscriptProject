/**
 * Casting with two template arguments is rejected: this fork's Cast takes a
 * single target type and infers the source. This file is the illegal program
 * itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.WithTwoTemplateArguments
 * @Harness CompileReject
 * @Tag Language.Casting.CastWithTwoTemplateArguments
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<APawn, AActor>(A) with two template arguments
 * @Return does not compile; diagnostic "Cast with two template arguments should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast with two template arguments should fail".
 */

/** */
void Test(AActor A)
{
	auto X = Cast<APawn, AActor>(A);
}
