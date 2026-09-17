/**
 * @version v1
 * @summary A TOptional of TArray UPROPERTY is rejected: containers cannot be nested in other containers.
 * @topic Containers
 *
 * OfArrayProperty
 */
/**
 * @begin OfArrayProperty
 * @summary A TOptional of TArray UPROPERTY is rejected: containers cannot be nested in other containers.
 * @topic Containers
 */
UCLASS()
class UTOptionalOfArrayPropertyHost : UObject
{
	UPROPERTY()
	TOptional<TArray<int32>> Optional;
}
/** @end */
