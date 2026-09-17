/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled so GetKeys can list present keys.
 * @topic Containers
 *
 * FillByGetKeysListsPresentKeysBool
 */
/**
 * @begin FillByGetKeysListsPresentKeysBool
 * @summary An &out TMap<int, bool> is filled so GetKeys can list present keys.
 * @topic Containers
 */
void FillByGetKeysListsPresentKeysBool(TMap<int, bool>&out Result)
{
	Result.Add(1, true);
	Result.Add(2, false);
	Result.Add(3, true);
}
/** @end */
