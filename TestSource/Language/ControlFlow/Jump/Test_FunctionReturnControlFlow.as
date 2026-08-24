// Theme: Language.ControlFlow.Jump. Positive value oracle from FunctionReturnControlFlow.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionReturnControlFlow
// sha256=16302e73e1d23570f632329604a6e47eabac96a42ab96667a1e279aa5376ac6d; lines 884-916.
// Oracle: ReturnExpression 42; ReturnFunctionCall 42; ConditionalReturn(-42) 42; EarlyReturn(-5) -1; EarlyReturn(41) 42.
// Extra: Add(0,0) 0; ConditionalReturn(0) 0; ConditionalReturn(42) 42.
// DefaultSafe. Source owns locals.

int Add(int A, int B)
{
	return A + B;
}

int ReturnExpression()
{
	int A = 20;
	int B = 22;
	return A + B;
}

int ReturnFunctionCall()
{
	return Add(20, 22);
}

int ConditionalReturn(int Value)
{
	return Value > 0 ? Value : -Value;
}

int EarlyReturn(int Value)
{
	if (Value < 0)
	{
		return -1;
	}

	return Value + 1;
}

bool Observe_FunctionReturnControlFlow_Nominal()
{
	return ReturnExpression() == 42
		&& ReturnFunctionCall() == 42
		&& ConditionalReturn(-42) == 42
		&& EarlyReturn(-5) == -1
		&& EarlyReturn(41) == 42;
}

bool Observe_FunctionReturnControlFlow_ZeroDefault()
{
	return Add(0, 0) == 0 && ConditionalReturn(0) == 0 && EarlyReturn(0) == 1;
}

bool Observe_FunctionReturnControlFlow_PositiveBoundary()
{
	return ConditionalReturn(42) == 42 && Add(-1, 1) == 0;
}
