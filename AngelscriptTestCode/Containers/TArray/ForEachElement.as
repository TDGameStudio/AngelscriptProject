/**
 * @version v1
 * @summary Range-for visits every element and indexed range-for adds the index.
 * @topic Containers
 *
 * ForEachElement
 */
/**
 * @begin ForEachElement
 * @summary Range-for visits every element and indexed range-for adds the index.
 * @topic Containers
 */
bool ForEachElement()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(30);
	int32 MutableSum = 0;
	for (int32& Value : Values)
	{
		MutableSum += Value;
	}
	int32 ConstSum = 0;
	const TArray<int32> ConstValues = Values;
	for (const int32& Value : ConstValues)
	{
		ConstSum += Value;
	}
	int32 IndexedMutable = 0;
	for (int Index, int32& Value : Values)
	{
		IndexedMutable += Value + Index;
	}
	int32 IndexedConst = 0;
	for (int Index, const int32& Value : ConstValues)
	{
		IndexedConst += Value + Index;
	}
	return MutableSum == 60 && ConstSum == 60 && IndexedMutable == 63 && IndexedConst == 63;
}
/** @end */
