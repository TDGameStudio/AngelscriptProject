/**
 * @version v1
 * @summary FindIndex returns the first matching UObject handle index or -1 when absent.
 * @topic Containers
 *
 * FindIndexReturnsFirstOrMinusOneUObject
 */
/**
 * @begin FindIndexReturnsFirstOrMinusOneUObject
 * @summary FindIndex returns the first matching UObject handle index or -1 when absent.
 * @topic Containers
 */
UCLASS()
class UTArrayFindIndexReturnsFirstOrMinusOneUObjectHost : UObject
{
}

bool FindIndexReturnsFirstOrMinusOneUObject()
{
	TArray<UObject> Empty;
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayFindIndexReturnsFirstOrMinusOneUObjectHost::StaticClass(), n"FindIndex_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayFindIndexReturnsFirstOrMinusOneUObjectHost::StaticClass(), n"FindIndex_Second", true);
	UObject Miss = NewObject(GetTransientPackage(), UTArrayFindIndexReturnsFirstOrMinusOneUObjectHost::StaticClass(), n"FindIndex_Miss", true);
	Values.Add(First);
	Values.Add(Second);
	Values.Add(First);
	return Empty.FindIndex(First) == -1
		&& Values.FindIndex(First) == 0
		&& Values.FindIndex(Second) == 1
		&& Values.FindIndex(Miss) == -1;
}
/** @end */
