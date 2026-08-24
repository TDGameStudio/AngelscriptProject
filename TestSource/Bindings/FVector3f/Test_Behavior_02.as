// Purpose: Observe FVector3f parallelism tests, component min/max/clamp, and
// Euclidean sizes.
// AS-facing API: Parallel; Coincident; Orthogonal; ComponentMin; ComponentMax;
// ComponentClamp; Size; SizeSquared; Size2D; SizeSquared2D.
// Inputs: Forward/Right and -Forward, (2,0,-1) vs min (0,0,0) max (1,1,1),
// (3,4,0) Size 5, (3,4,12) SizeSquared 169 and XY size 5.
// Expected observations: Forward is parallel and coincident with itself,
// parallel but not coincident with -Forward, orthogonal to Right. Component
// clamp maps (2,0,-1) to (1,0,0). Size of (3,4,0) is 5. Size2D of (3,4,12)
// is 5.
// Boundary/ownership: Parallel family expects unit normals. Default
// thresholds are __THRESH_NORMALS_ARE_PARALLEL_flt /
// __THRESH_NORMALS_ARE_ORTHOGONAL_flt.

namespace TS_FVector3f_Behavior_02
{
	bool Observe_Parallel_Nominal()
	{
		FVector3f AntiForward(-1.0f, 0.0f, 0.0f);
		bool bSame = FVector3f::ForwardVector.Parallel(FVector3f::ForwardVector);
		bool bOpposite = FVector3f::ForwardVector.Parallel(AntiForward);
		bool bSkew = FVector3f::ForwardVector.Parallel(FVector3f::RightVector);
		return bSame && bOpposite && !bSkew;
	}

	bool Observe_Coincident_Nominal()
	{
		FVector3f AntiForward(-1.0f, 0.0f, 0.0f);
		bool bSame = FVector3f::ForwardVector.Coincident(FVector3f::ForwardVector);
		bool bOpposite = FVector3f::ForwardVector.Coincident(AntiForward);
		return bSame && !bOpposite;
	}

	bool Observe_Orthogonal_Nominal()
	{
		bool bPerp = FVector3f::ForwardVector.Orthogonal(FVector3f::RightVector);
		bool bAligned = FVector3f::ForwardVector.Orthogonal(FVector3f::ForwardVector);
		return bPerp && !bAligned;
	}

	bool Observe_ComponentMin_Nominal()
	{
		FVector3f Min = FVector3f(2.0f, 0.0f, -1.0f).ComponentMin(FVector3f(1.0f, 1.0f, 1.0f));
		return Min.Equals(FVector3f(1.0f, 0.0f, -1.0f));
	}

	bool Observe_ComponentMax_Nominal()
	{
		FVector3f Max = FVector3f(2.0f, 0.0f, -1.0f).ComponentMax(FVector3f(1.0f, 1.0f, 1.0f));
		return Max.Equals(FVector3f(2.0f, 1.0f, 1.0f));
	}

	bool Observe_ComponentClamp_Nominal()
	{
		FVector3f Clamped = FVector3f(2.0f, 0.0f, -1.0f).ComponentClamp(FVector3f(0.0f, 0.0f, 0.0f), FVector3f(1.0f, 1.0f, 1.0f));
		return Clamped.Equals(FVector3f(1.0f, 0.0f, 0.0f));
	}

	bool Observe_Size_Nominal()
	{
		return FVector3f(3.0f, 4.0f, 0.0f).Size() == 5.0f && FVector3f(0.0f, 0.0f, 0.0f).Size() == 0.0f;
	}

	bool Observe_SizeSquared_Nominal()
	{
		return FVector3f(3.0f, 4.0f, 12.0f).SizeSquared() == 169.0f && FVector3f(0.0f, 0.0f, 0.0f).SizeSquared() == 0.0f;
	}

	bool Observe_Size2D_Nominal()
	{
		return FVector3f(3.0f, 4.0f, 12.0f).Size2D() == 5.0f && FVector3f(0.0f, 0.0f, 9.0f).Size2D() == 0.0f;
	}

	bool Observe_SizeSquared2D_Nominal()
	{
		return FVector3f(3.0f, 4.0f, 12.0f).SizeSquared2D() == 25.0f && FVector3f(0.0f, 0.0f, 9.0f).SizeSquared2D() == 0.0f;
	}
}
