/**
 * @version v1
 * @summary A const&in TArray<FString> reports unique AddUnique order.
 * @topic Containers
 *
 * ReadAddUniqueRejectsDuplicateFString
 */
/**
 * @begin ReadAddUniqueRejectsDuplicateFString
 * @summary A const&in TArray<FString> reports unique AddUnique order.
 * @topic Containers
 */
bool ReadAddUniqueRejectsDuplicateFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma";
}
/** @end */
