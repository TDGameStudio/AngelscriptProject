/**
 * @version v1
 * @summary A const&in TOptional<FVector> reports IsSet after Set.
 * @topic Containers
 *
 * ReadIsSetAfterSetFVector
 */
/**
 * @begin ReadIsSetAfterSetFVector
 * @summary A const&in TOptional<FVector> reports IsSet after Set.
 * @topic Containers
 */
bool ReadIsSetAfterSetFVector(const TOptional<FVector>&in Value)
{
	return Value.IsSet();
}
/** @end */
