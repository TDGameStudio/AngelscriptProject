/**
 * @version v1
 * @summary Nested TArray of TMap as a UPROPERTY is rejected.
 * @topic Containers
 *
 * OfMapsProperty
 */
/**
 * @begin OfMapsProperty
 * @summary Nested TArray of TMap as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTArrayOfMapsPropertyReject : UObject
{
	UPROPERTY()
	TArray<TMap<int, FString>> Rows;
}
/** @end */
