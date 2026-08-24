// Purpose: Observe FVector3f safe/unsafe normals, magnitude clamps,
// uniformity, perpendicular axes, and NaN detection.
// AS-facing API: GetUnsafeNormal; GetClampedToSize; GetClampedToSize2D;
// GetClampedToMaxSize; GetClampedToMaxSize2D; IsUniform; GetSafeNormal;
// GetSafeNormal2D; FindBestAxisVectors; ContainsNaN.
// Inputs: (0,0,2), (10,0,0), (10,0,7), (2,2,2), (2,2,3), zero, ResultIfZero
// OneVector, omitted float32 defaults, GetUnsafeNormal of zero for NaN.
// Expected observations: Unsafe normal of (0,0,2) is (0,0,1). Size clamp of
// (10,0,0) into [2,5] is length 5. 2D clamps preserve Z. Uniform (2,2,2) is
// true. Safe normal of zero is ZeroVector or ResultIfZero. Best axes are
// unit and orthogonal to UpVector. Finite vectors are not NaN.
// Boundary/ownership: GetSafeNormal does not mutate. Out Axis1/Axis2 are
// writebacks. GetUnsafeNormal of zero may be non-finite. IsUniform default
// tolerance is KINDA_SMALL_NUMBER.

namespace TS_FVector3f_Queries_02
{
	bool Observe_GetUnsafeNormal_Nominal()
	{
		FVector3f Normal = FVector3f(0.0f, 0.0f, 2.0f).GetUnsafeNormal();
		return Normal.Equals(FVector3f(0.0f, 0.0f, 1.0f));
	}

	bool Observe_GetClampedToSize_Nominal()
	{
		FVector3f Long = FVector3f(10.0f, 0.0f, 0.0f).GetClampedToSize(2.0f, 5.0f);
		FVector3f Short = FVector3f(1.0f, 0.0f, 0.0f).GetClampedToSize(2.0f, 5.0f);
		return Long.Equals(FVector3f(5.0f, 0.0f, 0.0f)) && Short.Equals(FVector3f(2.0f, 0.0f, 0.0f));
	}

	bool Observe_GetClampedToSize2D_Nominal()
	{
		FVector3f Clamped = FVector3f(10.0f, 0.0f, 7.0f).GetClampedToSize2D(0.0f, 5.0f);
		return Clamped.Equals(FVector3f(5.0f, 0.0f, 7.0f));
	}

	bool Observe_GetClampedToMaxSize_Nominal()
	{
		FVector3f Long = FVector3f(10.0f, 0.0f, 0.0f).GetClampedToMaxSize(5.0f);
		FVector3f Short = FVector3f(1.0f, 0.0f, 0.0f).GetClampedToMaxSize(5.0f);
		return Long.Equals(FVector3f(5.0f, 0.0f, 0.0f)) && Short.Equals(FVector3f(1.0f, 0.0f, 0.0f));
	}

	bool Observe_GetClampedToMaxSize2D_Nominal()
	{
		FVector3f Clamped = FVector3f(10.0f, 0.0f, 7.0f).GetClampedToMaxSize2D(5.0f);
		return Clamped.Equals(FVector3f(5.0f, 0.0f, 7.0f));
	}

	bool Observe_IsUniform_Nominal()
	{
		return FVector3f(2.0f, 2.0f, 2.0f).IsUniform() && !FVector3f(2.0f, 2.0f, 3.0f).IsUniform();
	}

	bool Observe_GetSafeNormal_Nominal()
	{
		FVector3f Unit = FVector3f(0.0f, 0.0f, 2.0f).GetSafeNormal();
		FVector3f ZeroDefault = FVector3f::ZeroVector.GetSafeNormal();
		FVector3f ZeroFallback = FVector3f::ZeroVector.GetSafeNormal(__SMALL_NUMBER_flt, FVector3f::OneVector);
		return Unit.Equals(FVector3f(0.0f, 0.0f, 1.0f)) && ZeroDefault.IsZero() && ZeroFallback == FVector3f::OneVector;
	}

	bool Observe_GetSafeNormal2D_Nominal()
	{
		FVector3f UnitXY = FVector3f(3.0f, 4.0f, 9.0f).GetSafeNormal2D();
		FVector3f ZeroXY = FVector3f(0.0f, 0.0f, 5.0f).GetSafeNormal2D();
		FVector3f Fallback = FVector3f(0.0f, 0.0f, 5.0f).GetSafeNormal2D(__SMALL_NUMBER_flt, FVector3f::OneVector);
		return UnitXY.Equals(FVector3f(0.6f, 0.8f, 0.0f)) && ZeroXY.IsZero() && Fallback == FVector3f::OneVector;
	}

	bool Observe_FindBestAxisVectors_Nominal()
	{
		FVector3f Axis1;
		FVector3f Axis2;
		FVector3f::UpVector.FindBestAxisVectors(Axis1, Axis2);
		bool bUnit = Axis1.IsNormalized() && Axis2.IsNormalized();
		bool bPerpToUp = Axis1.Orthogonal(FVector3f::UpVector) && Axis2.Orthogonal(FVector3f::UpVector);
		bool bPerpToEachOther = Axis1.Orthogonal(Axis2);
		return bUnit && bPerpToUp && bPerpToEachOther;
	}

	bool Observe_ContainsNaN_Nominal()
	{
		bool bFinite = !FVector3f(1.0f, 2.0f, 3.0f).ContainsNaN();
		FVector3f MaybeNonFinite = FVector3f::ZeroVector.GetUnsafeNormal();
		bool bNonFinite = MaybeNonFinite.ContainsNaN();
		return bFinite && bNonFinite;
	}
}
