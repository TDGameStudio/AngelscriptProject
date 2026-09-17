/**
 * @version v1
 * @summary Get returns the stored FVector while set and the fallback while unset.
 * @topic Containers
 *
 * GetReturnsStoredValueFVector
 */
/**
 * @begin GetReturnsStoredValueFVector
 * @summary Get returns the stored FVector while set and the fallback while unset.
 * @topic Containers
 */
bool GetReturnsStoredValueFVector()
{
	TOptional<FVector> Empty;
	FVector Fallback = FVector(0.0f, 1.0f, 0.0f);
	const FVector& FromEmpty = Empty.Get(Fallback);
	TOptional<FVector> SetValue;
	SetValue.Set(FVector(1.0f, 0.0f, 0.0f));
	const FVector& FromSet = SetValue.Get(Fallback);
	return FromEmpty.Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Fallback.Equals(FVector(0.0f, 1.0f, 0.0f))
		&& FromSet.Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
