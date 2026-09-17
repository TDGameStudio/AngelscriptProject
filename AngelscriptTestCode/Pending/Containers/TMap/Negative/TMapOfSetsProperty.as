/**
 * @version v1
 * @summary Nested TMap whose value is TSet as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap whose value is TSet as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTMapOfSetsPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TSet<int>> Groups;
}
/** @end */
