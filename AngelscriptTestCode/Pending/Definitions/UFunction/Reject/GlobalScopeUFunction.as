/**
 * @version v1
 * @summary A UFUNCTION at global scope is rejected. UFUNCTION methods belong on a UCLASS or the generated statics class, not as a bare global. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION at global scope is rejected. UFUNCTION methods belong on a UCLASS or the generated statics class, not as a bare global. This file is the illegal program itself.
 * @topic Negative
 */
/**
 * Illegal global UFUNCTION with no owning class.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION() void GlobalFunc()
 * @Return does not compile
 */
UFUNCTION()
void GlobalFunc()
{
}
/** @end */
