/**
 * Nested TMap whose value is TArray as a UPROPERTY is rejected.
 * Moved from Containers/TArray/Negative/TMapWithArrayValues.as.
 *
 * @Theme Containers.TMap
 * @Subject TMap.OfArraysProperty
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapOfArraysProperty
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs UPROPERTY TMap<int, TArray<int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTMapOfArraysPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TArray<int>> Groups;
}
