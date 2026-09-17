/**
 * @version v1
 * @summary Reset after Set leaves TOptional<FName> unset.
 * @topic Containers
 *
 * ResetClearsFName
 */
/**
 * @begin ResetClearsFName
 * @summary Reset after Set leaves TOptional<FName> unset.
 * @topic Containers
 */
bool ResetClearsFName()
{
	TOptional<FName> Optional;
	Optional.Set(n"Red");
	Optional.Reset();
	bool bResetUnset = !Optional.IsSet();
	Optional.Reset();
	return bResetUnset && !Optional.IsSet();
}
/** @end */
