/**
 * @version v1
 * @summary Nested TArray of TSet as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray of TSet as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTArrayOfSetsPropertyReject : UObject
{
	UPROPERTY()
	TArray<TSet<int>> Groups;
}
/** @end */
