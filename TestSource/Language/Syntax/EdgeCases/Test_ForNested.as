// Theme: Language.Syntax.EdgeCases. Positive nested for-loops and nested range-for.
// C++: AngelscriptCoverageLoopTests.cpp::ForNested ExpectGlobalReturn
// sha256=3094171a159471c8b50c693bb33dff19143c21452108332f15aa67878d20d5d9; lines 435-488.
// Oracle: NestedFor()==99; TripleNested()==8; NestedWithArrays()==66.
// Extra: NestedWithArrays empty outer yields 0; TripleNested is the 2x2x2 count boundary.
// DefaultSafe. Source owns locals and inner TArray.

int NestedFor()
{
	int Sum = 0;
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			Sum += i * 10 + j;
		}
	}
	return Sum;
}

int TripleNested()
{
	int Count = 0;
	for (int i = 0; i < 2; i++)
	{
		for (int j = 0; j < 2; j++)
		{
			for (int k = 0; k < 2; k++)
			{
				Count++;
			}
		}
	}
	return Count;
}

int NestedWithArrays()
{
	TArray<int> Outer;
	Outer.Add(1);
	Outer.Add(2);

	int Sum = 0;
	for (int Val1 : Outer)
	{
		TArray<int> Inner;
		Inner.Add(10);
		Inner.Add(20);

		for (int Val2 : Inner)
		{
			Sum += Val1 + Val2;
		}
	}
	return Sum;
}

bool Observe_ForNested_Nominal()
{
	return NestedFor() == 99 && TripleNested() == 8 && NestedWithArrays() == 66;
}

int Observe_ForNested_EmptyOuter()
{
	TArray<int> Outer;
	int Sum = 0;
	for (int Val1 : Outer)
	{
		Sum += Val1;
	}
	return Sum;
}
