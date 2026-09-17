/**
 * @version v1
 * @summary A const&in TOptional<FVector> reports the value stored by Set.
 * @topic Containers
 *
 * ReadSetValueFVector
 */
/**
 * @begin ReadSetValueFVector
 * @summary A const&in TOptional<FVector> reports the value stored by Set.
 * @topic Containers
 */
bool ReadSetValueFVector(const TOptional<FVector>&in Value)
{
	return Value.IsSet() && Value.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
