/**
 * @version v1
 * @summary Append copies the other FString array onto the end and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherArrayFString
 */
/**
 * @begin AppendOtherArrayFString
 * @summary Append copies the other FString array onto the end and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherArrayFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	TArray<FString> Other;
	Other.Add("beta");
	Other.Add("gamma");
	Values.Append(Other);
	TArray<FString> EmptyOther;
	Values.Append(EmptyOther);
	return Values.Num() == 3 && Values[1] == "beta" && Values[2] == "gamma" && Other.Num() == 2;
}
/** @end */
