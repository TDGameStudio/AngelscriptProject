/**
 * Declaring the same local name twice in one scope is rejected. This file is the
 * illegal program itself; do not rename either local, since the collision is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.DuplicateLocalVariable
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.DuplicateLocalVariable
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs two locals named X in one scope
 * @Return does not compile; diagnostic "Duplicate variable"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=fbd99f3fd6d2f5a8f5e23d00b073a1e41e0d787bf958110c34228796a1e8ade8; lines 577-579.
 * @Provenance Expected diagnostic: "Duplicate variable". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to declare two locals with the same name in one scope.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int X = 1;
	int X = 2;
}
