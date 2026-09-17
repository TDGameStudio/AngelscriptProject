/**
 * @version v1
 * @summary Mutable GetValue writes through to the stored FVector.
 * @topic Containers
 *
 * GetValueReturnsStoredIntFVector
 */
/**
 * @begin GetValueReturnsStoredIntFVector
 * @summary Mutable GetValue writes through to the stored FVector.
 * @topic Containers
 */
bool GetValueReturnsStoredIntFVector()
{
	TOptional<FVector> Optional;
	Optional.Set(FVector(1.0f, 0.0f, 0.0f));
	FVector& Mutable = Optional.GetValue();
	bool bMutableIsX = Mutable.Equals(FVector(1.0f, 0.0f, 0.0f));
	Mutable = FVector(0.0f, 1.0f, 0.0f);
	const FVector& ConstValue = Optional.GetValue();
	return bMutableIsX && ConstValue.Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
