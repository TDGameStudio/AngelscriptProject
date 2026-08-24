// Purpose: Observe Perlin noise, grid snapping, 2D segment intersection,
// stateful spring interpolation, and float64 EaseIn.
// AS-facing API: Math::PerlinNoise1D; Math::PerlinNoise2D; Math::PerlinNoise3D;
// Math::GridSnap; Math::SegmentIntersection2D; Math::FloatSpringInterp;
// Math::VectorSpringInterp; Math::QuaternionSpringInterp; Math::EaseIn.
// Inputs: Noise at 0 and (1,2)/(1,2,3); GridSnap 5 onto 2 and 5 onto 0;
// segments (0,0)-(2,0) vs (1,-1)-(1,1); springs from 0 toward 10 / Identity
// toward 90 yaw with omitted and explicit mass; EaseIn 0-to-10 at 0/0.5/1
// with Exp 2.
// Expected observations: Perlin samples are finite. GridSnap(5,2) is 6 and
// Grid 0 leaves Location. Crossing segments intersect at (1,0,0). Springs
// move toward the target and mutate SpringState. EaseIn(0.5,2) is 2.5.
// Boundary/ownership: SpringState is an inout writeback. Mass defaults to 1.
// out_IntersectionPoint is written on success. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_17
{
	bool Observe_PerlinNoise1D_Nominal()
	{
		float32 Zero32 = 0.0;
		float32 One32 = 1.0;
		float32 SampleZero = Math::PerlinNoise1D(Zero32);
		float32 SampleOne = Math::PerlinNoise1D(One32);
		return Math::IsFinite(SampleZero) && Math::IsFinite(SampleOne);
	}

	bool Observe_PerlinNoise2D_Nominal()
	{
		FVector2D Origin(0.0, 0.0);
		FVector2D Offset(1.0, 2.0);
		float32 SampleOrigin = Math::PerlinNoise2D(Origin);
		float32 SampleOffset = Math::PerlinNoise2D(Offset);
		return Math::IsFinite(SampleOrigin) && Math::IsFinite(SampleOffset);
	}

	bool Observe_PerlinNoise3D_Nominal()
	{
		FVector Origin(0.0, 0.0, 0.0);
		FVector Offset(1.0, 2.0, 3.0);
		float32 SampleOrigin = Math::PerlinNoise3D(Origin);
		float32 SampleOffset = Math::PerlinNoise3D(Offset);
		return Math::IsFinite(SampleOrigin) && Math::IsFinite(SampleOffset);
	}

	bool Observe_GridSnap_Nominal()
	{
		float64 Snap64 = Math::GridSnap(5.0, 2.0);
		float64 Unchanged64 = Math::GridSnap(5.0, 0.0);
		float32 Loc32 = 5.0;
		float32 Grid32 = 2.0;
		float32 Zero32 = 0.0;
		float32 Snap32 = Math::GridSnap(Loc32, Grid32);
		float32 Unchanged32 = Math::GridSnap(Loc32, Zero32);
		return Snap64 == 6.0 && Unchanged64 == 5.0 && Snap32 == 6.0 && Unchanged32 == 5.0;
	}

	bool Observe_SegmentIntersection2D_Nominal()
	{
		FVector Hit;
		bool bCrosses = Math::SegmentIntersection2D(
			FVector(0.0, 0.0, 0.0),
			FVector(2.0, 0.0, 0.0),
			FVector(1.0, -1.0, 0.0),
			FVector(1.0, 1.0, 0.0),
			Hit);
		FVector Miss;
		bool bMisses = Math::SegmentIntersection2D(
			FVector(0.0, 0.0, 0.0),
			FVector(1.0, 0.0, 0.0),
			FVector(0.0, 2.0, 0.0),
			FVector(1.0, 2.0, 0.0),
			Miss);
		bool bHitPoint = Hit.Equals(FVector(1.0, 0.0, 0.0), KINDA_SMALL_NUMBER);
		return bCrosses && bHitPoint && !bMisses;
	}

	bool Observe_FloatSpringInterp_Nominal()
	{
		FFloatSpringState SpringState;
		float32 Current = 0.0;
		float32 Target = 10.0;
		float32 Stiffness = 100.0;
		float32 Damping = 1.0;
		float32 DeltaTime = 0.016;
		float32 Mass = 1.0;
		float32 TargetVelocityAmount = 1.0;
		float32 Stepped = Math::FloatSpringInterp(Current, Target, SpringState, Stiffness, Damping, DeltaTime);
		float32 SteppedAgain = Math::FloatSpringInterp(Stepped, Target, SpringState, Stiffness, Damping, DeltaTime, Mass, TargetVelocityAmount);
		bool bMovedToward = Stepped > 0.0 && Stepped < 10.0;
		bool bSecondStepFinite = Math::IsFinite(SteppedAgain);
		return bMovedToward && bSecondStepFinite;
	}

	bool Observe_VectorSpringInterp_Nominal()
	{
		FVectorSpringState SpringState;
		FVector Current(0.0, 0.0, 0.0);
		FVector Target(10.0, 0.0, 0.0);
		float32 Stiffness = 100.0;
		float32 Damping = 1.0;
		float32 DeltaTime = 0.016;
		float32 Mass = 1.0;
		float32 TargetVelocityAmount = 1.0;
		FVector Stepped = Math::VectorSpringInterp(Current, Target, SpringState, Stiffness, Damping, DeltaTime);
		FVector SteppedAgain = Math::VectorSpringInterp(Stepped, Target, SpringState, Stiffness, Damping, DeltaTime, Mass, TargetVelocityAmount);
		bool bMovedToward = Stepped.X > 0.0 && Stepped.X < 10.0;
		bool bSecondStepFinite = Math::IsFinite(SteppedAgain.X);
		return bMovedToward && bSecondStepFinite;
	}

	bool Observe_QuaternionSpringInterp_Nominal()
	{
		FQuaternionSpringState SpringState;
		FQuat Current = FQuat::Identity;
		FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
		float32 Stiffness = 100.0;
		float32 Damping = 1.0;
		float32 DeltaTime = 0.016;
		float32 Mass = 1.0;
		float32 TargetVelocityAmount = 1.0;
		FQuat Stepped = Math::QuaternionSpringInterp(Current, Target, SpringState, Stiffness, Damping, DeltaTime);
		FQuat SteppedAgain = Math::QuaternionSpringInterp(Stepped, Target, SpringState, Stiffness, Damping, DeltaTime, Mass, TargetVelocityAmount);
		bool bMoved = !Stepped.Equals(Current, KINDA_SMALL_NUMBER);
		bool bSecondStepNormalized = SteppedAgain.IsNormalized();
		return bMoved && bSecondStepNormalized;
	}

	bool Observe_EaseIn_Nominal()
	{
		float64 Start = Math::EaseIn(0.0, 10.0, 0.0, 2.0);
		float64 Mid = Math::EaseIn(0.0, 10.0, 0.5, 2.0);
		float64 End = Math::EaseIn(0.0, 10.0, 1.0, 2.0);
		return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 2.5) && Math::IsNearlyEqual(End, 10.0);
	}
}
