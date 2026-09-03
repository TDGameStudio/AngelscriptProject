/**
 * A function declaration with no return type is rejected. This file is the illegal
 * program itself; do not add a return type, since its absence is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionWithoutReturnType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FunctionWithoutReturnType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a function declaration with no type before its name
 * @Return does not compile; diagnostic "No return type"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=0d00c304f07aec69a0135caa6160f7bcdf1cdd3131c8818cff1b33916efd4628; lines 680-682.
 * @Provenance Expected diagnostic: "No return type". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

Foo()
{
}
