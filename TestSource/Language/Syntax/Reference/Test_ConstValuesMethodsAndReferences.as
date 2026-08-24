// Theme: Language.Syntax.Reference. Positive const values, const &in, const array foreach.
// C++: AngelscriptCoverageConstTests.cpp::ConstValuesMethodsAndReferences ExpectGlobalReturn.
// sha256=43fa01adabb1202a2732aa9003f80bca66d0ac5b7c3f355ece575f665dd30538; lines 60-98.
// Oracle: LocalConstValue==17; ConstInRefRead==64; ConstContainerRead==12.
// Extra: AddReadonly(0)==30; SumConstArray(empty)==0. DefaultSafe. Source owns locals.

const int GlobalLimit = 12;

int LocalConstValue()
{
	const int LocalLimit = 5;
	return LocalLimit + GlobalLimit;
}

int AddReadonly(const int&in Amount)
{
	return 30 + Amount;
}

int ConstInRefRead()
{
	const int Bonus = 34;
	return AddReadonly(Bonus);
}

int SumConstArray(const TArray<int>&in Values)
{
	int Sum = 0;
	for (const int& Value : Values)
	{
		Sum += Value;
	}
	return Sum;
}

int ConstContainerRead()
{
	TArray<int> Values;
	Values.Add(3);
	Values.Add(4);
	Values.Add(5);
	return SumConstArray(Values);
}

bool Observe_ConstValues_Nominal()
{
	return LocalConstValue() == 17 && ConstInRefRead() == 64 && ConstContainerRead() == 12;
}

int Observe_AddReadonly_ZeroBoundary()
{
	return AddReadonly(0);
}

int Observe_SumConstArray_Empty()
{
	TArray<int> Empty;
	return SumConstArray(Empty);
}
