/**
 * Geometric structs passed and returned by function: an FBox shifted by an
 * offset, box volumes read singly, summed over an array, and looked up in a
 * map; an FPlane offset along its normal and its distance to a point; and
 * FIntPoint and FIntVector summed over an array and a map. A missing map key
 * yields -1.0 rather than throwing, and empty containers sum to zero.
 * These are math struct parameters and returns rather than jumps, so they
 * belong with the math subject; they sit here until moved to a Math
 * geometric-struct directory.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.GeometricStructParametersAndReturns
 * @Harness Function
 * @Tag Language.ControlFlow.GeometricStructParametersAndReturns
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::GeometricStructFunctionParametersAndReturns
 * @Provenance sha256=6ef87090ef88df92bc04ab9f34de82fa44144abc1305c8c0977a8a539b751b35; lines 820-895.
 * @Provenance Oracle: TranslateBox Min(11,22,33)/Max(14,25,36); ReadBoxVolume 24;
 * @Provenance SumBoxArrayVolumes 30; ReadBoxMapVolume 60; OffsetPlane W 15;
 * @Provenance ReadPlaneDistance 15; SumPlaneDistances 11; SumIntPoints (4,6); SumIntVectorMap (5,7,9).
 * @Provenance Extra: empty array/map defaults; missing map key returns -1.0.
 */

namespace ControlFlowTest
{
	/**
	 * Shift a box by an offset.
	 */
	FBox TranslateBox(FBox Value, const FVector&in Offset)
	{
		return Value.ShiftBy(Offset);
	}

	/**
	 * Read the volume of a box.
	 */
	double ReadBoxVolume(const FBox&in Value)
	{
		return Value.GetVolume();
	}

	/**
	 * Sum the volumes of an array of boxes.
	 */
	double SumBoxArrayVolumes(const TArray<FBox>&in Values)
	{
		double Total = 0.0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Total += Values[Index].GetVolume();
		}
		return Total;
	}

	/**
	 * Look up a box in a map by key and read its volume, returning -1.0 when
	 * the key is absent.
	 */
	double ReadBoxMapVolume(const TMap<int, FBox>&in Values, int Key)
	{
		if (!Values.Contains(Key))
		{
			return -1.0;
		}

		return Values[Key].GetVolume();
	}

	/**
	 * Move a plane along its own normal by an offset.
	 */
	FPlane OffsetPlane(FPlane Value, double Offset)
	{
		FVector Normal = Value.GetNormal();
		return FPlane(Value.GetOrigin() + Normal * Offset, Normal);
	}

	/**
	 * Read the signed distance from a plane to a point.
	 */
	double ReadPlaneDistance(const FPlane&in Value, const FVector&in Point)
	{
		return Value.PlaneDot(Point);
	}

	/**
	 * Sum the distances from an array of planes to one point.
	 */
	double SumPlaneDistances(const TArray<FPlane>&in Values, const FVector&in Point)
	{
		double Total = 0.0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Total += Values[Index].PlaneDot(Point);
		}
		return Total;
	}

	/**
	 * Sum an array of int points.
	 */
	FIntPoint SumIntPoints(const TArray<FIntPoint>&in Values)
	{
		FIntPoint Total;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Total += Values[Index];
		}
		return Total;
	}

	/**
	 * Sum two int vectors looked up from a map by key.
	 */
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

	/**
	 * Observe the box forms: shifting, reading a volume, summing volumes, and
	 * looking one up by key.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs A shifted box, a single volume, an array sum, and a map lookup
	 * @Return true when the bounds, volume, sum, and lookup all match
	 */
	UFUNCTION()
	bool BoxFormsProduceExpectedValues()
	{
		FBox Translated = TranslateBox(FBox(FVector(1, 2, 3), FVector(4, 5, 6)), FVector(10, 20, 30));
		TArray<FBox> Boxes;
		Boxes.Add(FBox(FVector(0, 0, 0), FVector(1, 2, 3)));
		Boxes.Add(FBox(FVector(0, 0, 0), FVector(2, 3, 4)));
		TMap<int, FBox> BoxMap;
		BoxMap.Add(3, FBox(FVector(0, 0, 0), FVector(3, 4, 5)));

		if (!Translated.Min.Equals(FVector(11, 22, 33), 0.001))
		{
			return false;
		}
		if (!Translated.Max.Equals(FVector(14, 25, 36), 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(ReadBoxVolume(FBox(FVector(0, 0, 0), FVector(2, 3, 4))), 24.0, 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(SumBoxArrayVolumes(Boxes), 30.0, 0.001))
		{
			return false;
		}
		return Math::IsNearlyEqual(ReadBoxMapVolume(BoxMap, 3), 60.0, 0.001);
	}

	/**
	 * Observe the plane forms: offsetting along the normal and reading distances
	 * to a point.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs An offset plane, a single distance, and a summed distance
	 * @Return true when the origin, distance, and sum all match
	 */
	UFUNCTION()
	bool PlaneFormsProduceExpectedValues()
	{
		FPlane Offset = OffsetPlane(FPlane(FVector(0, 0, 10), FVector(0, 0, 1)), 5.0);
		TArray<FPlane> Planes;
		Planes.Add(FPlane(FVector(0, 0, 2), FVector(0, 0, 1)));
		Planes.Add(FPlane(FVector(5, 0, 0), FVector(1, 0, 0)));

		if (!Offset.GetOrigin().Equals(FVector(0, 0, 15), 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(ReadPlaneDistance(FPlane(FVector(0, 0, 10), FVector(0, 0, 1)), FVector(0, 0, 25)), 15.0, 0.001))
		{
			return false;
		}
		return Math::IsNearlyEqual(SumPlaneDistances(Planes, FVector(10, 0, 8)), 11.0, 0.001);
	}

	/**
	 * Observe the integer struct forms summed over an array and a map.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs An array of int points and a map of int vectors
	 * @Return true when both sums match
	 */
	UFUNCTION()
	bool IntStructFormsProduceExpectedValues()
	{
		TArray<FIntPoint> Points;
		Points.Add(FIntPoint(1, 2));
		Points.Add(FIntPoint(3, 4));
		TMap<int, FIntVector> Vectors;
		Vectors.Add(1, FIntVector(1, 2, 3));
		Vectors.Add(2, FIntVector(4, 5, 6));

		if (SumIntPoints(Points) != FIntPoint(4, 6))
		{
			return false;
		}
		return SumIntVectorMap(Vectors) == FIntVector(5, 7, 9);
	}

	/**
	 * Observe the empty default: empty containers sum to zero and default
	 * integer structs are zero.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Empty arrays and maps plus default integer structs
	 * @Return true when every sum is zero
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool GeometricSumsHandleEmptyContainers()
	{
		TArray<FBox> EmptyBoxes;
		TArray<FPlane> EmptyPlanes;
		TArray<FIntPoint> EmptyPoints;
		TMap<int, FIntVector> EmptyVectors;
		FIntPoint ZeroPoint;
		FIntVector ZeroVector;

		if (!Math::IsNearlyEqual(SumBoxArrayVolumes(EmptyBoxes), 0.0, 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(SumPlaneDistances(EmptyPlanes, FVector(0, 0, 0)), 0.0, 0.001))
		{
			return false;
		}
		if (SumIntPoints(EmptyPoints) != ZeroPoint)
		{
			return false;
		}
		return SumIntVectorMap(EmptyVectors) == ZeroVector;
	}

	/**
	 * Observe the missing-key boundary: looking up a key that is absent yields
	 * -1.0 rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs A map lookup with a key that was never added
	 * @Return true when the lookup returns -1.0
	 * @Boundary missing map key
	 */
	UFUNCTION()
	bool MissingMapKeyYieldsMinusOne()
	{
		TMap<int, FBox> BoxMap;
		BoxMap.Add(3, FBox(FVector(0, 0, 0), FVector(3, 4, 5)));
		return Math::IsNearlyEqual(ReadBoxMapVolume(BoxMap, 99), -1.0, 0.001);
	}
}
