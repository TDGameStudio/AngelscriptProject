/**
 * @version v1
 * @summary Bracket access on a const TMap<FName,int>&in reads stored values without writing the map back.
 * @topic Containers
 *
 * IndexAccessFNameIn
 */
/**
 * @begin IndexAccessFNameIn
 * @summary Bracket access on a const TMap<FName,int>&in reads stored values without writing the map back.
 * @topic Containers
 */
bool IndexAccessFNameIn(const TMap<FName, int>&in Values)
{
	return Values.Num() == 3
		&& Values[n"Red"] == 1
		&& Values[n"Green"] == 2
		&& Values[n"Blue"] == 3;
}
/** @end */
