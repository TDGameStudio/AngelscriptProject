/**
 * A struct member of type void is rejected. This file is the illegal program
 * itself; do not replace void with int, since the void declaration is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructVoidMember
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.StructVoidMember
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a member declared with type void
 * @Return does not compile; diagnostic "void is not a valid member type for X"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=37540d53c2b7df406ed1aaa84c1e7ca571adb54cda52a969bc8e20aa30ecea8f; lines 321-323.
 * @Provenance Expected diagnostic: void is not a valid member type for X.
 * @Provenance DiagnosticOnly. Do not replace void with int.
 */

/**
 * A struct whose member type is void.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FStructVoidMember
{
	/**
	 * The member whose void type is the point.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void X;
}
