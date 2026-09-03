/**
 * Casting to a struct is rejected: the template argument must be an
 * object-derived class. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ToStruct
 * @Harness CompileReject
 * @Tag Language.Casting.CastToStruct
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<FVector>(A) where A is an actor
 * @Return does not compile; diagnostic "Cast to struct type should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast to struct type should fail".
 */

void Test(AActor A)
{
	auto X = Cast<FVector>(A);
}
