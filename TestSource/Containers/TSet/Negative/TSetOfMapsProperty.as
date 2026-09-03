/**
 * Nested TSet<TMap<int, int>> as a UPROPERTY is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.OfMapsProperty
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetOfMapsProperty
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs UPROPERTY TSet<TMap<int, int>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTSetOfMapsPropertyReject : UObject
{
	UPROPERTY()
	TSet<TMap<int, int>> Nested;
}
