/**
 * @version v1
 * @summary A network UFUNCTION cannot also be BlueprintOverride. Server plus BlueprintOverride is treated as an event/override conflict. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A network UFUNCTION cannot also be BlueprintOverride. Server plus BlueprintOverride is treated as an event/override conflict. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionNetOverrideConflictActor : AActor
{
	/**
	 * Illegal UFUNCTION mixing Server and BlueprintOverride.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, BlueprintOverride)
	 * @Return does not compile
	 */
	UFUNCTION(Server, BlueprintOverride)
	void Conflict()
	{
	}
}
/** @end */
