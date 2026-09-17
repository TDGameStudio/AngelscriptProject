/**
 * @version v1
 * @summary Native-only APawn BlueprintOverride methods are rejected. SetupPlayerInputComponent and PossessedBy do not exist in the script-visible Pawn superclass, and UnPossessed does not match the supported signature.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Native-only APawn BlueprintOverride methods are rejected. SetupPlayerInputComponent and PossessedBy do not exist in the script-visible Pawn superclass, and UnPossessed does not match the supported signature.
 * @topic Negative
 */
UCLASS()
class ALifecyclePawnUnsupportedOverrides : APawn
{
	/**
	 * Illegal BlueprintOverride of SetupPlayerInputComponent.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param PlayerInputComponent Input component
	 * @Inputs SetupPlayerInputComponent override on APawn
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
	}

	/**
	 * Illegal BlueprintOverride of PossessedBy.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param NewController Possessing controller
	 * @Inputs PossessedBy override on APawn
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void PossessedBy(AController NewController)
	{
	}

	/**
	 * Illegal BlueprintOverride of UnPossessed.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs UnPossessed override on APawn
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void UnPossessed()
	{
	}
}
/** @end */
