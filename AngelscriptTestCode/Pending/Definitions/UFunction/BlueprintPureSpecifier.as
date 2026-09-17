/**
 * @version v1
 * @summary BlueprintPure on a const getter. GetHealth returns 100, a second instance also returns 100, and a default handle is null.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintPure on a const getter. GetHealth returns 100, a second instance also returns 100, and a default handle is null.
 * @topic Baseline
 */
class AUFuncBPPureActor : AActor
{
	/**
	 * BlueprintPure const getter that always returns 100.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION(BlueprintPure)
	int GetHealth() const
	{
		return 100;
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that GetHealth returns 100 on a live actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose GetHealth is invoked, runner-owned when non-null
	 * @Inputs Actor.GetHealth()
	 * @Return 100 when Actor is live; -1 when Actor is null
	 */
	UFUNCTION()
	int GetHealthReturnsHundred(AUFuncBPPureActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		return Actor.GetHealth();
	}

	/**
	 * Observe that a second instance also returns 100.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Second Second actor whose GetHealth is invoked, runner-owned when non-null
	 * @Inputs Second.GetHealth() after constructing a first unused handle
	 * @Return 100 when Second is live; -1 when Second is null
	 */
	UFUNCTION()
	int SecondInstanceReturnsHundred(AUFuncBPPureActor Second)
	{
		if (Second == nullptr)
		{
			return -1;
		}
		AUFuncBPPureActor First;
		return Second.GetHealth();
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPPureActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBPPureActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
