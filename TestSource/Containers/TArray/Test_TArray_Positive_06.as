// Theme: Containers.TArray. Empty() after Add. Extra: Empty on already-empty is 0.

void Test()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Empty();
}

bool Observe_EmptyClears()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Empty();
	return Arr.Num() == 0;
}

bool Observe_EmptyIdempotent()
{
	TArray<int> Arr;
	Arr.Empty();
	return Arr.Num() == 0;
}
