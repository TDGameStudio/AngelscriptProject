/**
 * @version v1
 * @summary A second Set replaces the stored value and keeps the optional set.
 * @topic Containers
 *
 * Overwrite
 */
/**
 * @begin Overwrite
 * @summary A second Set replaces the stored value and keeps the optional set.
 * @topic Containers
 */
bool Overwrite()
{
	TOptional<int32> Optional;
	Optional.Set(1);
	if (!Optional.IsSet() || Optional.GetValue() != 1)
	{
		return false;
	}

	Optional.Set(2);
	return Optional.IsSet() && Optional.GetValue() == 2;
}
/** @end */
