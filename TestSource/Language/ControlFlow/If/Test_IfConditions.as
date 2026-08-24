// Theme: Language.ControlFlow.If. Positive value oracle from IfConditions.
// C++: AngelscriptCoverageConditionalTests.cpp::IfConditions
// sha256=6416bc7b5547081e43e1f765f3b69d93ffe3e8fc22d363695a4271b592daed85; lines 239-333.
// Oracle: BoolVariable 1; ComparisonExpr(12) 1; LogicalAnd(1,1) 1; LogicalOr(1,0) 1;
// LogicalNot(false) 1; ComplexExpr(1,5,false) 1; NullCheckNull 0; IsValidCheckNull 0; FunctionReturnCheck 1.
// Extra: remaining comparison/logic branches; ComplexExpr false when A<=0, B>=10, and C false.
// DefaultSafe. Source owns locals.

int BoolVariable()
{
	bool bFlag = true;
	if (bFlag)
		return 1;
	return 0;
}

int ComparisonExpr(int Value)
{
	if (Value > 10)
		return 1;
	if (Value < 5)
		return 2;
	if (Value == 7)
		return 3;
	if (Value != 8)
		return 4;
	return 0;
}

int LogicalAnd(int A, int B)
{
	if (A > 0 && B > 0)
		return 1;
	return 0;
}

int LogicalOr(int A, int B)
{
	if (A > 0 || B > 0)
		return 1;
	return 0;
}

int LogicalNot(bool Flag)
{
	if (!Flag)
		return 1;
	return 0;
}

int ComplexExpr(int A, int B, bool C)
{
	if ((A > 0) && (B < 10) || C)
		return 1;
	return 0;
}

int NullCheck(UObject Obj)
{
	if (Obj != nullptr)
		return 1;
	return 0;
}

int IsValidCheck(UObject Obj)
{
	if (IsValid(Obj))
		return 1;
	return 0;
}

int NullCheckNull()
{
	return NullCheck(nullptr);
}

int IsValidCheckNull()
{
	return IsValidCheck(nullptr);
}

bool IsReady()
{
	return true;
}

int FunctionReturnCheck()
{
	if (IsReady())
		return 1;
	return 0;
}

bool Observe_IfConditions_Nominal()
{
	return BoolVariable() == 1
		&& ComparisonExpr(12) == 1
		&& LogicalAnd(1, 1) == 1
		&& LogicalOr(1, 0) == 1
		&& LogicalNot(false) == 1
		&& ComplexExpr(1, 5, false) == 1
		&& NullCheckNull() == 0
		&& IsValidCheckNull() == 0
		&& FunctionReturnCheck() == 1;
}

bool Observe_IfConditions_FalseDefault()
{
	return LogicalAnd(1, 0) == 0
		&& LogicalAnd(0, 1) == 0
		&& LogicalOr(0, 0) == 0
		&& LogicalNot(true) == 0
		&& ComplexExpr(0, 15, false) == 0
		&& NullCheck(nullptr) == 0
		&& IsValidCheck(nullptr) == 0;
}

bool Observe_IfConditions_ComparisonBoundary()
{
	return ComparisonExpr(3) == 2
		&& ComparisonExpr(7) == 3
		&& ComparisonExpr(8) == 0
		&& ComparisonExpr(9) == 4
		&& ComplexExpr(0, 5, true) == 1;
}
