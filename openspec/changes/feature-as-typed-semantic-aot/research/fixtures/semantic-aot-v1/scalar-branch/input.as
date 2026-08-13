UFUNCTION()
int SemanticScalarBranch(int A, int B)
{
	int Sum = A + B;
	if (Sum > 10)
		return Sum * 2;

	return Sum - 1;
}
