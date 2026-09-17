/**
 * @version v1
 * @summary Default TOptional<FVector> is unset and copy-independent.
 * @topic Containers
 *
 * EmptyConstructionFVector
 */
/**
 * @begin EmptyConstructionFVector
 * @summary Default TOptional<FVector> is unset and copy-independent.
 * @topic Containers
 */
bool EmptyConstructionFVector()
{
	TOptional<FVector> First;
	TOptional<FVector> Second;
	bool bDefaultUnset = !First.IsSet() && !Second.IsSet();
	First.Set(FVector(1.0f, 0.0f, 0.0f));
	return bDefaultUnset && First.IsSet() && !Second.IsSet();
}
/** @end */
