// Purpose: Observe FVector squared/2D size, in-place Normalize, projection,
// snap/bound helpers, reciprocal, and mirror.
// AS-facing API: SizeSquared; Size2D; SizeSquared2D; Normalize; Projection;
// GridSnap; BoundToCube; BoundToBox; Reciprocal; MirrorByVector.
// Inputs: (3,4,12) so SizeSquared is 169 and XY size is 5, (2,4,2) for
// projection, (1.2,2.7,-1.4) snap 1, (10,0,-20) cube radius 5, box
// (0,0,0)-(1,1,1), (2,0,0) and zero for reciprocal, (1,1,0) mirrored by X.
// Expected observations: SizeSquared of (3,4,12) is 169. Size2D of (3,4,12)
// is 5. Normalize of (3,0,0) yields unit X and true; zero stays zero and
// false. Projection of (2,4,2) is (1,2,1). GridSnap rounds to integers.
// Cube/box clamp components. Reciprocal of 2 is 0.5; zero uses BIG_NUMBER.
// Mirror of (1,1,0) across X is (-1,1,0).
// Boundary/ownership: Normalize mutates. Other helpers return copies.
// Reciprocal of zero is BIG_NUMBER, not an exception.

namespace TS_FVector_Behavior_03
{
	bool Observe_SizeSquared_Nominal()
	{
		return FVector(3, 4, 12).SizeSquared() == 169.0 && FVector(0, 0, 0).SizeSquared() == 0.0;
	}

	bool Observe_Size2D_Nominal()
	{
		return FVector(3, 4, 12).Size2D() == 5.0 && FVector(0, 0, 9).Size2D() == 0.0;
	}

	bool Observe_SizeSquared2D_Nominal()
	{
		return FVector(3, 4, 12).SizeSquared2D() == 25.0 && FVector(0, 0, 9).SizeSquared2D() == 0.0;
	}

	bool Observe_Normalize_Nominal()
	{
		FVector Vector(3, 0, 0);
		bool bNormalized = Vector.Normalize();
		FVector Zero;
		bool bZeroFailed = Zero.Normalize();
		return bNormalized && Vector.Equals(FVector(1, 0, 0)) && !bZeroFailed && Zero.IsZero();
	}

	bool Observe_Projection_Nominal()
	{
		FVector Projected = FVector(2, 4, 2).Projection();
		return Projected.Equals(FVector(1, 2, 1));
	}

	bool Observe_GridSnap_Nominal()
	{
		FVector Snapped = FVector(1.2, 2.7, -1.4).GridSnap(1.0);
		return Snapped.Equals(FVector(1, 3, -1));
	}

	bool Observe_BoundToCube_Nominal()
	{
		FVector Cubed = FVector(10, 0, -20).BoundToCube(5.0);
		return Cubed.Equals(FVector(5, 0, -5));
	}

	bool Observe_BoundToBox_Nominal()
	{
		FVector Boxed = FVector(2, -1, 0.5).BoundToBox(FVector(0, 0, 0), FVector(1, 1, 1));
		return Boxed.Equals(FVector(1, 0, 0.5));
	}

	bool Observe_Reciprocal_Nominal()
	{
		FVector Reciprocal = FVector(2, 4, 0).Reciprocal();
		return Reciprocal.X == 0.5 && Reciprocal.Y == 0.25 && Reciprocal.Z == BIG_NUMBER;
	}

	bool Observe_MirrorByVector_Nominal()
	{
		FVector Mirrored = FVector(1, 1, 0).MirrorByVector(FVector(1, 0, 0));
		return Mirrored.Equals(FVector(-1, 1, 0));
	}
}
