/**
 * Nested TMap<int, TMap<int, int>> as a UPROPERTY is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.NestedProperty
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapNestedProperty
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs UPROPERTY TMap<int, TMap<int, int>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTMapNestedPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TMap<int, int>> Nested;
}
