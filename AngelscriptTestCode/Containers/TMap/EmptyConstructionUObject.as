/**
 * @version v1
 * @summary Default TMap<int, UObject> is empty.
 * @topic Containers
 *
 * EmptyConstructionUObject
 */
/**
 * @begin EmptyConstructionUObject
 * @summary Default TMap<int, UObject> is empty.
 * @topic Containers
 */
UCLASS()
class UTMapEmptyConstructionUObjectHost : UObject
{
}

bool EmptyConstructionUObject()
{
	TMap<int, UObject> Map;
	UObject Probe = NewObject(GetTransientPackage(), UTMapEmptyConstructionUObjectHost::StaticClass(), n"EmptyConstruction_Probe", true);
	return Map.IsEmpty() && Map.Num() == 0 && !Map.Contains(42) && Probe != nullptr;
}
/** @end */
