// Theme: Containers.TArray. TArray<FVector> Add unit X. Extra: empty Num 0.

void Test()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 0, 0));
}

bool Observe_VectorArrayNominal()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 0, 0));
	return Vectors.Num() == 1 && Vectors[0].Equals(FVector(1, 0, 0));
}
