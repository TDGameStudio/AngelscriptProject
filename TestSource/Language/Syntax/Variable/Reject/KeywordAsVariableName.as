/**
 * A reserved keyword cannot serve as a variable name, so such a local is
 * rejected. This file is the illegal program itself; do not rename the variable,
 * since the keyword collision is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.KeywordAsVariableName
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.KeywordAsVariableName
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs a local named class
 * @Return does not compile; diagnostic "Keyword as variable name"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=ddc232de4f2a730c8c1f3782cfcdb981ee2cdda0075376b5f7587bf14907713e; lines 604-606.
 * @Provenance Expected diagnostic: "Keyword as variable name". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to declare a local named with a reserved keyword.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int class = 0;
}
