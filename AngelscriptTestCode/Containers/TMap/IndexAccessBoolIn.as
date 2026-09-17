/**
 * @version v1
 * @summary Bracket access on a const TMap<int,bool>&in reads stored values without writing the map back.
 * @topic Containers
 *
 * IndexAccessBoolIn
 */
/**
 * @begin IndexAccessBoolIn
 * @summary Bracket access on a const TMap<int,bool>&in reads stored values without writing the map back.
 * @topic Containers
 */
bool IndexAccessBoolIn(const TMap<int, bool>&in Values)
{
	return Values.Num() == 3
		&& Values[1] == true
		&& Values[2] == false
		&& Values[3] == true;
}
/** @end */
