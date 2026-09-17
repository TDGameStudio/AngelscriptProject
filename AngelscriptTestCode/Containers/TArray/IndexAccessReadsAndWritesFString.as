/**
 * @version v1
 * @summary Operator [] reads and writes FString elements, including const aliases.
 * @topic Containers
 *
 * IndexAccessReadsAndWritesFString
 */
/**
 * @begin IndexAccessReadsAndWritesFString
 * @summary Operator [] reads and writes FString elements, including const aliases.
 * @topic Containers
 */
bool IndexAccessReadsAndWritesFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	FString& Mutable = Values[0];
	bool bFirstIsAlpha = Mutable == "alpha";
	Mutable = "gamma";
	FString AfterWrite = Values[0];
	FString Last = Values[1];
	const TArray<FString> ConstValues = Values;
	const FString& ConstFirst = ConstValues[0];
	return bFirstIsAlpha && AfterWrite == "gamma" && Last == "beta" && ConstFirst == "gamma";
}
/** @end */
