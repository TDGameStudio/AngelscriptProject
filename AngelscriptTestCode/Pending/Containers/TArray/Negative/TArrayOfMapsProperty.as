/**
 * @version v1
 * @summary Nested TArray of TMap as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray of TMap as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTArrayOfMapsPropertyReject : UObject
{
	UPROPERTY()
	TArray<TMap<int, FString>> Rows;
}
/** @end */
