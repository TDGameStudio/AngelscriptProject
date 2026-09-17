/**
 * @version v1
 * @summary TOptional<int32> set to 0 is set.
 * @topic Containers
 *
 * StoredZeroIsSet
 */
/**
 * @begin StoredZeroIsSet
 * @summary TOptional<int32> set to 0 is set and GetValue is 0.
 * @topic Containers
 */
bool StoredZeroIsSet()
{
	TOptional<int32> Optional;
	Optional.Set(0);
	return Optional.IsSet() && Optional.GetValue() == 0;
}
/** @end */
