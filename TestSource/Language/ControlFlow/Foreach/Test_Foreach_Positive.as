// Theme: Language.ControlFlow.Foreach. Positive value oracle from Foreach_Positive.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Foreach_Positive
// sha256=5dccfb40663071d38e8f5e577bebea401d62f53ac1d6dc321420c045b317c6ed; lines 435-462.
// Oracle: BasicForeach 6; ForeachBreak 3; ForeachContinue 4.
// Extra: empty TArray sum 0; break on first element leaves sum 0.
// DefaultSafe. Source owns locals.

int BasicForeach()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.Add(3);
	int Sum = 0;
	for (int Val : Arr)
	{
		Sum += Val;
	}
	return Sum;
}

int ForeachBreak()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.Add(3);
	Arr.Add(4);
	int Sum = 0;
	for (int Val : Arr)
	{
		if (Val > 2)
		{
			break;
		}
		Sum += Val;
	}
	return Sum;
}

int ForeachContinue()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.Add(3);
	int Sum = 0;
	for (int Val : Arr)
	{
		if (Val == 2)
		{
			continue;
		}
		Sum += Val;
	}
	return Sum;
}

bool Observe_Foreach_Positive_Nominal()
{
	return BasicForeach() == 6 && ForeachBreak() == 3 && ForeachContinue() == 4;
}

bool Observe_Foreach_Positive_EmptyDefault()
{
	TArray<int> Empty;
	int Sum = 0;
	for (int Val : Empty)
	{
		Sum += Val;
	}
	return Sum == 0;
}

bool Observe_ForeachBreak_ImmediateBoundary()
{
	TArray<int> Arr;
	Arr.Add(3);
	Arr.Add(1);
	int Sum = 0;
	for (int Val : Arr)
	{
		if (Val > 2)
		{
			break;
		}
		Sum += Val;
	}
	return Sum == 0;
}
