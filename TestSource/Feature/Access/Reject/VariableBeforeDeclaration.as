/**
 * Using a local before it is declared is rejected. This file is the illegal
 * program itself; do not reorder the declarations, since the forward reference
 * is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.VariableBeforeDeclaration
 * @Harness CompileReject
 * @Tag Feature.Access.VariableBeforeDeclaration
 * @Kind CompileReject
 * @Covers Access.Scope
 * @Inputs a local read on the line before it is declared
 * @Return does not compile; diagnostic "Use variable before declaration"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: use a local before its declaration.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Negative block 3 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Use variable before declaration".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * Attempt to read a local before declaring it.
 *
 * @Covers Access.Scope
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int Y = X;
	int X = 5;
}
