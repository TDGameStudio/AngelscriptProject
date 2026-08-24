// Theme: Language.ControlFlow.Jump. Positive value oracle from MultipleReturns.
// C++: AngelscriptCoverageJumpTests.cpp::MultipleReturns
// sha256=b2fa4c8e2ead242bf14dd071cf5e217b0a71e42b2c52dcdc9e4a253a1645215d; lines 456-539.
// Oracle: MultipleReturnPoints(-1) -1; ReturnFromSwitch(1) 10; ReturnExpression(10, 20) 30;
// ReturnTernary(1) 1; ComplexMultipleReturns(1, 1, 1) 1; ReturnInNestedLoops 35.
// Extra: remaining return bands; switch default 0; nested-loop miss returns -1.
// DefaultSafe. Source owns locals.

int MultipleReturnPoints(int Value)
{
	if (Value < 0)
		return -1;
	else if (Value == 0)
		return 0;
	else if (Value < 10)
		return 1;
	else if (Value < 100)
		return 2;
	else
		return 3;
}

int ReturnFromSwitch(int Value)
{
	switch (Value)
	{
		case 1:
			return 10;
		case 2:
			return 20;
		case 3:
			return 30;
		default:
			return 0;
	}
}

int ReturnExpression(int A, int B)
{
	return A + B;
}

int ReturnTernary(int Value)
{
	return Value > 0 ? 1 : -1;
}

int ComplexMultipleReturns(int X, int Y, int Z)
{
	if (X > 0)
	{
		if (Y > 0)
		{
			if (Z > 0)
				return 1;
			else
				return 2;
		}
		else
		{
			return 3;
		}
	}
	else
	{
		if (Y > 0)
			return 4;
		else
			return 5;
	}
}

int ReturnInNestedLoops()
{
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			if (i == 3 && j == 5)
				return i * 10 + j;
		}
	}
	return -1;
}

bool Observe_MultipleReturns_Nominal()
{
	return MultipleReturnPoints(-1) == -1
		&& ReturnFromSwitch(1) == 10
		&& ReturnExpression(10, 20) == 30
		&& ReturnTernary(1) == 1
		&& ComplexMultipleReturns(1, 1, 1) == 1
		&& ReturnInNestedLoops() == 35;
}

bool Observe_MultipleReturns_ZeroDefault()
{
	return MultipleReturnPoints(0) == 0
		&& ReturnFromSwitch(0) == 0
		&& ReturnExpression(0, 0) == 0
		&& ReturnTernary(0) == -1
		&& ComplexMultipleReturns(0, 0, 0) == 5;
}

bool Observe_MultipleReturns_RemainingBands()
{
	return MultipleReturnPoints(5) == 1
		&& MultipleReturnPoints(50) == 2
		&& MultipleReturnPoints(200) == 3
		&& ReturnFromSwitch(2) == 20
		&& ReturnTernary(-4) == -1
		&& ComplexMultipleReturns(1, 1, 0) == 2
		&& ComplexMultipleReturns(1, 0, 1) == 3
		&& ComplexMultipleReturns(0, 1, 1) == 4;
}
