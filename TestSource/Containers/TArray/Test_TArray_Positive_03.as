// Theme: Containers.TArray. Index read after Add. Extra: missing index is not used here;
// empty has no [0]. Nominal Arr[0]==5.

void Test()
{
	TArray<int> Arr;
	Arr.Add(5);
	int X = Arr[0];
}

bool Observe_IndexNominal()
{
	TArray<int> Arr;
	Arr.Add(5);
	return Arr[0] == 5;
}
