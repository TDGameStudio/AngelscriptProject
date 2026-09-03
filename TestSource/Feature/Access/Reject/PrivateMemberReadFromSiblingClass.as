/**
 * Reading a private member from a sibling class is rejected. Sharing a base
 * does not grant access to a sibling's private field. This file is the illegal
 * program itself; do not make X public, since the sibling read is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.PrivateMemberReadFromSiblingClass
 * @Harness CompileReject
 * @Tag Feature.Access.PrivateMemberReadFromSiblingClass
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a sibling actor reading A.X
 * @Return does not compile; diagnostic "Accessing private from sibling class"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: private member read from a sibling class.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 13 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Accessing private from sibling class".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * A shared base that grants no private access between siblings.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once a sibling reads the other sibling's private field
 */
class ABase : AActor
{
}

/**
 * One sibling that holds a private field.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once X is read from the other sibling
 */
class ASiblingA : ABase
{
	private int X = 1;
}

/**
 * The other sibling, which tries to read the private field.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class ASiblingB : ABase
{
	/**
	 * Attempt to read the sibling's private member.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		ASiblingA A;
		int Y = A.X;
	}
}
