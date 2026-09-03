/**
 * Assigning to a Cast result is rejected: the converted handle is not an
 * assignable lvalue. This file is the illegal program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ResultAssignment
 * @Harness CompileReject
 * @Tag Language.Casting.CastResultAssignment
 * @Kind CompileReject
 * @Covers Casting.Cast
 * @Inputs Cast<APawn>(A) = nullptr
 * @Return does not compile; diagnostic "assignment to a Cast result should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
 * @Provenance Expected compile failure: "assignment to a Cast result should fail".
 */

void Test(AActor A)
{
	Cast<APawn>(A) = nullptr;
}
