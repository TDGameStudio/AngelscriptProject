/**
 * @version v1
 * @summary RemoveSingle removes the first matching FString and keeps later elements in order.
 * @topic Containers
 *
 * RemoveSinglePreservesOrderFString
 */
/**
 * @begin RemoveSinglePreservesOrderFString
 * @summary RemoveSingle removes the first matching FString and keeps later elements in order.
 * @topic Containers
 */
bool RemoveSinglePreservesOrderFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("alpha");
	int Removed = Values.RemoveSingle("alpha");
	int Missing = Values.RemoveSingle("zeta");
	return Removed == 1 && Missing == 0 && Values.Num() == 2 && Values[0] == "beta" && Values[1] == "alpha";
}
/** @end */
