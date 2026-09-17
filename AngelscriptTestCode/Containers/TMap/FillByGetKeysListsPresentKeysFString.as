/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled so GetKeys can list present keys.
 * @topic Containers
 *
 * FillByGetKeysListsPresentKeysFString
 */
/**
 * @begin FillByGetKeysListsPresentKeysFString
 * @summary An &out TMap<FString, int> is filled so GetKeys can list present keys.
 * @topic Containers
 */
void FillByGetKeysListsPresentKeysFString(TMap<FString, int>&out Result)
{
	Result.Add("alpha", 100);
	Result.Add("beta", 200);
	Result.Add("gamma", 300);
}
/** @end */
