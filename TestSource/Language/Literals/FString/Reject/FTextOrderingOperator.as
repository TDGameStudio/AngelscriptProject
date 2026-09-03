/**
 * Ordering two FTexts with the less-than operator is rejected: this fork
 * exposes no ordering operator for text. This file is the illegal program
 * itself; do not compare the underlying strings instead, since the missing
 * operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FTextOrderingOperator
 * @Harness CompileReject
 * @Tag Language.Literals.FTextOrderingOperator
 * @Kind CompileReject
 * @Covers Literals.FText
 * @Inputs Left < Right where both are FText
 * @Return does not compile; diagnostic "No matching operator"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 8
 */

bool TryTextOrdering()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("B");
	return Left < Right;
}
