/**
 * @version v1
 * @summary Remove deletes every matching float and leaves non-matches in place.
 * @topic Containers
 *
 * RemoveAllMatchesFloat
 */
/**
 * @begin RemoveAllMatchesFloat
 * @summary Remove deletes every matching float and leaves non-matches in place.
 * @topic Containers
 */
bool RemoveAllMatchesFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Add(1.0f);
	int Removed = Values.Remove(1.0f);
	int Missing = Values.Remove(9.0f);
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values[0] == 2.0f;
}
/** @end */
