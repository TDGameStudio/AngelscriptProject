/**
 * @version v1
 * @summary Observe default FMatrix construction and identity position/vector transforms, including homogeneous W.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe default FMatrix construction and identity position/vector transforms, including homogeneous W.
 * @topic Baseline
 */
// FVector4 FMatrix.TransformPosition(const FVector& Position) const;
// FVector4 FMatrix.TransformVector(const FVector& Vector) const;
// Inputs: Default-constructed matrix, Identity() as the valid transform,
// position (1,2,3), direction (1,2,3), and ZeroVector.
// Expected observations: Identity TransformPosition keeps XYZ and sets W=1.
// TransformVector keeps XYZ and sets W=0. ZeroVector position has W=1;
// ZeroVector direction has W=0.
// Boundary/ownership: Default construction is uninitialized; use Identity()
// when an identity matrix is required. Transform helpers return FVector4.

namespace TS_FMatrix_Behavior_01
{
	bool Observe_Matrix_Nominal()
	{
		FMatrix Matrix;
		FMatrix Identity = FMatrix::Identity();
		FVector4 Origin = Identity.TransformPosition(FVector::ZeroVector);
		return Origin.X == 0.0 && Origin.Y == 0.0 && Origin.Z == 0.0 && Origin.W == 1.0;
	}

	bool Observe_TransformPosition_Nominal()
	{
		FMatrix Identity = FMatrix::Identity();
		FVector4 Position = Identity.TransformPosition(FVector(1, 2, 3));
		FVector4 Origin = Identity.TransformPosition(FVector::ZeroVector);
		return Position.X == 1.0 && Position.Y == 2.0 && Position.Z == 3.0 && Position.W == 1.0 && Origin.X == 0.0 && Origin.W == 1.0;
	}

	bool Observe_TransformVector_Nominal()
	{
		FMatrix Identity = FMatrix::Identity();
		FVector4 Vector = Identity.TransformVector(FVector(1, 2, 3));
		FVector4 Zero = Identity.TransformVector(FVector::ZeroVector);
		return Vector.X == 1.0 && Vector.Y == 2.0 && Vector.Z == 3.0 && Vector.W == 0.0 && Zero.W == 0.0;
	}
}
/** @end */
