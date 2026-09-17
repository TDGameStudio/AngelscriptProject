/**
 * @version v1
 * @summary Range-for visits every float and indexed range-for adds the index.
 * @topic Containers
 *
 * ForEachElementFloat
 */
/**
 * @begin ForEachElementFloat
 * @summary Range-for visits every float and indexed range-for adds the index.
 * @topic Containers
 */
bool ForEachElementFloat()
{
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	Values.Add(30.0f);
	float MutableSum = 0.0f;
	for (float& Value : Values)
	{
		MutableSum += Value;
	}
	float ConstSum = 0.0f;
	const TArray<float> ConstValues = Values;
	for (const float& Value : ConstValues)
	{
		ConstSum += Value;
	}
	float IndexedMutable = 0.0f;
	for (int Index, float& Value : Values)
	{
		IndexedMutable += Value + float(Index);
	}
	return MutableSum == 60.0f && ConstSum == 60.0f && IndexedMutable == 63.0f;
}
/** @end */
