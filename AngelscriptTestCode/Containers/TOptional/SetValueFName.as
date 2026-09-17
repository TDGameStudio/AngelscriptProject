/**
 * @version v1
 * @summary Set stores an FName and marks the optional set.
 * @topic Containers
 *
 * SetValueFName
 */
/**
 * @begin SetValueFName
 * @summary Set stores an FName and marks the optional set.
 * @topic Containers
 */
bool SetValueFName()
{
	TOptional<FName> Optional;
	Optional.Set(n"Red");
	return Optional.IsSet() && Optional.GetValue() == n"Red";
}
/** @end */
