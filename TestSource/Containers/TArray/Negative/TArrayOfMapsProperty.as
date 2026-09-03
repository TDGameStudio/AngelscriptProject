/**
 * Nested TArray of TMap as a UPROPERTY is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.OfMapsProperty
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayOfMapsProperty
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs UPROPERTY TArray<TMap<int, FString>> Rows
 * @Return does not compile; "Containers cannot be nested in other containers"
 */

UCLASS()
class UTArrayOfMapsPropertyReject : UObject
{
	UPROPERTY()
	TArray<TMap<int, FString>> Rows;
}
