/**
 * Nested TSet<TArray<int>> as a UPROPERTY is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.OfArraysProperty
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetOfArraysProperty
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs UPROPERTY TSet<TArray<int>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTSetOfArraysPropertyReject : UObject
{
	UPROPERTY()
	TSet<TArray<int>> Nested;
}
