/**
 * @version v1
 * @summary An &inout TArray<UObject> appends Values[0] so FindIndex still hits the first identity.
 * @topic Containers
 *
 * MutateFindIndexReturnsFirstOrMinusOneUObject
 */
/**
 * @begin MutateFindIndexReturnsFirstOrMinusOneUObject
 * @summary An &inout TArray<UObject> appends Values[0] so FindIndex still hits the first identity.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateFindIndexReturnsFirstOrMinusOneUObjectHost : UObject
{
}

void MutateFindIndexReturnsFirstOrMinusOneUObject(TArray<UObject>&inout Values)
{
	UObject Duplicate = Values[0];
	Values.Add(Duplicate);
}
/** @end */
