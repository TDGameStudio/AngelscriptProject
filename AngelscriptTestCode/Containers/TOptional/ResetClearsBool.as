/**
 * @version v1
 * @summary Reset after Set of false leaves TOptional<bool> unset.
 * @topic Containers
 *
 * ResetClearsBool
 */
/**
 * @begin ResetClearsBool
 * @summary Reset after Set of false leaves TOptional<bool> unset.
 * @topic Containers
 */
bool ResetClearsBool()
{
	TOptional<bool> Optional;
	Optional.Set(false);
	bool bWasSet = Optional.IsSet();
	Optional.Reset();
	return bWasSet && !Optional.IsSet() && Optional.Get(true) == true;
}
/** @end */
