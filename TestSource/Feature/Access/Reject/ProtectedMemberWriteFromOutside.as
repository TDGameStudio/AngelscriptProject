/**
 * Writing a protected member from a free function is rejected. This file is
 * the illegal program itself; do not make ProtVal public, since the outside
 * write is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.ProtectedMemberWriteFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.ProtectedMemberWriteFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function assigning A.ProtVal = 99
 * @Return does not compile; diagnostic "Writing to protected member from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: protected member write from a free function.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 11 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Writing to protected member from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only member is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once ProtVal is written from outside
 */
class AActorProtWrite : AActor
{
	protected int ProtVal = 0;
}

/**
 * Attempt to write the protected member from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorProtWrite A;
	A.ProtVal = 99;
}
