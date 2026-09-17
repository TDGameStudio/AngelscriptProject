/**
 * @version v1
 * @summary Unbound UE TMap aliases have no matching signatures.
 * @topic Containers
 *
 * UnsupportedApiAliases
 */
/**
 * @begin UnsupportedApiAliases
 * @summary Unbound UE TMap aliases have no matching signatures.
 * @topic Containers
 */
UCLASS()
class UTMapUnsupportedApiAliasesReject : UObject
{
	void Test()
	{
		TMap<int, FString> Values;
		TMap<int, FString> Other;
		TArray<int> Keys;
		TArray<FString> OutValues;
		Values.Add(1, "One");
		Values.GenerateKeyArray(Keys);
		Values.GenerateValueArray(OutValues);
		Values.FindRef(1);
		Values.FindChecked(1);
		Values.Reserve(8);
		Values.Shrink();
		Values.Append(Other);
		Values.FilterByPredicate(1);
	}
}
/** @end */
