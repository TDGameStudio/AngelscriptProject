/**
 * @version v1
 * @summary A const&in TSet<UObject> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumUObject
 */
/**
 * @begin ReadResetClearsNumUObject
 * @summary A const&in TSet<UObject> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumUObject(const TSet<UObject>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
