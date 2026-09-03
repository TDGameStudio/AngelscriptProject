/**
 * Casting to a class that was never declared is rejected: the template
 * argument must name a type that exists. This file is the illegal program
 * itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ToUndeclaredClass
 * @Harness CompileReject
 * @Tag Language.Casting.CastToUndeclaredClass
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<NonExistentClass>(A) where NonExistentClass was never declared
 * @Return does not compile; diagnostic "Cast to non-existent type should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "Cast to non-existent type should fail".
 */

void Test(AActor A)
{
	auto X = Cast<NonExistentClass>(A);
}
