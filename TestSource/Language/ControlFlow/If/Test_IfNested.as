// Theme: Language.ControlFlow.If. Positive value oracle from IfNested.
// C++: AngelscriptCoverageConditionalTests.cpp::IfNested
// sha256=1f3d81dd5ec4090ba36d4603a7eb27087911198c4ee137d5e2bb8bff6a39a0cf; lines 175-218.
// Oracle: NestedIf(1, 1) 1; DeepNested(25) 3.
// Extra: remaining NestedIf quadrants; DeepNested 0/1/2 bands.
// DefaultSafe. Source owns locals.

int NestedIf(int X, int Y)
{
	if (X > 0)
	{
		if (Y > 0)
		{
			return 1;
		}
		else
		{
			return 2;
		}
	}
	else
	{
		if (Y > 0)
		{
			return 3;
		}
		else
		{
			return 4;
		}
	}
}

int DeepNested(int Value)
{
	if (Value > 0)
	{
		if (Value > 10)
		{
			if (Value > 20)
			{
				return 3;
			}
			return 2;
		}
		return 1;
	}
	return 0;
}

bool Observe_IfNested_Nominal()
{
	return NestedIf(1, 1) == 1 && DeepNested(25) == 3;
}

bool Observe_IfNested_ZeroDefault()
{
	return NestedIf(0, 0) == 4 && DeepNested(0) == 0;
}

bool Observe_IfNested_Boundary()
{
	return NestedIf(1, -1) == 2
		&& NestedIf(-1, 1) == 3
		&& NestedIf(-1, -1) == 4
		&& DeepNested(5) == 1
		&& DeepNested(15) == 2
		&& DeepNested(20) == 2;
}
