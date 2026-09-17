/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Adds one handle after visiting existing pairs.
 * @topic Containers
 *
 * MutateForEachPairUObject
 */
/**
 * @begin MutateForEachPairUObject
 * @summary An &inout TMap<int, UObject> Adds one handle after visiting existing pairs.
 * @topic Containers
 */
UCLASS()
class UTMapMutateForEachPairUObjectHost : UObject
{
}

void MutateForEachPairUObject(TMap<int, UObject>&inout Values)
{
	int Count = 0;
	for (int Key, UObject Value : Values)
	{
		if (Value != nullptr)
		{
			Count += 1;
		}
	}
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateForEachPairUObjectHost::StaticClass(), n"ForEach_Mutate", true));
}
/** @end */
