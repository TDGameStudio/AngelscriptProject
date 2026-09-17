/**
 * @version v1
 * @summary A global UFUNCTION may not be BlueprintOverride. Overrides belong on a UCLASS that has a parent event. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A global UFUNCTION may not be BlueprintOverride. Overrides belong on a UCLASS that has a parent event. This file is the illegal program itself.
 * @topic Negative
 */
/**
 * Illegal global BlueprintOverride UFUNCTION.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintOverride) void BadGlobalOverride()
 * @Return does not compile
 */
UFUNCTION(BlueprintOverride)
void BadGlobalOverride()
{
}
/** @end */
