/**
 * @version v1
 * @summary Three-level nested TArray as a UPROPERTY is rejected.
 * @topic Containers
 *
 * NestedPropertyDeep
 */
/**
 * @begin NestedPropertyDeep
 * @summary Three-level nested TArray as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTArrayNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TArray<TArray<TArray<int>>> Matrix;
}
/** @end */
