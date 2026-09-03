/**
 * A function body left unclosed is rejected. This file is the illegal program
 * itself; do not close the function body, since the missing brace is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UnmatchedOpeningBrace
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.UnmatchedOpeningBrace
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a function whose body is never closed
 * @Return does not compile; diagnostic "unmatched opening brace"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=ed17ddd5ad2df64ba2fe118e49a50f59a79d07df08afafb581175d2474fe781a; lines 280-282.
 * @Provenance Expected diagnostic: unmatched opening brace / missing closing brace.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

void Test()
{
	int X = 1;
