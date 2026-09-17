/**
 * @version v1
 * @summary An &out TMap<FString, int> is filled by FindOrAdd of three keys.
 * @topic Containers
 *
 * FillByFindOrAddInsertsFString
 */
/**
 * @begin FillByFindOrAddInsertsFString
 * @summary An &out TMap<FString, int> is filled by FindOrAdd of three keys.
 * @topic Containers
 */
void FillByFindOrAddInsertsFString(TMap<FString, int>&out Result)
{
	Result.FindOrAdd("alpha") = 100;
	Result.FindOrAdd("beta") = 200;
	Result.FindOrAdd("gamma") = 300;
}
/** @end */
