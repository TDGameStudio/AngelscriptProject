/**
 * Reading a private member from an unrelated class is rejected. This file is
 * the illegal program itself; do not make Secret public, since the unrelated
 * read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateMemberReadFromUnrelatedClass
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateMemberReadFromUnrelatedClass
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs an unrelated actor reading A.Secret
 * @Return does not compile; diagnostic "Reading private from unrelated class"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private member read from an unrelated class.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 10 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Reading private from unrelated class".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Secret is read from an unrelated class
 */
class AActorPrivViaUnrel : AActor
{
	private int Secret = 42;
}

/**
 * An unrelated actor that tries to read the private member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class AOther : AActor
{
	/**
	 * Attempt to read Secret from a type that does not declare it.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		AActorPrivViaUnrel A;
		int X = A.Secret;
	}
}
