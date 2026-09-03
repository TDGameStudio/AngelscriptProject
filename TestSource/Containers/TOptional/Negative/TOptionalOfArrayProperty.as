/**
 * TOptional<TArray<int>> as a UPROPERTY is rejected: containers cannot be
 * nested in other containers. Rejected at the property declaration site.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.NestedArray
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalOfArrayProperty
 * @Kind CompileReject
 * @Covers TOptional.Declaration
 * @Inputs UPROPERTY TOptional<TArray<int>> Opt
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalOfArrayPropertyHost : UObject
{
	UPROPERTY()
	TOptional<TArray<int>> Opt;
}
