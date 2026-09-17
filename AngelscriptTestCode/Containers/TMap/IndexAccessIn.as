/**
 * @version v1
 * @summary Bracket access on a const TMap<int,int>&in reads stored values without writing the map back.
 * @topic Containers
 *
 * IndexAccessIn
 */
/**
 * @begin IndexAccessIn
 * @summary Bracket access on a const TMap<int,int>&in reads stored values without writing the map back.
 * @topic Containers
 */
bool IndexAccessIn(const TMap<int, int>&in Values)
{
	return Values.Num() == 3
		&& Values[10] == 100
		&& Values[20] == 200
		&& Values[30] == 300;
}
/** @end */
