// Theme: Language.Operators.Overload. Isolated compile-fail.
// C++: AngelscriptCoverageOperatorOverloadTests.cpp::OperatorNegativeCompile
// sha256=d253ceed93ad6135b0df5eef04e5ccd7fa4df706952844f0d1bffa40566d3d63; lines 244-250.
// Expected compile failure: "duplicate operator overload declaration should fail".
// DiagnosticOnly. Isolated failing program.

struct FDuplicateOp
{
	FDuplicateOp opAdd(const FDuplicateOp& Other) const
	{
		return FDuplicateOp();
	}

	FDuplicateOp opAdd(const FDuplicateOp& Other) const
	{
		return FDuplicateOp();
	}
}
