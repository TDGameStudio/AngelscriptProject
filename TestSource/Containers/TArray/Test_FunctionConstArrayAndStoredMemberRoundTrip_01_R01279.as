// Theme: Containers.TArray. Positive TArray<FTransform> return/in and Inverse.
// C++ ValidateArrayReturn==1, ValidateArrayInput==1. Extra: empty combine is Identity.

TArray<FTransform> MakeTransformArray()
{
	TArray<FTransform> Values;
	Values.Add(FTransform::Identity);
	Values.Add(FTransform(FVector(10, 20, 30)));
	Values.Add(FTransform(FQuat::Identity, FVector(1, 2, 3), FVector(2, 3, 4)));
	return Values;
}

FTransform CombineTransformArray(const TArray<FTransform>&in Values)
{
	FTransform Result = FTransform::Identity;
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		Result *= Values[Index];
	}
	return Result;
}

int ValidateArrayReturn()
{
	TArray<FTransform> Values = MakeTransformArray();
	return Values.Num() == 3
		&& Values[0].Equals(FTransform::Identity, 0.001)
		&& Values[1].GetLocation().Equals(FVector(10, 20, 30), 0.001)
		&& Values[2].GetScale3D().Equals(FVector(2, 3, 4), 0.001)
		? 1 : 0;
}

int ValidateArrayInput()
{
	TArray<FTransform> Values;
	Values.Add(FTransform(FVector(1, 0, 0)));
	Values.Add(FTransform(FVector(0, 2, 0)));
	return CombineTransformArray(Values).GetLocation().Equals(FVector(1, 2, 0), 0.001) ? 1 : 0;
}

FTransform ReadConstTransform(const FTransform&in Value)
{
	return Value.Inverse();
}

bool Observe_TransformArray_Nominal()
{
	return ValidateArrayReturn() == 1 && ValidateArrayInput() == 1;
}

bool Observe_TransformArray_EmptyDefault()
{
	TArray<FTransform> Empty;
	return Empty.Num() == 0 && CombineTransformArray(Empty).Equals(FTransform::Identity, 0.001);
}
