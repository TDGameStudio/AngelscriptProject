// Purpose: Observe Math random helpers, unit-vector cones, circle samples,
// and the pulsating scalar, plus the degenerate cone-axis diagnostic.
// AS-facing API: Math::RandHelper; Math::RandRange; Math::RandBool;
// Math::VRand; Math::VRandCone; Math::RandPointInCircle;
// Math::MakePulsatingValue.
// Inputs: RandHelper max 10 and nonpositive 0/-5; RandRange [1,5] int and
// float; VRandCone axis (0,0,1) with half-angle PI/4 and the two-arg cone;
// circle radius 4; pulse time 0.25 at 1 Hz with omitted and explicit phase;
// zero DDir as the diagnostic companion.
// Expected observations: RandHelper is in [0, Max) and nonpositive Max
// returns 0. RandRange stays in [Min, Max]. VRand and VRandCone are unit
// length. Circle samples stay within Radius. Pulse is in [0, 1].
// Boundary/ownership: Results are random; observe range/unit-length/boolean,
// not exact values. DDir is expected to be normalized. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_01
{
	bool Observe_RandHelper_Nominal()
	{
		int32 InRange = Math::RandHelper(10);
		int32 InRangeAgain = Math::RandHelper(10);
		int32 ZeroMax = Math::RandHelper(0);
		int32 NegativeMax = Math::RandHelper(-5);
		return InRange >= 0 && InRange < 10 &&
			InRangeAgain >= 0 && InRangeAgain < 10 &&
			ZeroMax == 0 &&
			NegativeMax == 0;
	}

	bool Observe_RandRange_Nominal()
	{
		int32 IntSample = Math::RandRange(1, 5);
		int32 IntEqual = Math::RandRange(3, 3);
		float64 Min64 = 1.0;
		float64 Max64 = 5.0;
		float64 Float64Sample = Math::RandRange(Min64, Max64);
		float32 Min32 = 1.0;
		float32 Max32 = 5.0;
		float32 Float32Sample = Math::RandRange(Min32, Max32);
		return IntSample >= 1 && IntSample <= 5 &&
			IntEqual == 3 &&
			Float64Sample >= 1.0 && Float64Sample <= 5.0 &&
			Float32Sample >= 1.0 && Float32Sample <= 5.0;
	}

	bool Observe_RandBool_Nominal()
	{
		int32 TrueCount = 0;
		if (Math::RandBool())
		{
			TrueCount += 1;
		}
		if (Math::RandBool())
		{
			TrueCount += 1;
		}
		if (Math::RandBool())
		{
			TrueCount += 1;
		}
		return TrueCount >= 0 && TrueCount <= 3;
	}

	bool Observe_VRand_Nominal()
	{
		FVector Unit = Math::VRand();
		FVector UnitAgain = Math::VRand();
		return Unit.IsNormalized() && UnitAgain.IsNormalized();
	}

	bool Observe_VRandCone_Nominal()
	{
		FVector Axis(0.0, 0.0, 1.0);
		float32 Horizontal = float32(HALF_PI * 0.5);
		float32 Vertical = float32(HALF_PI * 0.5);
		FVector Anisotropic = Math::VRandCone(Axis, Horizontal, Vertical);
		float32 HalfAngle = float32(HALF_PI);
		FVector Isotropic = Math::VRandCone(Axis, HalfAngle);
		float64 AnisotropicDot = Anisotropic.DotProduct(Axis);
		float64 IsotropicDot = Isotropic.DotProduct(Axis);
		return Anisotropic.IsNormalized() &&
			AnisotropicDot >= 0.0 &&
			Isotropic.IsNormalized() &&
			IsotropicDot >= -KINDA_SMALL_NUMBER;
	}

	bool Observe_RandPointInCircle_Nominal()
	{
		float32 Radius = 4.0;
		FVector2D Inside = Math::RandPointInCircle(Radius);
		FVector2D InsideAgain = Math::RandPointInCircle(Radius);
		float32 ZeroRadius = 0.0;
		FVector2D Origin = Math::RandPointInCircle(ZeroRadius);
		return Inside.Size() <= 4.0 + KINDA_SMALL_NUMBER &&
			InsideAgain.Size() <= 4.0 + KINDA_SMALL_NUMBER &&
			Origin.Size() <= KINDA_SMALL_NUMBER;
	}

	bool Observe_MakePulsatingValue_Nominal()
	{
		float64 Time = 0.25;
		float32 Pulses = 1.0;
		float32 PulseDefault = Math::MakePulsatingValue(Time, Pulses);
		float32 Phase = 0.5;
		float32 PulsePhased = Math::MakePulsatingValue(Time, Pulses, Phase);
		float32 PulseZeroTime = Math::MakePulsatingValue(0.0, Pulses);
		return PulseDefault >= 0.0 && PulseDefault <= 1.0 &&
			PulsePhased >= 0.0 && PulsePhased <= 1.0 &&
			PulseZeroTime >= 0.0 && PulseZeroTime <= 1.0;
	}

	void ExerciseExpectedFailure()
	{
		FVector ZeroAxis;
		float32 HalfAngle = float32(HALF_PI * 0.25);
		FVector Degenerate = Math::VRandCone(ZeroAxis, HalfAngle);
	}
}
