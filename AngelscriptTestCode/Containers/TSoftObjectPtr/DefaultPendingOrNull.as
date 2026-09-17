/**
 * @version v1
 * @summary A default TSoftObjectPtr is null, not pending or valid.
 * @topic Containers
 * DefaultPendingOrNull
 */
/**
 * @begin DefaultPendingOrNull
 * @summary A default TSoftObjectPtr is null, not pending or valid.
 * @topic Containers
 */
bool DefaultPendingOrNull()
{
	TSoftObjectPtr<UObject> Soft;
	return Soft.IsNull() && !Soft.IsPending() && !Soft.IsValid() && Soft.Get() == nullptr;
}
/** @end */
