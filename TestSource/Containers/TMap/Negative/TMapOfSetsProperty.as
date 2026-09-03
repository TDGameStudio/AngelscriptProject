/**
 * Nested TMap whose value is TSet as a UPROPERTY is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.OfSetsProperty
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapOfSetsProperty
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs UPROPERTY TMap<int, TSet<int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTMapOfSetsPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TSet<int>> Groups;
}
