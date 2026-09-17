/**
 * @version v1
 * @summary Three-level nested TArray as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Three-level nested TArray as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTArrayNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TArray<TArray<TArray<int>>> Matrix;
}
/** @end */
