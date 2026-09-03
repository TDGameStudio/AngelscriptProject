/**
 * Casting between unrelated types is rejected: an FString is not part of the
 * actor hierarchy, so there is no conversion to attempt. This file is the
 * illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.BetweenUnrelatedTypes
 * @Harness CompileReject
 * @Tag Language.Casting.CastBetweenUnrelatedTypes
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<AActor>(S) where S is an FString
 * @Return does not compile; diagnostic "Cast between unrelated types should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast between unrelated types should fail".
 */

void Test()
{
	FString S = "hello";
	auto X = Cast<AActor>(S);
}
