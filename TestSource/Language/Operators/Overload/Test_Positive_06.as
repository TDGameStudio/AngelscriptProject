// Theme: Language.Operators.Overload. Positive: struct opIndex on TArray data.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
// ASSyntaxOOIndex; lines 132-142;
// sha256=3704bc124d24c7b7f416aed96eb8a14950e268b914cceeb74aa99fec844bd2ec.
// Oracle: Container[0]==10 and Container[1]==20 after Add(10), Add(20).
// Extra: default Data.Num()==0; copied TArray is independent of the original.
// DefaultSafe. Source owns locals.

struct FMyContainer
{
	TArray<int> Data;

	int opIndex(int Index) const
	{
		return Data[Index];
	}
}

bool Observe_Index_Nominal()
{
	FMyContainer Container;
	Container.Data.Add(10);
	Container.Data.Add(20);
	return Container[0] == 10 && Container[1] == 20;
}

bool Observe_Index_EmptyDefault()
{
	FMyContainer Container;
	return Container.Data.Num() == 0;
}

bool Observe_Index_CopyIndependence()
{
	FMyContainer Original;
	Original.Data.Add(7);
	FMyContainer Copy = Original;
	Copy.Data[0] = 9;
	return Original[0] == 7 && Copy[0] == 9;
}
