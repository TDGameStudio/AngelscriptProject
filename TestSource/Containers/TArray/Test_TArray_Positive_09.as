// Theme: Containers.TArray. Contains true for 5. Extra: Contains 9 false; empty Contains false.

void Test()
{
	TArray<int> Arr;
	Arr.Add(5);
	bool B = Arr.Contains(5);
}

bool Observe_ContainsNominal()
{
	TArray<int> Arr;
	Arr.Add(5);
	return Arr.Contains(5) && !Arr.Contains(9);
}

bool Observe_ContainsEmpty()
{
	TArray<int> Arr;
	return !Arr.Contains(5);
}
