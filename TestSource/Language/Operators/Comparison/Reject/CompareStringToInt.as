/**
 * Ordering a string against an integer is rejected: the two operands have no
 * common ordering. This file is the illegal program itself; do not convert
 * either side, since the unsupported comparison is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.CompareStringToInt
 * @Harness CompileReject
 * @Tag Language.Operators.CompareStringToInt
 * @Kind CompileReject
 * @Covers Operators.Comparison
 * @Inputs "hello" < 5
 * @Return does not compile; diagnostic "Comparing string to int"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
 * @Provenance sha256=d34a34262a1bb43e776bbbee18426d5c70dc00f56a4f4c3d7340ac2d176f6318; lines 404-406.
 * @Provenance Expected compile failure: "Comparing string to int".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

void Test()
{
	bool X = ("hello" < 5);
}
