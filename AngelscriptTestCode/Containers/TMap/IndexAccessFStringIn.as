/**
 * @version v1
 * @summary Bracket access on a const TMap<FString,int>&in reads stored values without writing the map back.
 * @topic Containers
 *
 * IndexAccessFStringIn
 */
/**
 * @begin IndexAccessFStringIn
 * @summary Bracket access on a const TMap<FString,int>&in reads stored values without writing the map back.
 * @topic Containers
 */
bool IndexAccessFStringIn(const TMap<FString, int>&in Values)
{
	return Values.Num() == 3
		&& Values["alpha"] == 100
		&& Values["beta"] == 200
		&& Values["gamma"] == 300;
}
/** @end */
