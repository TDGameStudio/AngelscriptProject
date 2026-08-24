// Theme: Language.ControlFlow.Jump. Positive value oracle from GeometricStructFunctionParametersAndReturns.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::GeometricStructFunctionParametersAndReturns
// sha256=6ef87090ef88df92bc04ab9f34de82fa44144abc1305c8c0977a8a539b751b35; lines 820-895.
// Oracle: TranslateBox Min(11,22,33)/Max(14,25,36); ReadBoxVolume 24; SumBoxArrayVolumes 30; ReadBoxMapVolume 60;
// OffsetPlane W 15; ReadPlaneDistance 15; SumPlaneDistances 11; SumIntPoints (4,6); SumIntVectorMap (5,7,9).
// Extra: empty array/map defaults; missing map key returns -1.0.
// DefaultSafe. Source owns locals.

FBox TranslateBox(FBox Value, const FVector&in Offset)
{
	return Value.ShiftBy(Offset);
}

double ReadBoxVolume(const FBox&in Value)
{
	return Value.GetVolume();
}

double SumBoxArrayVolumes(const TArray<FBox>&in Values)
{
	double Total = 0.0;
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		Total += Values[Index].GetVolume();
	}
	return Total;
}

double ReadBoxMapVolume(const TMap<int, FBox>&in Values, int Key)
{
	if (!Values.Contains(Key))
	{
		return -1.0;
	}

	return Values[Key].GetVolume();
}

FPlane OffsetPlane(FPlane Value, double Offset)
{
	FVector Normal = Value.GetNormal();
	return FPlane(Value.GetOrigin() + Normal * Offset, Normal);
}

double ReadPlaneDistance(const FPlane&in Value, const FVector&in Point)
{
	return Value.PlaneDot(Point);
}

double SumPlaneDistances(const TArray<FPlane>&in Values, const FVector&in Point)
{
	double Total = 0.0;
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		Total += Values[Index].PlaneDot(Point);
	}
	return Total;
}

FIntPoint SumIntPoints(const TArray<FIntPoint>&in Values)
{
	FIntPoint Total;
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		Total += Values[Index];
	}
	return Total;
}

FIntVector SumIntVectorMap(const TMap<int, FIntVector>&in Values)
{
	FIntVector Total;
	if (Values.Contains(1))
	{
		Total += Values[1];
	}
	if (Values.Contains(2))
	{
		Total += Values[2];
	}
	return Total;
}

bool Observe_GeometricStruct_Nominal()
{
	FBox Translated = TranslateBox(FBox(FVector(1, 2, 3), FVector(4, 5, 6)), FVector(10, 20, 30));
	TArray<FBox> Boxes;
	Boxes.Add(FBox(FVector(0, 0, 0), FVector(1, 2, 3)));
	Boxes.Add(FBox(FVector(0, 0, 0), FVector(2, 3, 4)));
	TMap<int, FBox> BoxMap;
	BoxMap.Add(3, FBox(FVector(0, 0, 0), FVector(3, 4, 5)));
	FPlane Offset = OffsetPlane(FPlane(FVector(0, 0, 10), FVector(0, 0, 1)), 5.0);
	TArray<FPlane> Planes;
	Planes.Add(FPlane(FVector(0, 0, 2), FVector(0, 0, 1)));
	Planes.Add(FPlane(FVector(5, 0, 0), FVector(1, 0, 0)));
	TArray<FIntPoint> Points;
	Points.Add(FIntPoint(1, 2));
	Points.Add(FIntPoint(3, 4));
	TMap<int, FIntVector> Vectors;
	Vectors.Add(1, FIntVector(1, 2, 3));
	Vectors.Add(2, FIntVector(4, 5, 6));
	return Translated.Min.Equals(FVector(11, 22, 33), 0.001)
		&& Translated.Max.Equals(FVector(14, 25, 36), 0.001)
		&& Math::IsNearlyEqual(ReadBoxVolume(FBox(FVector(0, 0, 0), FVector(2, 3, 4))), 24.0, 0.001)
		&& Math::IsNearlyEqual(SumBoxArrayVolumes(Boxes), 30.0, 0.001)
		&& Math::IsNearlyEqual(ReadBoxMapVolume(BoxMap, 3), 60.0, 0.001)
		&& Offset.GetOrigin().Equals(FVector(0, 0, 15), 0.001)
		&& Math::IsNearlyEqual(ReadPlaneDistance(FPlane(FVector(0, 0, 10), FVector(0, 0, 1)), FVector(0, 0, 25)), 15.0, 0.001)
		&& Math::IsNearlyEqual(SumPlaneDistances(Planes, FVector(10, 0, 8)), 11.0, 0.001)
		&& SumIntPoints(Points) == FIntPoint(4, 6)
		&& SumIntVectorMap(Vectors) == FIntVector(5, 7, 9);
}

bool Observe_GeometricStruct_EmptyDefault()
{
	TArray<FBox> EmptyBoxes;
	TArray<FPlane> EmptyPlanes;
	TArray<FIntPoint> EmptyPoints;
	TMap<int, FIntVector> EmptyVectors;
	FIntPoint ZeroPoint;
	FIntVector ZeroVector;
	return Math::IsNearlyEqual(SumBoxArrayVolumes(EmptyBoxes), 0.0, 0.001)
		&& Math::IsNearlyEqual(SumPlaneDistances(EmptyPlanes, FVector(0, 0, 0)), 0.0, 0.001)
		&& SumIntPoints(EmptyPoints) == ZeroPoint
		&& SumIntVectorMap(EmptyVectors) == ZeroVector;
}

bool Observe_GeometricStruct_MissingKeyBoundary()
{
	TMap<int, FBox> EmptyMap;
	TMap<int, FBox> Present;
	Present.Add(3, FBox(FVector(0, 0, 0), FVector(3, 4, 5)));
	return Math::IsNearlyEqual(ReadBoxMapVolume(EmptyMap, 3), -1.0, 0.001)
		&& Math::IsNearlyEqual(ReadBoxMapVolume(Present, 99), -1.0, 0.001);
}
