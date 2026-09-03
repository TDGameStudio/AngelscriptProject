/**
 * Calling a private method from outside the declaring class is rejected. This
 * file is the illegal program itself; do not make SecretMethod public, since
 * the outside call is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateMethodCallFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateMethodCallFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function calling A.SecretMethod()
 * @Return does not compile; diagnostic "Calling private method from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private method call from outside.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 2 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Calling private method from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only method is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once SecretMethod is called from outside
 */
class AActorPrivMethod : AActor
{
	/**
	 * A private method that outsiders must not call.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return nothing; the outside call is rejected first
	 */
	private void SecretMethod()
	{
	}
}

/**
 * Attempt to call the private method from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorPrivMethod A;
	A.SecretMethod();
}
