/**
 * @version v1
 * @summary Null guards on the gameplay tag blueprint property map: C++ compiles this file and then expects runtime script exceptions from the two triggers, while the observer only reads the empty vectors and never enters the.
 * @topic Optional
 */
/**
 * @version root
 * @summary Null guards on the gameplay tag blueprint property map: C++ compiles this file and then expects runtime script exceptions from the two triggers, while the observer only reads the empty vectors and never enters the.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Initializes the map with both a null owner and a null ASC, which throws.
	 *
	 * @Covers GAS.TagPropertyMapNullGuards
	 * @Inputs the out step recorder
	 * @Return nothing; throws when Initialize receives the null owner
	 * @Param OutStep the step recorder, left at 1 when Initialize throws
	 */
	void TriggerNullOwnerAndASC(int&out OutStep)
	{
		OutStep = 1;
		FGameplayTagBlueprintPropertyMap Map;
		UObject NullOwner;
		UAbilitySystemComponent NullASC;
		Map.Initialize(NullOwner, NullASC);
		OutStep = 2;
		Map.ApplyCurrentTags();
		OutStep = 3;
	}

	/**
	 * Initializes the map with a real owner but a null ASC, which throws.
	 *
	 * @Covers GAS.TagPropertyMapNullGuards
	 * @Inputs a valid owner and the out step recorder
	 * @Return nothing; throws when Initialize receives the null ASC
	 * @Param Owner the non-null owner
	 * @Param OutStep the step recorder, left at 1 when Initialize throws
	 */
	void TriggerNullASC(UObject Owner, int&out OutStep)
	{
		OutStep = 1;
		FGameplayTagBlueprintPropertyMap Map;
		UAbilitySystemComponent NullASC;
		Map.Initialize(Owner, NullASC);
		OutStep = 2;
		Map.ApplyCurrentTags();
		OutStep = 3;
	}

	/**
	 * Observe that a default tag is invalid and a default container empty.
	 *
	 * @Kind Observe
	 * @Covers GAS.TagPropertyMapNullGuards
	 * @Inputs a default tag and a default container
	 * @Return 1 when both are in their empty state
	 * @Boundary empty tag and container
	 */
	UFUNCTION()
	int EmptyTagAndContainer()
	{
		FGameplayTag EmptyTag;
		FGameplayTagContainer EmptyContainer;

		if (EmptyTag.IsValid())
		{
			return 0;
		}
		if (!EmptyContainer.IsEmpty())
		{
			return 0;
		}
		return 1;
	}
}
/** @end */
