/**
 * @version v1
 * @summary FMatrix host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FMatrix
 *
 * matrix
 * transform-position
 * transform-vector
 * identity
 */
/**
 * @begin matrix
 * @summary Boundary/ownership: Default construction is uninitialized;
 * @topic Unreal
 */
/**
 * @function ObserveMatrixNominal
 * @summary Boundary/ownership: Default construction is uninitialized;
 * @covers FMatrix.matrix
 * @inputs FMatrix values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: Default construction is uninitialized;

 use Identity()
// when an identity matrix is required. Transform helpers return FVector4.
bool ObserveMatrixNominal()
{
	FMatrix Matrix;
	FMatrix Identity = FMatrix::Identity();
	FVector4 Origin = Identity.TransformPosition(FVector::ZeroVector);
	return Origin.X == 0.0 && Origin.Y == 0.0 && Origin.Z == 0.0 && Origin.W == 1.0;
}
/** @end */
/**
 * @begin transform-position
 * @summary when an identity matrix is required.
 * @topic Unreal
 */
/**
 * @function ObserveTransformPositionNominal
 * @summary when an identity matrix is required.
 * @covers FMatrix.transform-position
 * @inputs FMatrix values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: Default construction is uninitialized;

bool ObserveTransformPositionNominal()
{
	FMatrix Identity = FMatrix::Identity();
	FVector4 Position = Identity.TransformPosition(FVector(1, 2, 3));
	FVector4 Origin = Identity.TransformPosition(FVector::ZeroVector);
	return Position.X == 1.0 && Position.Y == 2.0 && Position.Z == 3.0 && Position.W == 1.0 && Origin.X == 0.0 && Origin.W == 1.0;
}
/** @end */
/**
 * @begin transform-vector
 * @summary when an identity matrix is required.
 * @topic Unreal
 */
/**
 * @function ObserveTransformVectorNominal
 * @summary when an identity matrix is required.
 * @covers FMatrix.transform-vector
 * @inputs FMatrix values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership: Default construction is uninitialized;

bool ObserveTransformVectorNominal()
{
	FMatrix Identity = FMatrix::Identity();
	FVector4 Vector = Identity.TransformVector(FVector(1, 2, 3));
	FVector4 Zero = Identity.TransformVector(FVector::ZeroVector);
	return Vector.X == 1.0 && Vector.Y == 2.0 && Vector.Z == 3.0 && Vector.W == 0.0 && Zero.W == 0.0;
}
/** @end */
/**
 * @begin identity
 * @summary A
 * @topic Unreal
 */
/**
 * @function ObserveIdentityNominal
 * @summary A
 * @covers FMatrix.identity
 * @inputs FMatrix values exercised by this observe
 * @return true when the observe comparison holds
 */
// A

 second Identity() produces the same transform. Default construction is
// not used here; Identity() is the published identity factory.
// Boundary/ownership: Identity() returns a new matrix value. It is not a
// shared FMatrix::Identity field.
bool ObserveIdentityNominal()
{
	FMatrix Identity = FMatrix::Identity();
	FMatrix Again = FMatrix::Identity();
	FVector4 Position = Identity.TransformPosition(FVector(1, 2, 3));
	FVector4 Repeated = Again.TransformPosition(FVector(1, 2, 3));
	return Position.X == 1.0 && Position.Y == 2.0 && Position.Z == 3.0 && Position.W == 1.0 && Repeated.X == 1.0 && Repeated.W == 1.0;
}
/** @end */
