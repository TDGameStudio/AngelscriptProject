/**
 * Three-level nested TArray as a UPROPERTY is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.NestedPropertyDeep
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayNestedPropertyDeep
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs UPROPERTY TArray<TArray<TArray<int>>> Matrix
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTArrayNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TArray<TArray<TArray<int>>> Matrix;
}
