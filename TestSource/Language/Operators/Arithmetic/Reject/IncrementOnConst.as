/**
 * Incrementing a const is rejected: a const binding has no mutable storage to
 * increment. This file is the illegal program itself; do not drop the const,
 * since the immutability is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.IncrementOnConst
 * @Harness CompileReject
 * @Tag Language.Operators.IncrementOnConst
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs const int X = 5; ++X;
 * @Return does not compile; diagnostic "Increment on const"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
 * @Provenance sha256=869e4e859213ef4befff766cc2d8c085f4ee3c0c76cebdc68f0317d9d0402c9f; lines 144-146.
 * @Provenance Expected compile failure: "Increment on const".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	const int X = 5;
	++X;
}
