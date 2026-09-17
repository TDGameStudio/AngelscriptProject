/**
 * @version v1
 * @summary Default TSet<UObject> is empty.
 * @topic Containers
 *
 * EmptyConstructionUObject
 */
/**
 * @begin EmptyConstructionUObject
 * @summary Default TSet<UObject> is empty.
 * @topic Containers
 */
UCLASS()
class UTSetEmptyConstructionUObjectHost : UObject
{
}

bool EmptyConstructionUObject()
{
	TSet<UObject> Values;
	UObject Probe = NewObject(GetTransientPackage(), UTSetEmptyConstructionUObjectHost::StaticClass(), n"EmptyConstruction_Probe", true);
	return Values.IsEmpty() && Values.Num() == 0 && !Values.Contains(Probe);
}
/** @end */
