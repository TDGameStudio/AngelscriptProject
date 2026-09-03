/**
 * Nested TSet<TSet<int>> as a UPROPERTY is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.NestedProperty
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetNestedProperty
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs UPROPERTY TSet<TSet<int>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTSetNestedPropertyReject : UObject
{
	UPROPERTY()
	TSet<TSet<int>> Nested;
}
