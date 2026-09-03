/**
 * Casting with no argument at all is rejected: the call needs a source
 * handle to convert. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.WithoutArgument
 * @Harness CompileReject
 * @Tag Language.Casting.CastWithoutArgument
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<AActor>() with no source argument
 * @Return does not compile; diagnostic "Cast without an argument should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast without an argument should fail".
 */

void Test()
{
	auto X = Cast<AActor>();
}
