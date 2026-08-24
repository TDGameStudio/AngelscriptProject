// Purpose: Observe FVector cross/dot products, parallelism tests, component
// min/max/clamp, and Euclidean size.
// AS-facing API: CrossProduct; DotProduct; AllComponentsEqual; Parallel;
// Coincident; Orthogonal; ComponentMin; ComponentMax; ComponentClamp; Size.
// Inputs: Unit X/Y/Z, anti-parallel -X, (1,1,1), (1,2,1), (2,0,-1) vs
// min (0,0,0) max (1,1,1), (3,4,0) so Size is 5, omitted default thresholds.
// Expected observations: X cross Y is Z. X dot Y is 0. (1,1,1) components
// are equal. X is parallel and coincident with X, parallel but not coincident
// with -X, orthogonal to Y. Component min/max/clamp are per-axis. Size of
// (3,4,0) is 5.
// Boundary/ownership: Parallel/Coincident/Orthogonal expect unit normals.
// Results are new values; receivers are unchanged.

namespace TS_FVector_Behavior_02
{
	bool Observe_CrossProduct_Nominal()
	{
		FVector Cross = FVector(1, 0, 0).CrossProduct(FVector(0, 1, 0));
		return Cross.Equals(FVector(0, 0, 1));
	}

	bool Observe_DotProduct_Nominal()
	{
		float64 Orthogonal = FVector(1, 0, 0).DotProduct(FVector(0, 1, 0));
		float64 Aligned = FVector(1, 0, 0).DotProduct(FVector(1, 0, 0));
		return Orthogonal == 0.0 && Aligned == 1.0;
	}

	bool Observe_AllComponentsEqual_Nominal()
	{
		return FVector(1, 1, 1).AllComponentsEqual() && !FVector(1, 2, 1).AllComponentsEqual();
	}

	bool Observe_Parallel_Nominal()
	{
		return FVector::ForwardVector.Parallel(FVector::ForwardVector) &&
			FVector::ForwardVector.Parallel(FVector::BackwardVector) &&
			!FVector::ForwardVector.Parallel(FVector::RightVector);
	}

	bool Observe_Coincident_Nominal()
	{
		return FVector::ForwardVector.Coincident(FVector::ForwardVector) &&
			!FVector::ForwardVector.Coincident(FVector::BackwardVector);
	}

	bool Observe_Orthogonal_Nominal()
	{
		return FVector::ForwardVector.Orthogonal(FVector::RightVector) &&
			!FVector::ForwardVector.Orthogonal(FVector::ForwardVector);
	}

	bool Observe_ComponentMin_Nominal()
	{
		FVector Min = FVector(2, 0, -1).ComponentMin(FVector(1, 1, 1));
		return Min.Equals(FVector(1, 0, -1));
	}

	bool Observe_ComponentMax_Nominal()
	{
		FVector Max = FVector(2, 0, -1).ComponentMax(FVector(1, 1, 1));
		return Max.Equals(FVector(2, 1, 1));
	}

	bool Observe_ComponentClamp_Nominal()
	{
		FVector Clamped = FVector(2, 0, -1).ComponentClamp(FVector(0, 0, 0), FVector(1, 1, 1));
		return Clamped.Equals(FVector(1, 0, 0));
	}

	bool Observe_Size_Nominal()
	{
		return FVector(3, 4, 0).Size() == 5.0 && FVector(0, 0, 0).Size() == 0.0;
	}
}
