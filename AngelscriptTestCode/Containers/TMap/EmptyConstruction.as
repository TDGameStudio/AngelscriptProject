/**
 * @version v1
 * @summary Default TMap<FName,int32>, TMap<FString,int32>, and TMap<FName,FString> are empty.
 * @topic Containers
 *
 * EmptyConstruction
 */
/**
 * @begin EmptyConstruction
 * @summary Default TMap<FName,int32>, TMap<FString,int32>, and TMap<FName,FString> are empty.
 * @topic Containers
 */
bool EmptyConstruction()
{
	TMap<FName, int32> Map;
	TMap<FString, int32> StringMap;
	TMap<FName, FString> NameToString;
	return Map.IsEmpty() && Map.Num() == 0
		&& StringMap.IsEmpty() && NameToString.IsEmpty();
}
/** @end */
