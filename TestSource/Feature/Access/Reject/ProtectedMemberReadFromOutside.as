/**
 * Reading a protected member from a free function is rejected. This file is
 * the illegal program itself; do not make ProtVal public, since the outside
 * read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.ProtectedMemberReadFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.ProtectedMemberReadFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function reading A.ProtVal
 * @Return does not compile; diagnostic "Accessing protected member from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: protected member read from a free function.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 3 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Accessing protected member from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only member is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once ProtVal is read from outside
 */
class AActorProtOut : AActor
{
	protected int ProtVal = 10;
}

/**
 * Attempt to read the protected member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorProtOut A;
	int X = A.ProtVal;
}
