/**
 * Writing a private member from outside the declaring class is rejected. This
 * file is the illegal program itself; do not make X public, since the outside
 * write is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateMemberWriteFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateMemberWriteFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function assigning A.X = 5
 * @Return does not compile; diagnostic "Writing to private member from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private member write from outside.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 8 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Writing to private member from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once X is written from outside
 */
class AActorPrivWrite : AActor
{
	private int X = 0;
}

/**
 * Attempt to write the private member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivWrite A;
	A.X = 5;
}
