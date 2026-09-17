/**
 * @version v1
 * @summary Nested TMap of TMap of TMap as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap of TMap of TMap as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTMapNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TMap<int, TMap<int, TMap<int, int>>> Nested;
}
/** @end */
