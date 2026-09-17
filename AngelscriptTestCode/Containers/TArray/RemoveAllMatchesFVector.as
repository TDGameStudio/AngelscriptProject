/**
 * @version v1
 * @summary Remove deletes every matching FVector and leaves non-matches in place.
 * @topic Containers
 *
 * RemoveAllMatchesFVector
 */
/**
 * @begin RemoveAllMatchesFVector
 * @summary Remove deletes every matching FVector and leaves non-matches in place.
 * @topic Containers
 */
bool RemoveAllMatchesFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	int Removed = Values.Remove(FVector(1.0f, 0.0f, 0.0f));
	int Missing = Values.Remove(FVector(0.0f, 0.0f, 1.0f));
	return Removed == 2 && Missing == 0 && Values.Num() == 1
		&& Values[0].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
