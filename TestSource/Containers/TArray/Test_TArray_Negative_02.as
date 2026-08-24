// Theme: Containers.TArray. NegativeDiagnostic: Add string into TArray<int>.
// Expected compile failure. DiagnosticOnly.

void Test()
{
	TArray<int> Arr;
	Arr.Add("hello");
}
