/**
 * Casting to an enum type is rejected: the template argument must be an
 * object-derived class. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ToEnum
 * @Harness CompileReject
 * @Tag Language.Casting.CastToEnum
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<ENetRole>(A) where A is an actor
 * @Return does not compile; diagnostic "Cast to enum type should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast to enum type should fail".
 */

void Test(AActor A)
{
	auto X = Cast<ENetRole>(A);
}
