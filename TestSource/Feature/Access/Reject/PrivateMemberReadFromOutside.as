/**
 * Reading a private member from outside the declaring class is rejected. This
 * file is the illegal program itself; do not make Secret public, since the
 * outside read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateMemberReadFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateMemberReadFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function reading A.Secret
 * @Return does not compile; diagnostic "Reading private member from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private member read from outside.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 1 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Reading private member from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Secret is read from outside
 */
class AActorPrivRead : AActor
{
	private int Secret = 42;
}

/**
 * Attempt to read the private member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivRead A;
	int X = A.Secret;
}
