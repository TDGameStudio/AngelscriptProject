/**
 * @version v1
 * @summary Range-for visits every bool and indexed range-for counts the slots.
 * @topic Containers
 *
 * ForEachElementBool
 */
/**
 * @begin ForEachElementBool
 * @summary Range-for visits every bool and indexed range-for counts the slots.
 * @topic Containers
 */
bool ForEachElementBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Add(false);
	int32 MutableCount = 0;
	for (bool& Value : Values)
	{
		if (Value)
		{
			MutableCount += 1;
		}
	}
	int32 ConstCount = 0;
	const TArray<bool> ConstValues = Values;
	for (const bool& Value : ConstValues)
	{
		ConstCount += 1;
	}
	int32 IndexedCount = 0;
	for (int Index, bool& Value : Values)
	{
		IndexedCount += Index + 1;
	}
	return MutableCount == 1 && ConstCount == 3 && IndexedCount == 6;
}
/** @end */
