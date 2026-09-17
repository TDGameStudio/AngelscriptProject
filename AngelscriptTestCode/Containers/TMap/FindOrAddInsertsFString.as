/**
 * @version v1
 * @summary FindOrAdd of a missing FString key inserts a default and does not throw.
 * @topic Containers
 *
 * FindOrAddInsertsFString
 */
/**
 * @begin FindOrAddInsertsFString
 * @summary FindOrAdd of a missing FString key inserts a default and does not throw.
 * @topic Containers
 */
bool FindOrAddInsertsFString()
{
	TMap<FString, int> Map;
	int Added = Map.FindOrAdd("beta");
	return Added == 0 && Map.Num() == 1 && Map.Contains("beta") && Map["beta"] == 0;
}
/** @end */
