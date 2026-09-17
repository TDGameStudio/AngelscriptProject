/**
 * @version v1
 * @summary Add grows Num for new UObject members only.
 * @topic Containers
 *
 * AddElementIsContainedUObject
 */
/**
 * @begin AddElementIsContainedUObject
 * @summary Add grows Num for new UObject members only.
 * @topic Containers
 */
UCLASS()
class UTSetAddElementIsContainedUObjectHost : UObject
{
}

bool AddElementIsContainedUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetAddElementIsContainedUObjectHost::StaticClass(), n"AddElementIsContained_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetAddElementIsContainedUObjectHost::StaticClass(), n"AddElementIsContained_Second", true);
	Values.Add(First);
	Values.Add(Second);
	return Values.Num() == 2 && Values.Contains(First) && Values.Contains(Second);
}
/** @end */
