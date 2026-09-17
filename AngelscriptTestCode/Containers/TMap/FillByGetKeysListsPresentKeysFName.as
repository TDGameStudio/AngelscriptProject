/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled so GetKeys can list present keys.
 * @topic Containers
 *
 * FillByGetKeysListsPresentKeysFName
 */
/**
 * @begin FillByGetKeysListsPresentKeysFName
 * @summary An &out TMap<FName, int> is filled so GetKeys can list present keys.
 * @topic Containers
 */
void FillByGetKeysListsPresentKeysFName(TMap<FName, int>&out Result)
{
	Result.Add(n"Red", 1);
	Result.Add(n"Green", 2);
	Result.Add(n"Blue", 3);
}
/** @end */
