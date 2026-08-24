// Theme: Containers.TArray. Add two ints. Extra: order [1,2]; empty Num 0.

void Test()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
}

bool Observe_AddNominal()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	return Arr.Num() == 2 && Arr[0] == 1 && Arr[1] == 2;
}

bool Observe_EmptyDefault()
{
	TArray<int> Arr;
	return Arr.Num() == 0;
}
