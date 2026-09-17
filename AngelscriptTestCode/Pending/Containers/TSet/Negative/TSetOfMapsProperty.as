/**
 * @version v1
 * @summary Nested TSet<TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTSetOfMapsPropertyReject : UObject
{
	UPROPERTY()
	TSet<TMap<int, int>> Nested;
}
/** @end */
