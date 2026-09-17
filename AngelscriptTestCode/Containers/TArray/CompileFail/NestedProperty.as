/**
 * @version v1
 * @summary Nested TArray<TArray<int>> as a UPROPERTY is rejected.
 * @topic Containers
 *
 * NestedProperty
 */
/**
 * @begin NestedProperty
 * @summary Nested TArray<TArray<int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTArrayNestedPropertyReject : UObject
{
	UPROPERTY()
	TArray<TArray<int>> Matrix;
}
/** @end */
