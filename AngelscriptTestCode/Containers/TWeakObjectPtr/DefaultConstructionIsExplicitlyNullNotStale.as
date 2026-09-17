/**
 * @version v1
 * @summary Default TWeakObjectPtr is explicitly null and not stale.
 * @topic Containers
 *
 * DefaultConstructionIsExplicitlyNullNotStale
 */
/**
 * @begin DefaultConstructionIsExplicitlyNullNotStale
 * @summary Default TWeakObjectPtr is explicitly null and not stale.
 * @topic Containers
 */
bool DefaultConstructionIsExplicitlyNullNotStale()
{
	TWeakObjectPtr<UObject> Weak;
	return Weak.IsExplicitlyNull() && !Weak.IsStale();
}
/** @end */
