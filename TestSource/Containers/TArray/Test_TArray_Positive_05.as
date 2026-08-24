// Theme: Containers.TArray. RemoveAt(0) leaves [2]. Extra: empty not removed.

void Test()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.RemoveAt(0);
}

bool Observe_RemoveAtNominal()
{
	TArray<int> Arr;
	Arr.Add(1);
	Arr.Add(2);
	Arr.RemoveAt(0);
	return Arr.Num() == 1 && Arr[0] == 2;
}
