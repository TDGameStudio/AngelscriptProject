/**
 * @version v1
 * @summary Set stores an FVector and marks the optional set.
 * @topic Containers
 *
 * SetValueFVector
 */
/**
 * @begin SetValueFVector
 * @summary Set stores an FVector and marks the optional set.
 * @topic Containers
 */
bool SetValueFVector()
{
	TOptional<FVector> Optional;
	Optional.Set(FVector(1.0f, 0.0f, 0.0f));
	return Optional.IsSet() && Optional.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
