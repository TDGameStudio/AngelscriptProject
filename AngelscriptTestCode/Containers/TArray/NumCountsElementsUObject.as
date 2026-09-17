/**
 * @version v1
 * @summary Num counts UObject handles: empty is 0 and two Adds yield 2.
 * @topic Containers
 *
 * NumCountsElementsUObject
 */
/**
 * @begin NumCountsElementsUObject
 * @summary Num counts UObject handles: empty is 0 and two Adds yield 2.
 * @topic Containers
 */
UCLASS()
class UTArrayNumCountsElementsUObjectHost : UObject
{
}

bool NumCountsElementsUObject()
{
	TArray<UObject> Empty;
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayNumCountsElementsUObjectHost::StaticClass(), n"Num_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayNumCountsElementsUObjectHost::StaticClass(), n"Num_Second", true);
	Values.Add(First);
	Values.Add(Second);
	return Empty.Num() == 0 && Values.Num() == 2 && Values[0] == First && Values[1] == Second;
}
/** @end */
