// Theme: Containers.TArray. Num after one Add is 1. Extra: empty Num 0.

void Test()
{
	TArray<int> Arr;
	Arr.Add(1);
	int Count = Arr.Num();
}

bool Observe_NumNominal()
{
	TArray<int> Arr;
	Arr.Add(1);
	return Arr.Num() == 1;
}

bool Observe_NumEmpty()
{
	TArray<int> Arr;
	return Arr.Num() == 0;
}
