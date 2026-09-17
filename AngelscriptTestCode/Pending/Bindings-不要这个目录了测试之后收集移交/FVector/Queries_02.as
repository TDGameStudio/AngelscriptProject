/**
 * @version v1
 * @summary Observe FVector safe/unsafe normals, magnitude clamps, uniformity, perpendicular axes, and NaN detection.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector safe/unsafe normals, magnitude clamps, uniformity, perpendicular axes, and NaN detection.
 * @topic Baseline
 */
// GetClampedToMaxSize; GetClampedToMaxSize2D; IsUniform; GetSafeNormal;
// GetSafeNormal2D; FindBestAxisVectors; ContainsNaN.
// Inputs: (0,0,2), (10,0,0), (10,0,7), (2,2,2), (2,2,3), zero, ResultIfZero
// OneVector, omitted defaults, and GetUnsafeNormal of zero for NaN.
// Expected observations: Unsafe normal of (0,0,2) is (0,0,1). Size clamp of
// (10,0,0) into [2,5] is length 5. 2D clamps preserve Z. Uniform (2,2,2) is
// true. Safe normal of zero is ZeroVector or ResultIfZero. Best axes are
// unit and orthogonal to UpVector. Finite vectors are not NaN.
// Boundary/ownership: GetSafeNormal does not mutate. Out Axis1/Axis2 are
// writebacks. GetUnsafeNormal of zero may be non-finite.

namespace TS_FVector_Queries_02
{
	bool Observe_GetUnsafeNormal_Nominal()
	{
		FVector Normal = FVector(0, 0, 2).GetUnsafeNormal();
		return Normal.Equals(FVector(0, 0, 1));
	}

	bool Observe_GetClampedToSize_Nominal()
	{
		FVector Long = FVector(10, 0, 0).GetClampedToSize(2.0, 5.0);
		FVector Short = FVector(1, 0, 0).GetClampedToSize(2.0, 5.0);
		return Long.Equals(FVector(5, 0, 0)) && Short.Equals(FVector(2, 0, 0));
	}

	bool Observe_GetClampedToSize2D_Nominal()
	{
		FVector Clamped = FVector(10, 0, 7).GetClampedToSize2D(0.0, 5.0);
		return Clamped.Equals(FVector(5, 0, 7));
	}

	bool Observe_GetClampedToMaxSize_Nominal()
	{
		FVector Long = FVector(10, 0, 0).GetClampedToMaxSize(5.0);
		FVector Short = FVector(1, 0, 0).GetClampedToMaxSize(5.0);
		return Long.Equals(FVector(5, 0, 0)) && Short.Equals(FVector(1, 0, 0));
	}

	bool Observe_GetClampedToMaxSize2D_Nominal()
	{
		FVector Clamped = FVector(10, 0, 7).GetClampedToMaxSize2D(5.0);
		return Clamped.Equals(FVector(5, 0, 7));
	}

	bool Observe_IsUniform_Nominal()
	{
		return FVector(2, 2, 2).IsUniform() && !FVector(2, 2, 3).IsUniform();
	}

	bool Observe_GetSafeNormal_Nominal()
	{
		FVector Unit = FVector(0, 0, 2).GetSafeNormal();
		FVector ZeroDefault = FVector::ZeroVector.GetSafeNormal();
		FVector ZeroFallback = FVector::ZeroVector.GetSafeNormal(SMALL_NUMBER, FVector::OneVector);
		return Unit.Equals(FVector(0, 0, 1)) && ZeroDefault.IsZero() && ZeroFallback == FVector::OneVector;
	}

	bool Observe_GetSafeNormal2D_Nominal()
	{
		FVector UnitXY = FVector(3, 4, 9).GetSafeNormal2D();
		FVector ZeroXY = FVector(0, 0, 5).GetSafeNormal2D();
		FVector Fallback = FVector(0, 0, 5).GetSafeNormal2D(SMALL_NUMBER, FVector::OneVector);
		return UnitXY.Equals(FVector(0.6, 0.8, 0)) && ZeroXY.IsZero() && Fallback == FVector::OneVector;
	}

	bool Observe_FindBestAxisVectors_Nominal()
	{
		FVector Axis1;
		FVector Axis2;
		FVector::UpVector.FindBestAxisVectors(Axis1, Axis2);
		return Axis1.IsNormalized() &&
			Axis2.IsNormalized() &&
			Axis1.Orthogonal(FVector::UpVector) &&
			Axis2.Orthogonal(FVector::UpVector) &&
			Axis1.Orthogonal(Axis2);
	}

	bool Observe_ContainsNaN_Nominal()
	{
		FVector MaybeNonFinite = FVector::ZeroVector.GetUnsafeNormal();
		return !FVector(1, 2, 3).ContainsNaN() && MaybeNonFinite.ContainsNaN();
	}
}
/** @end */
