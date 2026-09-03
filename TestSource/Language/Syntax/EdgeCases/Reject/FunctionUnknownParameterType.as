/**
 * A function whose parameter type does not exist is rejected. This file is the
 * illegal program itself; do not replace the type, since the unknown name is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionUnknownParameterType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FunctionUnknownParameterType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a parameter type that was never declared
 * @Return does not compile; diagnostic "Non-existent param type"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=d95f4dfe5a24de1191f7e4a582d196a14d680fc12d056f1a52620a6368d74521; lines 711-713.
 * @Provenance Expected diagnostic: "Non-existent param type". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function whose parameter type was never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo(NonExistentType X)
{
}
