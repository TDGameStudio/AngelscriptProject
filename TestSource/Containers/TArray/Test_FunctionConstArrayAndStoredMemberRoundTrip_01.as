// Theme: Containers.TArray. Positive TArray<FRotator> return/in plus const rotator inverse.
// C++: ValidateArrayReturn==1, ValidateArrayInput==1.
// Extra: empty sum is ZeroRotator; ReadConstRotator of Zero stays Zero inverse? GetInverse of zero.
// DefaultSafe.

TArray<FRotator> MakeRotatorArray()
{
	TArray<FRotator> Values;
	Values.Add(FRotator::ZeroRotator);
	Values.Add(FRotator(0, 90, 0));
	Values.Add(FRotator(10, 20, 30).GetNormalized());
	return Values;
}

FRotator SumRotatorArray(const TArray<FRotator>&in Values)
{
	FRotator Total = FRotator::ZeroRotator;
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		Total += Values[Index];
	}
	return Total;
}

int ValidateArrayReturn()
{
	TArray<FRotator> Values = MakeRotatorArray();
	return Values.Num() == 3
		&& Values[0].Equals(FRotator::ZeroRotator, 0.001)
		&& Values[1].Equals(FRotator(0, 90, 0), 0.001)
		&& Values[2].Equals(FRotator(10, 20, 30), 0.001)
		? 1 : 0;
}

int ValidateArrayInput()
{
	TArray<FRotator> Values;
	Values.Add(FRotator(1, 2, 3));
	Values.Add(FRotator(4, 5, 6));
	return SumRotatorArray(Values).Equals(FRotator(5, 7, 9), 0.001) ? 1 : 0;
}

FRotator ReadConstRotator(const FRotator&in Value)
{
	return Value.GetInverse();
}

bool Observe_RotatorArray_Nominal()
{
	return ValidateArrayReturn() == 1 && ValidateArrayInput() == 1;
}

bool Observe_RotatorArray_EmptyDefault()
{
	TArray<FRotator> Empty;
	return Empty.Num() == 0 && SumRotatorArray(Empty).Equals(FRotator::ZeroRotator, 0.001);
}
