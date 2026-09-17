/**
 * @version v1
 * @summary Set stores false and still marks the optional set.
 * @topic Containers
 *
 * SetValueBool
 */
/**
 * @begin SetValueBool
 * @summary Set stores false and still marks the optional set.
 * @topic Containers
 */
bool SetValueBool()
{
	TOptional<bool> Optional;
	Optional.Set(false);
	return Optional.IsSet() && Optional.GetValue() == false;
}
/** @end */
