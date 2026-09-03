/**
 * Assigning an FVector to an FRotator is rejected: the two structs are
 * distinct types even though both hold three floats. This file is the illegal
 * program itself.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitVectorToRotator
 * @Harness CompileReject
 * @Tag Language.Casting.ImplicitVectorToRotator
 * @Kind CompileReject
 * @Covers Casting.ImplicitConversion
 * @Inputs FRotator R = V where V is an FVector
 * @Return does not compile; diagnostic "implicit FVector to FRotator conversion should fail"
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 */

void Test()
{
	FVector V = FVector(1, 0, 0);
	FRotator R = V;
}
