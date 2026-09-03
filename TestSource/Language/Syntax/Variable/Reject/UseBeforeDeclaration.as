/**
 * Reading a local before it is declared is rejected. This file is the illegal
 * program itself; do not reorder the declarations, since the forward reference is
 * the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.UseBeforeDeclaration
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.UseBeforeDeclaration
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs a local read on the line before it is declared
 * @Return does not compile; diagnostic "Use before declaration"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 8 AssertFailsToCompile.
 * @Provenance sha256=9c99c253ead1b2be40b5b95eb89af778f84bfcb1664802b5a5229ad99936f6d9; lines 616-618.
 * @Provenance Expected diagnostic: "Use before declaration". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to read a local before declaring it.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int Y = X;
	int X = 5;
}
