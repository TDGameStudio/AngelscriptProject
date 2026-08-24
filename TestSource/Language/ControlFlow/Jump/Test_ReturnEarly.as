// Theme: Language.ControlFlow.Jump. Positive value oracle from ReturnEarly.
// C++: AngelscriptCoverageJumpTests.cpp::ReturnEarly
// sha256=2e296b5a1a14b6ea866ecdebc7b327255f428605183f74b5fa3222b03134a50c; lines 378-433.
// Oracle: EarlyReturn(-5) -1; EarlyReturnInLoop 5; GuardClause(-5) 0; EarlyReturnNested(1, 1) 1.
// Extra: clamp/pass-through bounds; EarlyReturnVoid is callable; nested remaining arms.
// DefaultSafe. Source owns locals.

int EarlyReturn(int Value)
{
	if (Value < 0)
		return -1;
	if (Value > 100)
		return 100;
	return Value;
}

int EarlyReturnInLoop()
{
	for (int i = 0; i < 10; i++)
	{
		if (i == 5)
			return i;
	}
	return -1;
}

void EarlyReturnVoid(int Value)
{
	if (Value < 0)
		return;
	if (Value > 10)
		return;
}

int GuardClause(int Value)
{
	if (Value < 0)
		return 0;
	if (Value > 100)
		return 100;

	int Result = Value * 2;
	return Result;
}

int EarlyReturnNested(int A, int B)
{
	if (A > 0)
	{
		if (B > 0)
			return 1;
		return 2;
	}
	return 3;
}

bool Observe_ReturnEarly_Nominal()
{
	return EarlyReturn(-5) == -1
		&& EarlyReturnInLoop() == 5
		&& GuardClause(-5) == 0
		&& EarlyReturnNested(1, 1) == 1;
}

bool Observe_ReturnEarly_ZeroDefault()
{
	EarlyReturnVoid(-1);
	EarlyReturnVoid(0);
	EarlyReturnVoid(20);
	return EarlyReturn(0) == 0 && GuardClause(0) == 0 && EarlyReturnNested(0, 1) == 3;
}

bool Observe_ReturnEarly_ClampBoundary()
{
	return EarlyReturn(50) == 50
		&& EarlyReturn(150) == 100
		&& GuardClause(10) == 20
		&& GuardClause(150) == 100
		&& EarlyReturnNested(1, -1) == 2;
}
