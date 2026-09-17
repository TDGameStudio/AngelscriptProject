/**
 * @version v1
 * @summary Set stores a value and marks the optional set.
 * @topic Containers
 *
 * SetValue
 */
/**
 * @begin SetValue
 * @summary Set stores a value and marks the optional set.
 * @topic Containers
 */
bool SetValue()
{
	TOptional<int32> Optional;
	Optional.Set(7);
	TOptional<FName> Named;
	Named.Set(n"Alpha");
	return Optional.IsSet() && Optional.GetValue() == 7
		&& Named.IsSet() && Named.GetValue() == n"Alpha";
}
/** @end */
