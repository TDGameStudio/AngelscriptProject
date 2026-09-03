/**
 * A struct member whose type does not exist is rejected. This file is the illegal
 * program itself; do not replace the member type with int, since the unknown type
 * is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructInvalidMemberType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.StructInvalidMemberType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a member declared with the unknown NonExistentType
 * @Return does not compile; diagnostic "NonExistentType is not a known type for member X"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=7a8046467be3c260491d762706625b46d3430becce88e913c9b718f60fb4c1ff; lines 291-293.
 * @Provenance Expected diagnostic: NonExistentType is not a known type for member X.
 * @Provenance DiagnosticOnly. Do not replace the member type with int.
 */

/**
 * A struct whose member type was never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FStructBadMember
{
	/**
	 * The member whose unknown type is the point.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	NonExistentType X;
}
