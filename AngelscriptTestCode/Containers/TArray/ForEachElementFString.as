/**
 * @version v1
 * @summary Range-for visits every FString and indexed range-for adds the index.
 * @topic Containers
 *
 * ForEachElementFString
 */
/**
 * @begin ForEachElementFString
 * @summary Range-for visits every FString and indexed range-for adds the index.
 * @topic Containers
 */
bool ForEachElementFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	FString MutableJoined = "";
	for (FString& Value : Values)
	{
		MutableJoined += Value;
	}
	FString ConstJoined = "";
	const TArray<FString> ConstValues = Values;
	for (const FString& Value : ConstValues)
	{
		ConstJoined += Value;
	}
	int32 IndexedCount = 0;
	for (int Index, FString& Value : Values)
	{
		IndexedCount += Index + 1;
	}
	return MutableJoined == "alphabetagamma" && ConstJoined == "alphabetagamma" && IndexedCount == 6;
}
/** @end */
