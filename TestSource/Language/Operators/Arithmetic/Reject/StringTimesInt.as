/**
 * Multiplying a string by an int is rejected: repetition is not an operator
 * here. This file is the illegal program itself; do not rewrite it with a loop,
 * since the unsupported operand is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.StringTimesInt
 * @Harness CompileReject
 * @Tag Language.Operators.StringTimesInt
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs "abc" * 3
 * @Return does not compile; diagnostic "String * int"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=086bd5231bafb5d9f0c8b7335c9203c73ab1e1c42dfed90fd7f334ac1c8f94c4; lines 176-178.
 * @Provenance Expected compile failure: "String * int".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	auto S = "abc" * 3;
}
