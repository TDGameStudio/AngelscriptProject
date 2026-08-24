// Theme: Language.Operators.Overload. Isolated compile-fail: invalid op name.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOInvalid
// lines 226-236;
// sha256=6277dcaf72cae7822421d31bb3243b52c638a45cf2e38fd51bee2ebbb67fa148.
// Expected diagnostic: invalid operator overload name should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

struct FVecInvalid
{
	int X = 0;

	FVecInvalid opInvalid(const FVecInvalid& Other) const
	{
		return FVecInvalid();
	}
}
