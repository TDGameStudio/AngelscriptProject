// Theme: Containers.TArray. NegativeDiagnostic: local nested TArray<TArray<TArray<int>>>.
// C++ ExpectNestedContainerRejected. DiagnosticOnly.

int BuildLocalDeepMatrix()
{
	TArray<TArray<TArray<int>>> Matrix;
	return Matrix.Num();
}
