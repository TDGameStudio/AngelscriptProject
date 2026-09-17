/**
 * @version v1
 * @summary Nested TArray<TArray<int>> as a UFUNCTION return type is rejected.
 * @topic Containers
 *
 * NestedReturn
 */
/**
 * @begin NestedReturn
 * @summary Nested TArray<TArray<int>> as a UFUNCTION return type is rejected.
 * @topic Containers
 */
UFUNCTION()
TArray<TArray<int>> NestedReturn()
{
	TArray<TArray<int>> Result;
	return Result;
}
/** @end */
