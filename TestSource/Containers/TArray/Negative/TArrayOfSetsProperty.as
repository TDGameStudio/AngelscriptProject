/**
 * Nested TArray of TSet as a UPROPERTY is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.OfSetsProperty
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayOfSetsProperty
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs UPROPERTY TArray<TSet<int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTArrayOfSetsPropertyReject : UObject
{
	UPROPERTY()
	TArray<TSet<int>> Groups;
}
