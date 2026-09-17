/**
 * @version v1
 * @summary Last() write-through is visible on TArray<FString> and Last(1) reads from the end.
 * @topic Containers
 *
 * LastValidIndexFString
 */
/**
 * @begin LastValidIndexFString
 * @summary Last() write-through is visible on TArray<FString> and Last(1) reads from the end.
 * @topic Containers
 */
bool LastValidIndexFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	FString& LastMut = Values.Last();
	bool bLastIsGamma = LastMut == "gamma";
	LastMut = "omega";
	FString& FromEnd = Values.Last(1);
	const TArray<FString> ConstValues = Values;
	const FString& ConstLast = ConstValues.Last();
	const FString& ConstFromEnd = ConstValues.Last(1);
	return bLastIsGamma && Values[2] == "omega" && FromEnd == "beta" && ConstLast == "omega" && ConstFromEnd == "beta";
}
/** @end */
