/**
 * A non-interface function declared without a body is rejected. This file is the
 * illegal program itself; do not add a body, since its absence is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionWithoutBody
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FunctionWithoutBody
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a function declaration terminated with a semicolon
 * @Return does not compile; diagnostic "No body (non-interface)"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=37788acb30380bf32c0858251b9310b79190c5c02c55661a451bbb46fb7a73a3; lines 686-688.
 * @Provenance Expected diagnostic: "No body (non-interface)". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function declaration terminated with a semicolon instead of a body.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
void Foo();
