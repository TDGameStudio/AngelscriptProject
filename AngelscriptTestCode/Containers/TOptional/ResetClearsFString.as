/**
 * @version v1
 * @summary Reset after Set leaves TOptional<FString> unset.
 * @topic Containers
 *
 * ResetClearsFString
 */
/**
 * @begin ResetClearsFString
 * @summary Reset after Set leaves TOptional<FString> unset.
 * @topic Containers
 */
bool ResetClearsFString()
{
	TOptional<FString> Optional;
	Optional.Set("alpha");
	Optional.Reset();
	bool bResetUnset = !Optional.IsSet();
	Optional.Reset();
	return bResetUnset && !Optional.IsSet();
}
/** @end */
