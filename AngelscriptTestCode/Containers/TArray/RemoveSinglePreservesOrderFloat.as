/**
 * @version v1
 * @summary RemoveSingle removes the first matching float and keeps later elements in order.
 * @topic Containers
 *
 * RemoveSinglePreservesOrderFloat
 */
/**
 * @begin RemoveSinglePreservesOrderFloat
 * @summary RemoveSingle removes the first matching float and keeps later elements in order.
 * @topic Containers
 */
bool RemoveSinglePreservesOrderFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Add(1.0f);
	int Removed = Values.RemoveSingle(1.0f);
	int Missing = Values.RemoveSingle(9.0f);
	return Removed == 1 && Missing == 0 && Values.Num() == 2 && Values[0] == 2.0f && Values[1] == 1.0f;
}
/** @end */
