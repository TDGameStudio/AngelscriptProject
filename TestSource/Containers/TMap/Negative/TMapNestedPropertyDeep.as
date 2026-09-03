/**
 * Nested TMap of TMap of TMap as a UPROPERTY is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.NestedPropertyDeep
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapNestedPropertyDeep
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs UPROPERTY TMap<int, TMap<int, TMap<int, int>>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTMapNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TMap<int, TMap<int, TMap<int, int>>> Nested;
}
