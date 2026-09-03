/**
 * Declaring a method inside an enum is rejected. This file is the illegal program
 * itself; do not move the method out of the enum, since being inside it is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.MethodInsideEnum
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.MethodInsideEnum
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an enum body containing a method declaration
 * @Return does not compile; diagnostic "methods are not allowed in enum"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=3199251df53905906f1862ac16243d33cb37abb36a898aedc0a7dbfa2397f251; lines 417-419.
 * @Provenance Expected diagnostic: methods are not allowed in enum EEnumMethod.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

enum EEnumMethod
{
	Value1;
/** */
	void Foo()
	{
	}
}
