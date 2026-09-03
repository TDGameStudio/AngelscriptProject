/**
 * Nested TArray<TArray<int>> as a UPROPERTY is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.NestedProperty
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayNestedProperty
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs UPROPERTY TArray<TArray<int>> Matrix
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTArrayNestedPropertyReject : UObject
{
	UPROPERTY()
	TArray<TArray<int>> Matrix;
}
