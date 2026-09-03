/**
 * Nested TSet of TSet of TSet as a UPROPERTY is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.NestedPropertyDeep
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetNestedPropertyDeep
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs UPROPERTY TSet<TSet<TSet<int>>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTSetNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TSet<TSet<TSet<int>>> Nested;
}
