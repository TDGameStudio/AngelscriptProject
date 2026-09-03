/**
 * Ordering two vectors with the less-than operator is rejected: vectors have
 * no ordering. This file is the illegal program itself; do not compare
 * component-wise, since the unsupported operator is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.VectorOrderingComparison
 * @Harness CompileReject
 * @Tag Language.Operators.VectorOrderingComparison
 * @Kind CompileReject
 * @Covers Operators.Comparison
 * @Inputs FVector(1,0,0) < FVector(0,1,0)
 * @Return does not compile; diagnostic "Comparing vectors with <"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
 * @Provenance sha256=501e776c3b827eb618ea9c19e2a8412208a7160b6468eda5c9dce510959fa818; lines 425-427.
 * @Provenance Expected compile failure: "Comparing vectors with <".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	bool X = FVector(1,0,0) < FVector(0,1,0);
}
