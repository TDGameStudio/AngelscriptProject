/**
 * @version v1
 * @summary AddUnique is false for a duplicate FString and true for a new value.
 * @topic Containers
 *
 * AddUniqueRejectsDuplicateFString
 */
/**
 * @begin AddUniqueRejectsDuplicateFString
 * @summary AddUnique is false for a duplicate FString and true for a new value.
 * @topic Containers
 */
bool AddUniqueRejectsDuplicateFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	bool bDuplicate = Values.AddUnique("alpha");
	bool bUnique = Values.AddUnique("gamma");
	return !bDuplicate && bUnique && Values.Num() == 2 && Values.Contains("gamma");
}
/** @end */
