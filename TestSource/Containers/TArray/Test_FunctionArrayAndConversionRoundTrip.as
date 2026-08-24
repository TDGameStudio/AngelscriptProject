// Theme: Containers.TArray. Positive TArray<FLinearColor> return/in and FColor conversion.
// C++: function-array conversion coverage. Oracle: ValidateArrayReturn==1,
// ValidateArrayInput==1, ReturnFromFColor(Red) is near-linear red.
// Extra: empty array sum is Transparent; copy independence of MakeColorArray.
// DefaultSafe. Bindings/TArray is entry wiring; this file proves values.

TArray<FLinearColor> MakeColorArray()
{
	TArray<FLinearColor> Values;
	Values.Add(FLinearColor::Red);
	Values.Add(FLinearColor(0.25, 0.5, 0.75, 1.0));
	FLinearColor Blue = FLinearColor::Blue;
	Values.Add(Blue.GetClamped());
	return Values;
}

FLinearColor SumColorArray(const TArray<FLinearColor>&in Values)
{
	FLinearColor Total = FLinearColor::Transparent;
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		Total += Values[Index];
	}
	return Total;
}

int ValidateArrayReturn()
{
	TArray<FLinearColor> Values = MakeColorArray();
	return Values.Num() == 3
		&& Values[0] == FLinearColor::Red
		&& Values[1].Equals(FLinearColor(0.25, 0.5, 0.75, 1.0), 0.001)
		&& Values[2] == FLinearColor::Blue
		? 1 : 0;
}

int ValidateArrayInput()
{
	TArray<FLinearColor> Values;
	Values.Add(FLinearColor(0.1, 0.2, 0.3, 0.4));
	Values.Add(FLinearColor(0.2, 0.3, 0.4, 0.5));
	FLinearColor Sum = SumColorArray(Values);
	return Sum.Equals(FLinearColor(0.3, 0.5, 0.7, 0.9), 0.001) ? 1 : 0;
}

FLinearColor ReturnFromFColor(FColor Packed)
{
	return FLinearColor(Packed);
}

FLinearColor ReturnReinterpretedFColor(FColor Packed)
{
	return Packed.ReinterpretAsLinear();
}

bool Observe_ColorArray_Nominal()
{
	return ValidateArrayReturn() == 1 && ValidateArrayInput() == 1;
}

bool Observe_ColorArray_EmptyDefault()
{
	TArray<FLinearColor> Empty;
	FLinearColor Sum = SumColorArray(Empty);
	return Empty.Num() == 0 && Sum.Equals(FLinearColor::Transparent, 0.001);
}

bool Observe_ColorArray_CopyIndependence()
{
	TArray<FLinearColor> First = MakeColorArray();
	TArray<FLinearColor> Second = MakeColorArray();
	First[0] = FLinearColor::Green;
	return Second[0] == FLinearColor::Red && First[0] == FLinearColor::Green;
}

bool Observe_FColorConversion_Nominal()
{
	FLinearColor FromPacked = ReturnFromFColor(FColor::Red);
	return FromPacked.R > 0.99 && FromPacked.G < 0.01 && FromPacked.B < 0.01;
}
