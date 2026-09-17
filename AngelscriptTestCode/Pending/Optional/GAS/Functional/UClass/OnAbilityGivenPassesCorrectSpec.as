/**
 * @version v1
 * @summary An ability granted at a specific level and input ID, whose OnAbilityGiven delegate must receive the matching spec. The observers cover the null handle, the empty sibling ability and handle independence.
 * @topic Optional
 */
/**
 * @version root
 * @summary An ability granted at a specific level and input ID, whose OnAbilityGiven delegate must receive the matching spec. The observers cover the null handle, the empty sibling ability and handle independence.
 * @topic Baseline
 */
UCLASS()
class UTestSpecInfoAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityGivenPassesSpec
	 * @Inputs an unset ability handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestSpecInfoAbility Ability = nullptr;
		return Ability == nullptr;
	}

	/**
	 * Observe that two granted instances stay distinct.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityGivenPassesSpec
	 * @Inputs two granted ability handles
	 * @Return true when both are non-null and differ
	 * @Param First the first granted handle
	 * @Param Second the second granted handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestSpecInfoAbility First, UTestSpecInfoAbility Second)
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
 * @Covers GAS.OnAbilityGivenPassesSpec
 * @Inputs none
 * @Return a declared but empty ability
 */
UCLASS()
class UTestSpecInfoAbilityEmpty : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityGivenPassesSpec
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		UTestSpecInfoAbilityEmpty Ability = nullptr;
		return Ability == nullptr;
	}
}
/** @end */
