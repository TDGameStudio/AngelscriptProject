/**
 * @version v1
 * @summary An ability whose grant broadcasts OnAbilityGiven. The observers cover the null handle, the empty sibling ability and handle independence between two granted instances.
 * @topic Optional
 */
/**
 * @version root
 * @summary An ability whose grant broadcasts OnAbilityGiven. The observers cover the null handle, the empty sibling ability and handle independence between two granted instances.
 * @topic Baseline
 */
UCLASS()
class UTestDelegateGiveAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityGivenBroadcasts
	 * @Inputs an unset ability handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestDelegateGiveAbility Ability = nullptr;
		return Ability == nullptr;
	}

	/**
	 * Observe that two granted instances stay distinct.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityGivenBroadcasts
	 * @Inputs two granted ability handles
	 * @Return true when both are non-null and differ
	 * @Param First the first granted handle
	 * @Param Second the second granted handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestDelegateGiveAbility First, UTestDelegateGiveAbility Second)
	{
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}

/**
 * The empty sibling ability that C++ also compiles alongside the granted one.
 *
 * @Covers GAS.OnAbilityGivenBroadcasts
 * @Inputs none
 * @Return a declared but empty ability
 */
UCLASS()
class UTestDelegateGiveAbilityEmpty : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityGivenBroadcasts
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		UTestDelegateGiveAbilityEmpty Ability = nullptr;
		return Ability == nullptr;
	}
}
/** @end */
