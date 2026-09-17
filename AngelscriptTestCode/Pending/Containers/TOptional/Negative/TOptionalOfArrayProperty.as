/**
 * @version v1
 * @summary TOptional<TArray<int>> as a UPROPERTY is rejected: containers cannot be nested in other containers. Rejected at the property declaration site.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional<TArray<int>> as a UPROPERTY is rejected: containers cannot be nested in other containers. Rejected at the property declaration site.
 * @topic Baseline
 */
UCLASS()
class UTOptionalOfArrayPropertyHost : UObject
{
	UPROPERTY()
	TOptional<TArray<int>> Opt;
}
/** @end */
