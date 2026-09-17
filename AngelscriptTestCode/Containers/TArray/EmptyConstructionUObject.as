/**
 * @version v1
 * @summary Default TArray<UObject> is empty.
 * @topic Containers
 *
 * EmptyConstructionUObject
 */
/**
 * @begin EmptyConstructionUObject
 * @summary Default TArray<UObject> is empty.
 * @topic Containers
 */
UCLASS()
class UTArrayEmptyConstructionUObjectHost : UObject
{
}

bool EmptyConstructionUObject()
{
	TArray<UObject> Values;
	UObject Probe = NewObject(GetTransientPackage(), UTArrayEmptyConstructionUObjectHost::StaticClass(), n"EmptyConstruction_Probe", true);
	return Values.IsEmpty() && Values.Num() == 0 && !Values.Contains(Probe);
}
/** @end */
