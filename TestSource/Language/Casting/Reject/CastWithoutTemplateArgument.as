/**
 * Casting without a template argument is rejected: the target type cannot be
 * inferred the way auto infers a local. This file is the illegal program
 * itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.WithoutTemplateArgument
 * @Harness CompileReject
 * @Tag Language.Casting.CastWithoutTemplateArgument
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast(A) with no template argument
 * @Return does not compile; diagnostic "Cast without template argument should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast without template argument should fail".
 */

/** */
void Test(AActor A)
{
	auto X = Cast(A);
}
