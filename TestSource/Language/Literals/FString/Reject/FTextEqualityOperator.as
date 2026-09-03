/**
 * Comparing two FTexts with the equality operator is rejected: this fork
 * exposes no equality operator for text. This file is the illegal program
 * itself; do not compare the underlying strings instead, since the missing
 * operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FTextEqualityOperator
 * @Harness CompileReject
 * @Tag Language.Literals.FTextEqualityOperator
 * @Kind CompileReject
 * @Covers Literals.FText
 * @Inputs Left == Right where both are FText
 * @Return does not compile; diagnostic "No matching operator"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 7
 * @Provenance sha256 from TS-LANG-0137; lines 723-730.
 */

bool TryTextEqualsOperator()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("A");
	return Left == Right;
}
