/**
 * @version v1
 * @summary Two abilities given on one ASC, so OnAbilityGiven must fire once per grant. The observers cover both null handles, the empty sibling ability and type independence between the two granted abilities.
 * @topic Optional
 */
/**
 * @version root
 * @summary Two abilities given on one ASC, so OnAbilityGiven must fire once per grant. The observers cover both null handles, the empty sibling ability and type independence between the two granted abilities.
 * @topic Baseline
 */
UCLASS()
class UTestMultiGiveAbilityA : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle of this ability is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleGiveAbilityFiresEachTime
	 * @Inputs an unset ability handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestMultiGiveAbilityA Ability = nullptr;
		return Ability == nullptr;
	}

	/**
	 * Observe that a granted A and a granted B stay distinct.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleGiveAbilityFiresEachTime
	 * @Inputs a granted A and a granted B
	 * @Return true when both are non-null and differ
	 * @Param Second the granted B to compare against
	 * @Boundary type independence
	 */
	UFUNCTION()
	bool TwoClassesIndependent(UTestMultiGiveAbilityB Second)
	{
		if (this == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return true;
	}
}

UCLASS()
class UTestMultiGiveAbilityB : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle of this ability is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleGiveAbilityFiresEachTime
	 * @Inputs an unset ability handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestMultiGiveAbilityB Ability = nullptr;
		return Ability == nullptr;
	}
}

/**
 * The empty sibling ability that C++ also compiles alongside the granted ones.
 *
 * @Covers GAS.MultipleGiveAbilityFiresEachTime
 * @Inputs none
 * @Return a declared but empty ability
 */
UCLASS()
class UTestMultiGiveAbilityEmpty : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleGiveAbilityFiresEachTime
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		UTestMultiGiveAbilityEmpty Ability = nullptr;
		return Ability == nullptr;
	}
}
/** @end */
