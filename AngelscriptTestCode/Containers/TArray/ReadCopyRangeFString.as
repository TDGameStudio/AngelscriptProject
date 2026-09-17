/**
 * @version v1
 * @summary A const&in TArray<FString> reports a copied run.
 * @topic Containers
 *
 * ReadCopyRangeFString
 */
/**
 * @begin ReadCopyRangeFString
 * @summary A const&in TArray<FString> reports a copied run.
 * @topic Containers
 */
bool ReadCopyRangeFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "-" && Values[1] == "x" && Values[2] == "y";
}
/** @end */
