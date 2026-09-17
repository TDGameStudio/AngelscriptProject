/**
 * @version v1
 * @summary Last() write-through is visible on TArray<float> and Last(1) reads from the end.
 * @topic Containers
 *
 * LastValidIndexFloat
 */
/**
 * @begin LastValidIndexFloat
 * @summary Last() write-through is visible on TArray<float> and Last(1) reads from the end.
 * @topic Containers
 */
bool LastValidIndexFloat()
{
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	Values.Add(30.0f);
	float& LastMut = Values.Last();
	bool bLastIsThirty = LastMut == 30.0f;
	LastMut = 31.0f;
	float& FromEnd = Values.Last(1);
	const TArray<float> ConstValues = Values;
	const float& ConstLast = ConstValues.Last();
	const float& ConstFromEnd = ConstValues.Last(1);
	return bLastIsThirty && Values[2] == 31.0f && FromEnd == 20.0f && ConstLast == 31.0f && ConstFromEnd == 20.0f;
}
/** @end */
