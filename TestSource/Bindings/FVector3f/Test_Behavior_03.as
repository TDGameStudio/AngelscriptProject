// Purpose: Observe FVector3f Normalize, projection, snap/bound helpers,
// reciprocal, mirror, plane project, rotate, and 2D cosine.
// AS-facing API: Normalize; Projection; GridSnap; BoundToCube; BoundToBox;
// Reciprocal; MirrorByVector; VectorPlaneProject; RotateAngleAxis;
// CosineAngle2D.
// Inputs: (3,0,0) and zero for Normalize, (2,4,2) projection, (1.2,2.7,-1.4)
// snap 1, (10,0,-20) cube 5, box (0,0,0)-(1,1,1), (2,0,0) reciprocal, (1,1,0)
// mirrored by X, (1,2,3) onto Z, (1,0,0) rotated 90 about Z, XY (1,0,*) vs
// (0,1,*).
// Expected observations: Normalize of (3,0,0) yields unit X and true. Zero
// stays zero and false. Projection of (2,4,2) is (1,2,1). GridSnap rounds.
// Cube/box clamp. Reciprocal of 2 is 0.5; zero uses __BIG_NUMBER_flt. Mirror
// of (1,1,0) across X is (-1,1,0). Plane project drops Z. 90 deg maps X to
// Y. Cosine of aligned XY is 1.
// Boundary/ownership: Normalize mutates. Reciprocal of zero is BIG_NUMBER,
// not an exception. RotateAngleAxis returns a new vector.

namespace TS_FVector3f_Behavior_03
{
	bool Observe_Normalize_Nominal()
	{
		FVector3f Vector(3.0f, 0.0f, 0.0f);
		bool bNormalized = Vector.Normalize();
		FVector3f Zero;
		bool bZeroFailed = Zero.Normalize();
		return bNormalized && Vector.Equals(FVector3f(1.0f, 0.0f, 0.0f)) && !bZeroFailed && Zero.IsZero();
	}

	bool Observe_Projection_Nominal()
	{
		FVector3f Projected = FVector3f(2.0f, 4.0f, 2.0f).Projection();
		return Projected.Equals(FVector3f(1.0f, 2.0f, 1.0f));
	}

	bool Observe_GridSnap_Nominal()
	{
		FVector3f Snapped = FVector3f(1.2f, 2.7f, -1.4f).GridSnap(1.0f);
		return Snapped.Equals(FVector3f(1.0f, 3.0f, -1.0f));
	}

	bool Observe_BoundToCube_Nominal()
	{
		FVector3f Cubed = FVector3f(10.0f, 0.0f, -20.0f).BoundToCube(5.0f);
		return Cubed.Equals(FVector3f(5.0f, 0.0f, -5.0f));
	}

	bool Observe_BoundToBox_Nominal()
	{
		FVector3f Boxed = FVector3f(2.0f, -1.0f, 0.5f).BoundToBox(FVector3f(0.0f, 0.0f, 0.0f), FVector3f(1.0f, 1.0f, 1.0f));
		return Boxed.Equals(FVector3f(1.0f, 0.0f, 0.5f));
	}

	bool Observe_Reciprocal_Nominal()
	{
		FVector3f Reciprocal = FVector3f(2.0f, 4.0f, 0.0f).Reciprocal();
		return Reciprocal.X == 0.5f && Reciprocal.Y == 0.25f && Reciprocal.Z == __BIG_NUMBER_flt;
	}

	bool Observe_MirrorByVector_Nominal()
	{
		FVector3f Mirrored = FVector3f(1.0f, 1.0f, 0.0f).MirrorByVector(FVector3f(1.0f, 0.0f, 0.0f));
		return Mirrored.Equals(FVector3f(-1.0f, 1.0f, 0.0f));
	}

	bool Observe_VectorPlaneProject_Nominal()
	{
		FVector3f Projected = FVector3f(1.0f, 2.0f, 3.0f).VectorPlaneProject(FVector3f(0.0f, 0.0f, 1.0f));
		return Projected.Equals(FVector3f(1.0f, 2.0f, 0.0f));
	}

	bool Observe_RotateAngleAxis_Nominal()
	{
		FVector3f Rotated = FVector3f(1.0f, 0.0f, 0.0f).RotateAngleAxis(90.0f, FVector3f(0.0f, 0.0f, 1.0f));
		return Rotated.Equals(FVector3f(0.0f, 1.0f, 0.0f));
	}

	bool Observe_CosineAngle2D_Nominal()
	{
		float32 Aligned = FVector3f(1.0f, 0.0f, 5.0f).CosineAngle2D(FVector3f(1.0f, 0.0f, 9.0f));
		float32 Perp = FVector3f(1.0f, 0.0f, 0.0f).CosineAngle2D(FVector3f(0.0f, 1.0f, 0.0f));
		return Aligned == 1.0f && Perp == 0.0f;
	}
}
