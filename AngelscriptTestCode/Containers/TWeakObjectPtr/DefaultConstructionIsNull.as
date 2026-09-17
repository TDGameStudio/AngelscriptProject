/**
 * @version v1
 * @summary Default TWeakObjectPtr<UObject> is null and not valid.
 * @topic Containers
 *
 * DefaultConstructionIsNull
 */
/**
 * @begin DefaultConstructionIsNull
 * @summary Default TWeakObjectPtr<UObject> is null and not valid.
 * @topic Containers
 */
bool DefaultConstructionIsNull()
{
	TWeakObjectPtr<UObject> Weak;
	return Weak.Get() == nullptr && !Weak.IsValid();
}
/** @end */
