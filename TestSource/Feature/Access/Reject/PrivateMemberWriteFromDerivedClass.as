/**
 * Writing a private base member from a derived class is rejected. This file
 * is the illegal program itself; do not make Secret protected, since the
 * derived write is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateMemberWriteFromDerivedClass
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateMemberWriteFromDerivedClass
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a derived method assigning Secret = 10
 * @Return does not compile; diagnostic "Accessing private member from derived class"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private base member written from a derived class.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 5 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Accessing private member from derived class".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * A base actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Secret is written from a derived class
 */
class ABaseActorPrivDeriv : AActor
{
	private int Secret = 42;
}

/**
 * A derived actor that tries to write the private base member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class ADerivedActorPriv : ABaseActorPrivDeriv
{
	/**
	 * Attempt to assign the private base member.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		Secret = 10;
	}
}
