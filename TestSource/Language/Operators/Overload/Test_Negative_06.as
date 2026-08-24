// Theme: Language.Operators.Overload. Isolated compile-fail: opAdd without param.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOBadParams
// lines 296-303;
// sha256=9fc601346d79727e27c17b9655906019c61fdd2ce6d692f553f77e398e3f5954.
// Expected diagnostic: opAdd without parameter should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

struct FVecBadParams
{
	int X = 0;

	FVecBadParams opAdd() const
	{
		return FVecBadParams();
	}
}
