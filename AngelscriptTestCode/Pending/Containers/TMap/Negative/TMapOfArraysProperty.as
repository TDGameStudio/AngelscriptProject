/**
 * @version v1
 * @summary Nested TMap whose value is TArray as a UPROPERTY is rejected. Moved from Containers/TArray/Negative/TMapWithArrayValues.as.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap whose value is TArray as a UPROPERTY is rejected. Moved from Containers/TArray/Negative/TMapWithArrayValues.as.
 * @topic Baseline
 */
UCLASS()
class UTMapOfArraysPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TArray<int>> Groups;
}
/** @end */
