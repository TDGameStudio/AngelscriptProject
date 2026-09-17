/**
 * @version v1
 * @summary Observe Math range mapping, axis-aligned and oriented box containment, and nearest points on two segments.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Math range mapping, axis-aligned and oriented box containment, and nearest points on two segments.
 * @topic Baseline
 */
// Math::GetMappedRangeValueUnclamped; Math::IsPointInBox;
// Math::IsPointInBoxWithTransform; Math::FindNearestPointsOnLineSegments.
// Inputs: Input [0,10] to output [0,100]; values 5, 15, -5; origin-zero box
// extent (1,1,1); Identity transform; segments (0,0,0)-(10,0,0) and
// (5,5,0)-(5,10,0); zero BoxExtent as the diagnostic companion.
// Expected observations: 5 maps to 50. Clamped 15 maps to 100; unclamped 15
// maps to 150. Origin is inside the box; (2,0,0) is outside. Nearest points
// are (5,0,0) and (5,5,0).
// Boundary/ownership: Segment out-params are writebacks. Call Math::, never
// FMath::. BoxExtent is a positive half-size. Identity is a local FTransform.

namespace TS_FMath_Queries_04
{
	bool Observe_GetMappedRangeValueClamped_Nominal()
	{
		FVector2D Input64(0.0, 10.0);
		FVector2D Output64(0.0, 100.0);
		float64 Mid64 = Math::GetMappedRangeValueClamped(Input64, Output64, 5.0);
		float64 High64 = Math::GetMappedRangeValueClamped(Input64, Output64, 15.0);
		float64 Low64 = Math::GetMappedRangeValueClamped(Input64, Output64, -5.0);

		FVector2f Input32(0.0, 10.0);
		FVector2f Output32(0.0, 100.0);
		float32 Five32 = 5.0;
		float32 Fifteen32 = 15.0;
		float32 Mid32 = Math::GetMappedRangeValueClamped(Input32, Output32, Five32);
		float32 High32 = Math::GetMappedRangeValueClamped(Input32, Output32, Fifteen32);
		return Mid64 == 50.0 && High64 == 100.0 && Low64 == 0.0 && Mid32 == 50.0 && High32 == 100.0;
	}

	bool Observe_GetMappedRangeValueUnclamped_Nominal()
	{
		FVector2D Input64(0.0, 10.0);
		FVector2D Output64(0.0, 100.0);
		float64 Mid64 = Math::GetMappedRangeValueUnclamped(Input64, Output64, 5.0);
		float64 High64 = Math::GetMappedRangeValueUnclamped(Input64, Output64, 15.0);
		float64 Low64 = Math::GetMappedRangeValueUnclamped(Input64, Output64, -5.0);

		FVector2f Input32(0.0, 10.0);
		FVector2f Output32(0.0, 100.0);
		float32 Five32 = 5.0;
		float32 Fifteen32 = 15.0;
		float32 Mid32 = Math::GetMappedRangeValueUnclamped(Input32, Output32, Five32);
		float32 High32 = Math::GetMappedRangeValueUnclamped(Input32, Output32, Fifteen32);
		return Mid64 == 50.0 && High64 == 150.0 && Low64 == -50.0 && Mid32 == 50.0 && High32 == 150.0;
	}

	bool Observe_IsPointInBox_Nominal()
	{
		FVector Origin;
		FVector Extent(1.0, 1.0, 1.0);
		bool bInside = Math::IsPointInBox(FVector(0.0, 0.0, 0.0), Origin, Extent);
		bool bOnFace = Math::IsPointInBox(FVector(1.0, 0.0, 0.0), Origin, Extent);
		bool bOutside = Math::IsPointInBox(FVector(2.0, 0.0, 0.0), Origin, Extent);
		return bInside && bOnFace && !bOutside;
	}

	bool Observe_IsPointInBoxWithTransform_Nominal()
	{
		FTransform BoxWorldTransform = FTransform::Identity;
		FVector BoxExtent(1.0, 1.0, 1.0);
		bool bInside = Math::IsPointInBoxWithTransform(FVector(0.0, 0.0, 0.0), BoxWorldTransform, BoxExtent);
		bool bOnFace = Math::IsPointInBoxWithTransform(FVector(1.0, 0.0, 0.0), BoxWorldTransform, BoxExtent);
		bool bOutside = Math::IsPointInBoxWithTransform(FVector(2.0, 0.0, 0.0), BoxWorldTransform, BoxExtent);
		return bInside && bOnFace && !bOutside;
	}

	bool Observe_FindNearestPointsOnLineSegments_Nominal()
	{
		FVector Segment1Point;
		FVector Segment2Point;
		Math::FindNearestPointsOnLineSegments(
			FVector(0.0, 0.0, 0.0),
			FVector(10.0, 0.0, 0.0),
			FVector(5.0, 5.0, 0.0),
			FVector(5.0, 10.0, 0.0),
			Segment1Point,
			Segment2Point);
		bool bSegment1 = Segment1Point.Equals(FVector(5.0, 0.0, 0.0), 0.001);
		bool bSegment2 = Segment2Point.Equals(FVector(5.0, 5.0, 0.0), 0.001);
		return bSegment1 && bSegment2;
	}

	void ExerciseExpectedFailure()
	{
		FTransform BoxWorldTransform = FTransform::Identity;
		FVector ZeroExtent;
		Math::IsPointInBoxWithTransform(FVector(1.0, 0.0, 0.0), BoxWorldTransform, ZeroExtent);
	}
}
/** @end */
