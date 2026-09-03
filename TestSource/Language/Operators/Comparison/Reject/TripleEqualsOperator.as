/**
 * A triple-equals operator is rejected: this language has no strict equality
 * operator, only == and !=. This file is the illegal program itself; do not
 * reduce it to ==, since the triple form is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.TripleEqualsOperator
 * @Harness CompileReject
 * @Tag Language.Operators.TripleEqualsOperator
 * @Kind CompileReject
 * @Covers Operators.Comparison
 * @Inputs 1 === 1
 * @Return does not compile; diagnostic "Triple equals not valid"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
 * @Provenance sha256=905ef858cda8d3508f5b130402cfa6c290c73999dd941716cc3d37d5403782e9; lines 418-420.
 * @Provenance Expected compile failure: "Triple equals not valid".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	bool X = (1 === 1);
}
