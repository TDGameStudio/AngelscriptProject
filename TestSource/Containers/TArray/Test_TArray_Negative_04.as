// Theme: Containers.TArray. NegativeDiagnostic: nested TArray<TArray<int>> local.
// Expected compile failure. DiagnosticOnly.

void Test()
{
	TArray<TArray<int>> Arr;
}
