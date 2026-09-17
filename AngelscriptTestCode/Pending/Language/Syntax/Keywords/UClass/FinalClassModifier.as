/**
 * @version v1
 * @summary The final class modifier applied to an actor subclass. The modifier must produce a valid type without preventing the class from being used as an actor.
 * @topic Language
 */
/**
 * @version root
 * @summary The final class modifier applied to an actor subclass. The modifier must produce a valid type without preventing the class from being used as an actor.
 * @topic Baseline
 */
class AFinalActorMisc : AActor final
{
	/**
	 * Observe that the final class is still usable as an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a default-constructed AFinalActorMisc handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int FinalClassHandleIsAnActor()
	{
		AFinalActorMisc Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs an unset AFinalActorMisc handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalClassHandleDefaultsToNull()
	{
		AFinalActorMisc Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool FinalClassHandleAssignAliases()
	{
		AFinalActorMisc First;
		AFinalActorMisc Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
