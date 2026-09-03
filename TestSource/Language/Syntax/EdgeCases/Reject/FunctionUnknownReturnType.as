/**
 * A function whose return type does not exist is rejected. This file is the
 * illegal program itself; do not replace the type, since the unknown name is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionUnknownReturnType
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FunctionUnknownReturnType
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a return type that was never declared
 * @Return does not compile; diagnostic "Non-existent return type"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=648fed7dffb970b1ea085eb80e46f8b46602fd6ee5c27aa98bcc15bc91b83290; lines 705-707.
 * @Provenance Expected diagnostic: "Non-existent return type". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function whose return type was never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
NonExistentType Foo()
{
}
