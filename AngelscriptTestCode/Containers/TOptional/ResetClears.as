/**
 * @version v1
 * @summary Reset after Set leaves the optional unset.
 * @topic Containers
 *
 * ResetClears
 */
/**
 * @begin ResetClears
 * @summary Reset after Set leaves the optional unset.
 * @topic Containers
 */
bool ResetClears()
{
	TOptional<int32> Optional;
	Optional.Set(7);
	Optional.Reset();
	bool bResetUnset = !Optional.IsSet();
	Optional.Reset();
	return bResetUnset && !Optional.IsSet();
}
/** @end */
