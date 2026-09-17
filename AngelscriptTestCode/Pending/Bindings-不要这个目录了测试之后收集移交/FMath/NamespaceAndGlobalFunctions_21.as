/**
 * @version v1
 * @summary Observe remaining FVector easings, NormalizeToRange, and IntegerDivisionTrunc including divide-by-zero.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FVector easings, NormalizeToRange, and IntegerDivisionTrunc including divide-by-zero.
 * @topic Baseline
 */
// Math::CircularOut; Math::CircularInOut; Math::NormalizeToRange;
// Math::IntegerDivisionTrunc.
// Inputs: FVector (0,0,0) to (10,0,0) at alpha 0/0.5/1; NormalizeToRange
// 5 and 15 over [0,10]; IntegerDivisionTrunc 7/3, -7/3, and unsigned 10/3;
// DivideBy 0 as the diagnostic companion.
// Expected observations: Vector endpoints match A and B. NormalizeToRange(5)
// is 0.5 and 15 is unclamped 1.5. 7/3 truncates to 2; -7/3 truncates toward
// zero to -2.
// Boundary/ownership: DivideBy must be nonzero; zero throws. Overflow of
// MIN integer is also rejected. Call Math::, never FMath::.

namespace TS_FMath_NamespaceAndGlobalFunctions_21
{
	bool Observe_ExpoOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::ExpoOut(A, B, Zero);
		FVector Mid = Math::ExpoOut(A, B, Half);
		FVector End = Math::ExpoOut(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}

	bool Observe_ExpoInOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::ExpoInOut(A, B, Zero);
		FVector Mid = Math::ExpoInOut(A, B, Half);
		FVector End = Math::ExpoInOut(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}

	bool Observe_CircularIn_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::CircularIn(A, B, Zero);
		FVector Mid = Math::CircularIn(A, B, Half);
		FVector End = Math::CircularIn(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}

	bool Observe_CircularOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::CircularOut(A, B, Zero);
		FVector Mid = Math::CircularOut(A, B, Half);
		FVector End = Math::CircularOut(A, B, One);
		return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
	}

	bool Observe_CircularInOut_Nominal()
	{
		FVector A(0.0, 0.0, 0.0);
		FVector B(10.0, 0.0, 0.0);
		float32 Zero = 0.0;
		float32 Half = 0.5;
		float32 One = 1.0;
		FVector Start = Math::CircularInOut(A, B, Zero);
		FVector Mid = Math::CircularInOut(A, B, Half);
		FVector End = Math::CircularInOut(A, B, One);
		return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 5.0, KINDA_SMALL_NUMBER) && End.Equals(B);
	}

	bool Observe_NormalizeToRange_Nominal()
	{
		float64 Mid = Math::NormalizeToRange(5.0, 0.0, 10.0);
		float64 Low = Math::NormalizeToRange(0.0, 0.0, 10.0);
		float64 High = Math::NormalizeToRange(15.0, 0.0, 10.0);
		float64 Degenerate = Math::NormalizeToRange(5.0, 3.0, 3.0);
		return Math::IsNearlyEqual(Mid, 0.5) && Math::IsNearlyEqual(Low, 0.0) && Math::IsNearlyEqual(High, 1.5) && Math::IsFinite(Degenerate);
	}

	bool Observe_IntegerDivisionTrunc_Nominal()
	{
		int32 Pos32 = Math::IntegerDivisionTrunc(7, 3);
		int32 Neg32 = Math::IntegerDivisionTrunc(-7, 3);
		int32 Exact32 = Math::IntegerDivisionTrunc(9, 3);
		int64 Pos64 = Math::IntegerDivisionTrunc(int64(7), int64(3));
		int64 Neg64 = Math::IntegerDivisionTrunc(int64(-7), int64(3));
		uint32 PosU32 = Math::IntegerDivisionTrunc(uint32(10), uint32(3));
		uint64 PosU64 = Math::IntegerDivisionTrunc(uint64(10), uint64(3));
		return Pos32 == 2 && Neg32 == -2 && Exact32 == 3 && Pos64 == 2 && Neg64 == int64(-2) && PosU32 == 3 && PosU64 == uint64(3);
	}

	void ExerciseExpectedFailure()
	{
		Math::IntegerDivisionTrunc(1, 0);
	}
}
/** @end */
