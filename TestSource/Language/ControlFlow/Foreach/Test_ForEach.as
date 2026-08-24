// Theme: Language.ControlFlow.Foreach. Positive value oracle from ForEach.
// C++: AngelscriptCoverageLoopTests.cpp::ForEach
// sha256=ccc982bca6e284cbe21880fad0060e358246974bbd3ca0d1f5a4b3c55606abeb; lines 239-327.
// Oracle: ForEachValue 15; ForEachReference 12; ForEachConstRef 60; ForEachSet 30; MapIteratorKeyValue 66.
// Extra: empty TArray/TSet/TMap visit nothing; ForEachValue does not mutate the source array.
// DefaultSafe. Source owns locals.

int ForEachValue()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.Add(3);
	Arr.Add(4);
	Arr.Add(5);

	int Sum = 0;
	for (int Val : Arr)
	{
		Sum += Val;
	}
	return Sum;
}

int ForEachReference()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.Add(3);

	for (int& Val : Arr)
	{
		Val *= 2;
	}

	int Sum = 0;
	for (int Val : Arr)
	{
		Sum += Val;
	}
	return Sum;
}

int ForEachConstRef()
{
	TArray<int> Arr;
	Arr.Add(10);
	Arr.Add(20);
	Arr.Add(30);

	int Sum = 0;
	for (const int& Val : Arr)
	{
		Sum += Val;
	}
	return Sum;
}

int ForEachSet()
{
	TSet<int> Set;
	Set.Add(5);
	Set.Add(10);
	Set.Add(15);

	int Sum = 0;
	for (int Val : Set)
	{
		Sum += Val;
	}
	return Sum;
}

int MapIteratorKeyValue()
{
	TMap<int, int> Map;
	Map.Add(1, 10);
	Map.Add(2, 20);
	Map.Add(3, 30);

	int Sum = 0;
	TMapIterator<int, int> It = Map.Iterator();
	while (It.CanProceed)
	{
		It.Proceed();
		Sum += It.GetKey() + It.GetValue();
	}
	return Sum;
}

bool Observe_ForEach_Nominal()
{
	return ForEachValue() == 15
		&& ForEachReference() == 12
		&& ForEachConstRef() == 60
		&& ForEachSet() == 30
		&& MapIteratorKeyValue() == 66;
}

bool Observe_ForEach_EmptyDefault()
{
	TArray<int> EmptyArr;
	int ArrSum = 0;
	for (int Val : EmptyArr)
	{
		ArrSum += Val;
	}

	TSet<int> EmptySet;
	int SetSum = 0;
	for (int Val : EmptySet)
	{
		SetSum += Val;
	}

	TMap<int, int> EmptyMap;
	int MapSum = 0;
	TMapIterator<int, int> It = EmptyMap.Iterator();
	while (It.CanProceed)
	{
		It.Proceed();
		MapSum += It.GetKey() + It.GetValue();
	}

	return ArrSum == 0 && SetSum == 0 && MapSum == 0;
}

bool Observe_ForEachValue_CopyIndependence()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.Add(3);
	for (int Val : Arr)
	{
		Val = 0;
	}
	return Arr[0] == 1 && Arr[1] == 2 && Arr[2] == 3 && ForEachValue() == 15;
}
