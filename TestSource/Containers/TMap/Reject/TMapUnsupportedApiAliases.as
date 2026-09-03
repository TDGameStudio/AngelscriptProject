/**
 * Unbound UE TMap aliases have no matching signatures.
 *
 * @Theme Containers.TMap
 * @Subject TMap.UnsupportedApiAliases
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapUnsupportedApiAliases
 * @Kind CompileReject
 * @Covers TMap.Unsupported
 * @Inputs GenerateKeyArray / GenerateValueArray / FindRef / FindChecked / Reserve / Shrink / Append / FilterByPredicate
 * @Return does not compile
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
