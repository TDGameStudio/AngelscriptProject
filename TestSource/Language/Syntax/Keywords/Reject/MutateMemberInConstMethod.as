/**
 * A const method promises not to modify its object, so assigning a member from
 * inside one is rejected.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.MutateMemberInConstMethod
 * @Harness CompileReject
 * @Tag Language.Syntax.Keywords.MutateMemberInConstMethod
 * @Kind CompileReject
 * @Covers Syntax.Keywords
 * @Inputs a member written from inside a const method
 * @Return does not compile; diagnostic "Modifying member in const method should fail"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=2a6d40814de62287b1f885e69eac98887e789c756b15c995e91dbbc9039b950c; lines 203-209.
 * @Provenance Expected diagnostic: "Modifying member in const method should fail".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * A struct whose const method writes a member.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
struct FStructConstModify
{
	int X = 0;

	/**
	 * Attempt to assign a member from a const method.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return does not compile
	 */
	void Bad() const
	{
		X = 5;
	}
}
