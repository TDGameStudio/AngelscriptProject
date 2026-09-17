/**
 * @version v1
 * @summary Nested TMap<int, TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap<int, TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTMapNestedPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TMap<int, int>> Nested;
}
/** @end */
