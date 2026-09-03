/**
 * Calling a private Init method from outside the declaring class is rejected.
 * This file is the illegal program itself; do not make Init public, since the
 * outside call is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateInitCallFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateInitCallFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function calling A.Init()
 * @Return does not compile; diagnostic "Calling private Init from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private Init method call from outside.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 12 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Calling private Init from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose Init method is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Init is called from outside
 */
class AActorPrivStatic : AActor
{
	/**
	 * A private Init method that outsiders must not call.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return nothing; the outside call is rejected first
	 */
	private void Init()
	{
	}
}

/**
 * Attempt to call the private Init method from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivStatic A;
	A.Init();
}
