// Theme: Containers.TArray. Runtime OOB read/write. C++ expected errors.
// Extra: in-range [0] is 10. DiagnosticOnly for the OOB paths.

int ReadPastEnd()
{
	TArray<int> Values;
	Values.Add(10);
	return Values[1];
}

void WritePastEnd()
{
	TArray<int> Values;
	Values.Add(10);
	Values[1] = 20;
}

int Observe_InRangeBoundary()
{
	TArray<int> Values;
	Values.Add(10);
	return Values[0];
}
