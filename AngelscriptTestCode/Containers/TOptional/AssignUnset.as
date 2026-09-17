/**
 * @version v1
 * @summary Assigning an unset TOptional unsets a previously set target.
 * @topic Containers
 *
 * AssignUnset
 */
/**
 * @begin AssignUnset
 * @summary Assigning an unset TOptional unsets a previously set target.
 * @topic Containers
 */
bool AssignUnset()
{
	TOptional<int32> Target;
	Target.Set(42);
	if (!Target.IsSet())
	{
		return false;
	}

	TOptional<int32> Unset;
	Target = Unset;
	return !Target.IsSet();
}
/** @end */
