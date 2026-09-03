/**
 * Ordering two FNames with the less-than operator is rejected: this fork
 * exposes no ordering operator for names. This file is the illegal program
 * itself; do not compare the underlying strings instead, since the missing
 * operator is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FNameOrderingOperator
 * @Harness CompileReject
 * @Tag Language.Literals.FNameOrderingOperator
 * @Kind CompileReject
 * @Covers Literals.FName
 * @Inputs Left < Right where both are FName
 * @Return does not compile; diagnostic "No matching operator"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 6
 * @Provenance sha256 from TS-LANG-0136; lines 705-712.
 */

bool TryNameOrdering()
{
	FName Left = n"Alpha";
	FName Right = n"Beta";
	return Left < Right;
}
