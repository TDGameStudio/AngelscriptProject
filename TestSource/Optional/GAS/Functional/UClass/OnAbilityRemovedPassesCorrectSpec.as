/**
 * An ability granted at a specific level and input ID then cleared, whose
 * OnAbilityRemoved delegate must receive the matching spec. The observers cover
 * the null handle, the empty sibling ability and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.OnAbilityRemovedPassesSpec
 * @Harness UClass
 * @Tag Optional.GAS.OnAbilityRemovedPassesCorrectSpec
 * @Provenance Theme: Optional.GAS. WorldStory: UTestRemoveSpecAbility is given at Level 3 InputID 4 then cleared.
 * @Provenance C++: AngelscriptGASASCDelegateTests.cpp::OnAbilityRemovedPassesCorrectSpec
 * @Provenance Oracle: OnAbilityRemoved CapturedAbilityLevel == 3.
 * @Provenance Extra: nullptr handle; empty sibling ability; two instances stay distinct.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns GiveAbility then ClearAbility.
 */

UCLASS()
class UTestRemoveSpecAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityRemovedPassesSpec
	 * @Inputs an unset ability handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestRemoveSpecAbility Ability = nullptr;
		return Ability == nullptr;
	}

	/**
	 * Observe that two granted instances stay distinct.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityRemovedPassesSpec
	 * @Inputs two granted ability handles
	 * @Return true when both are non-null and differ
	 * @Param First the first granted handle
	 * @Param Second the second granted handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestRemoveSpecAbility First, UTestRemoveSpecAbility Second)
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
 * @Covers GAS.OnAbilityRemovedPassesSpec
 * @Inputs none
 * @Return a declared but empty ability
 */
UCLASS()
class UTestRemoveSpecAbilityEmpty : UAngelscriptGASAbility
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAbilityRemovedPassesSpec
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		UTestRemoveSpecAbilityEmpty Ability = nullptr;
		return Ability == nullptr;
	}
}
