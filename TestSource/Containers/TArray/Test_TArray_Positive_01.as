// Theme: Containers.TArray. Positive empty TArray construction.
// Extra: Num() of default is 0; IsEmpty true.

void Test()
{
	TArray<int> Arr;
}

bool Observe_EmptyDefault()
{
	TArray<int> Arr;
	return Arr.Num() == 0 && Arr.IsEmpty();
}
