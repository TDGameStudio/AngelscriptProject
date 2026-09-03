/**
 * Declaring the same operator twice in one type is rejected. This is the
 * coverage suite's counterpart of ../Reject/DuplicateOpAdd, which comes from
 * the syntax suite; both are kept because their C++ sources differ.
 * This file is the illegal program itself; do not drop either overload, since
 * the duplication is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.DuplicateOpAddCoverage
 * @Harness CompileReject
 * @Tag Language.Operators.DuplicateOpAddCoverage
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring two identical opAdd overloads
 * @Return does not compile; diagnostic "duplicate operator overload declaration should fail"
 * @Provenance C++: AngelscriptCoverageOperatorOverloadTests.cpp::OperatorNegativeCompile
 * @Provenance sha256=d253ceed93ad6135b0df5eef04e5ccd7fa4df706952844f0d1bffa40566d3d63; lines 244-250.
 * @Provenance Expected compile failure: "duplicate operator overload declaration should fail".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FDuplicateOp
{
	/**
	 * The first of two identical opAdd declarations.
	 */
	FDuplicateOp opAdd(const FDuplicateOp&in Other) const
	{
		return FDuplicateOp();
	}

	/**
	 * The second of two identical opAdd declarations.
	 */
	FDuplicateOp opAdd(const FDuplicateOp&in Other) const
	{
		return FDuplicateOp();
	}
}
