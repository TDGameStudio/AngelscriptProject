/**
 * Reading a protected member from an unrelated class is rejected. This file
 * is the illegal program itself; do not derive AOtherActor from AActorProtUnrel,
 * since the unrelated read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.ProtectedMemberReadFromUnrelatedClass
 * @Harness CompileReject
 * @Tag Feature.Access.ProtectedMemberReadFromUnrelatedClass
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs an unrelated actor reading A.ProtVal
 * @Return does not compile; diagnostic "Accessing protected from unrelated class"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: protected member read from an unrelated class.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 4 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Accessing protected from unrelated class".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor whose only member is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once ProtVal is read from an unrelated class
 */
class AActorProtUnrel : AActor
{
	protected int ProtVal = 10;
}

/**
 * An unrelated actor that tries to read the protected member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class AOtherActor : AActor
{
	/**
	 * Attempt to read ProtVal from a type that does not inherit it.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		AActorProtUnrel A;
		int X = A.ProtVal;
	}
}
