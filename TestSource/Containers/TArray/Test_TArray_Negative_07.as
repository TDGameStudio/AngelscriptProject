// Theme: Containers.TArray. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior implicit-conversion-permissive): float TArray index compiles.
// CSV NegativeDiagnostic is wrong; this is a truncation value oracle.
// Oracle: Arr[0.5f] reads the int at index 0. Extra: [0.0f] still 0; [1.9f] is index 1.
// Extra: empty Num 0; mutating one copy does not write the other. DefaultSafe.

void Test()
{
	TArray<int> Arr;
	Arr.Add(1);
	int X = Arr[0.5f];
}

int Observe_FloatIndex_Nominal()
{
	TArray<int> Arr;
	Arr.Add(1);
	int X = Arr[0.5f];
	return X;
}

int Observe_FloatIndex_ZeroDefault()
{
	TArray<int> Arr;
	Arr.Add(7);
	int X = Arr[0.0f];
	return X;
}

int Observe_FloatIndex_TruncTowardZeroBoundary()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	int X = Arr[1.9f];
	return X;
}

bool Observe_FloatIndex_EmptyDefault()
{
	TArray<int> Arr;
	return Arr.Num() == 0;
}

bool Observe_FloatIndex_CopyIndependence()
{
	TArray<int> First;
	TArray<int> Second;
	First.Add(1);
	Second.Add(1);
	First[0] = 9;
	return Second[0] == 1 && First[0] == 9;
}
