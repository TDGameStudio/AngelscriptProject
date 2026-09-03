/**
 * Declaring the same enumerator name twice in one enum is rejected. This file is
 * the illegal program itself; do not rename the second enumerator, since the
 * collision is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DuplicateEnumerator
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DuplicateEnumerator
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an enum declaring Value1 twice
 * @Return does not compile; diagnostic "Value1 is declared twice"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=63d7ab5e068d512097c6160e4cc3fef4489b07b9368226687f2218742c22e155; lines 386-388.
 * @Provenance Expected diagnostic: Value1 is declared twice in EEnumDupVal.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

enum EEnumDupVal
{
	Value1,
	Value1
}
