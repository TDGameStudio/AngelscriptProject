/**
 * Declaring a class member with a type that does not exist is rejected. This file
 * is the illegal program itself; do not replace the member type with int, since
 * the unknown type is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ClassInvalidMemberType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ClassInvalidMemberType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a member declared with the unknown type NonExistentType
 * @Return does not compile; diagnostic "NonExistentType is not a known type for member X"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=25ca624ace26c8855a4e78af461170e796237e6797e14a4bbf3fe5a6408c2a25; lines 164-169.
 * @Provenance Expected diagnostic: NonExistentType is not a known type for member X.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class AClassBadMemberActor : AActor
{
	NonExistentType X;
}
