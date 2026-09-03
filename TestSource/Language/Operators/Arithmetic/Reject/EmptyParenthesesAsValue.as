/**
 * An empty pair of parentheses used as a value is rejected: there is no
 * expression inside to evaluate. This file is the illegal program itself; do
 * not supply an expression, since the empty parentheses are the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.EmptyParenthesesAsValue
 * @Harness CompileReject
 * @Tag Language.Operators.EmptyParenthesesAsValue
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs () assigned to an int
 * @Return does not compile; diagnostic "Empty parentheses as value"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
 * @Provenance sha256=e7950e42833fa3b379db54291222977ebeaca4f61e566defb566e894907bb8e6; lines 674-676.
 * @Provenance CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
 * @Provenance Expected compile failure: "Empty parentheses as value".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	int X = ();
}
