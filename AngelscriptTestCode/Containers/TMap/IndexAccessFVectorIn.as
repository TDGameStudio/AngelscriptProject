/**
 * @version v1
 * @summary Bracket access on a const TMap<int,FVector>&in reads stored values without writing the map back.
 * @topic Containers
 *
 * IndexAccessFVectorIn
 */
/**
 * @begin IndexAccessFVectorIn
 * @summary Bracket access on a const TMap<int,FVector>&in reads stored values without writing the map back.
 * @topic Containers
 */
bool IndexAccessFVectorIn(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 3
		&& Values[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[3].Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
