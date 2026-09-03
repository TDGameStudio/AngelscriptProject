/**
 * Using void as a parameter type is rejected. This file is the illegal program
 * itself; do not give the parameter a real type, since the void declaration is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.VoidParameterType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.VoidParameterType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a parameter declared with type void
 * @Return does not compile; diagnostic "Void parameter"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 7 AssertFailsToCompile.
 * @Provenance sha256=b71b890437955900d9561a48b297dd3a688ed51aafb8e75d97caa1549f33d7c8; lines 717-719.
 * @Provenance Expected diagnostic: "Void parameter". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function declaring a parameter of type void.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(void X)
{
}
