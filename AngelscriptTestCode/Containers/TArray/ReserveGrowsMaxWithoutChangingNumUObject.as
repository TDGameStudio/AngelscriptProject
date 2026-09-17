/**
 * @version v1
 * @summary Reserve(100) grows Max on TArray<UObject> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 *
 * ReserveGrowsMaxWithoutChangingNumUObject
 */
/**
 * @begin ReserveGrowsMaxWithoutChangingNumUObject
 * @summary Reserve(100) grows Max on TArray<UObject> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 */
UCLASS()
class UTArrayReserveGrowsMaxWithoutChangingNumUObjectHost : UObject
{
}

bool ReserveGrowsMaxWithoutChangingNumUObject()
{
	TArray<UObject> Values;
	Values.Reserve(100);
	if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
	{
		return false;
	}

	for (int Index = 0; Index < 10; ++Index)
	{
		Values.Add(NewObject(GetTransientPackage(), UTArrayReserveGrowsMaxWithoutChangingNumUObjectHost::StaticClass(), n"ReserveGrowsMax_Item", true));
	}
	return Values.Num() == 10 && Values[0] != nullptr && Values[9] != nullptr && Values.Max() >= 100;
}
/** @end */
