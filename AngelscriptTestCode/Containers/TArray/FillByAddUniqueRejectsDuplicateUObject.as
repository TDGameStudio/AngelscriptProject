/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by AddUnique including a skipped identity.
 * @topic Containers
 *
 * FillByAddUniqueRejectsDuplicateUObject
 */
/**
 * @begin FillByAddUniqueRejectsDuplicateUObject
 * @summary An &out TArray<UObject> is filled by AddUnique including a skipped identity.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByAddUniqueRejectsDuplicateUObjectHost : UObject
{
}

void FillByAddUniqueRejectsDuplicateUObject(TArray<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTArrayFillByAddUniqueRejectsDuplicateUObjectHost::StaticClass(), n"FillByAddUnique_0", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayFillByAddUniqueRejectsDuplicateUObjectHost::StaticClass(), n"FillByAddUnique_1", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayFillByAddUniqueRejectsDuplicateUObjectHost::StaticClass(), n"FillByAddUnique_2", true);
	Result.AddUnique(First);
	Result.AddUnique(Second);
	Result.AddUnique(First);
	Result.AddUnique(Third);
}
/** @end */
