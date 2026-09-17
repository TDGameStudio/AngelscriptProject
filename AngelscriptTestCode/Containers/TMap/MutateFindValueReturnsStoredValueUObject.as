/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Adds one pair so Find can hit a new key.
 * @topic Containers
 *
 * MutateFindValueReturnsStoredValueUObject
 */
/**
 * @begin MutateFindValueReturnsStoredValueUObject
 * @summary An &inout TMap<int, UObject> Adds one pair so Find can hit a new key.
 * @topic Containers
 */
UCLASS()
class UTMapMutateFindValueReturnsStoredValueUObjectHost : UObject
{
}

void MutateFindValueReturnsStoredValueUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateFindValueReturnsStoredValueUObjectHost::StaticClass(), n"FindValue_Mutate", true));
}
/** @end */
