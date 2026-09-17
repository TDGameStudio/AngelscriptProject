/**
 * @version v1
 * @summary RemoveAt drops the indexed float and shifts later elements down.
 * @topic Containers
 *
 * RemoveAtIndexFloat
 */
/**
 * @begin RemoveAtIndexFloat
 * @summary RemoveAt drops the indexed float and shifts later elements down.
 * @topic Containers
 */
bool RemoveAtIndexFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Add(3.0f);
	Values.RemoveAt(1);
	return Values.Num() == 2 && Values[0] == 1.0f && Values[1] == 3.0f;
}
/** @end */
