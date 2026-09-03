/**
 * Calling a protected method from a free function is rejected. This file is
 * the illegal program itself; do not make InternalMethod public, since the
 * outside call is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.ProtectedMethodCallFromOutside
 * @Harness CompileReject
 * @Tag Feature.Access.ProtectedMethodCallFromOutside
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a free function calling A.InternalMethod()
 * @Return does not compile; diagnostic "Calling protected method from outside"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: protected method call from a free function.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 9 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Calling protected method from outside".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only method is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once InternalMethod is called from outside
 */
class AActorProtMethodOut : AActor
{
	/**
	 * A protected method that free functions must not call.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return nothing; the outside call is rejected first
	 */
	protected void InternalMethod()
	{
	}
}

/**
 * Attempt to call the protected method from a free function.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	AActorProtMethodOut A;
	A.InternalMethod();
}
