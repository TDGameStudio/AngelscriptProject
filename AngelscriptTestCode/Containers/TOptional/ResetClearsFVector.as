/**
 * @version v1
 * @summary Reset after Set leaves TOptional<FVector> unset.
 * @topic Containers
 *
 * ResetClearsFVector
 */
/**
 * @begin ResetClearsFVector
 * @summary Reset after Set leaves TOptional<FVector> unset.
 * @topic Containers
 */
bool ResetClearsFVector()
{
	TOptional<FVector> Optional;
	Optional.Set(FVector(1.0f, 0.0f, 0.0f));
	Optional.Reset();
	bool bResetUnset = !Optional.IsSet();
	Optional.Reset();
	return bResetUnset && !Optional.IsSet();
}
/** @end */
