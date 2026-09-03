/**
 * Null guards on the gameplay tag blueprint property map: C++ compiles this file
 * and then expects runtime script exceptions from the two triggers, while the
 * observer only reads the empty vectors and never enters the throwing path.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TagPropertyMapNullGuards
 * @Harness Function
 * @Tag Optional.GAS.GameplayTagPropertyMapNullGuards
 * @Namespace GASTest
 * @Provenance Theme: Optional.GAS. C++ compiles then expects runtime script exceptions.
 * @Provenance CSV NegativeDiagnostic is a heuristic; null Owner / null ASC are the null vectors.
 * @Provenance Diagnostic: "GameplayTagBlueprintPropertyMap.Initialize received a null Owner."
 * @Provenance Diagnostic: "GameplayTagBlueprintPropertyMap.Initialize received a null AbilitySystemComponent."
 * @Provenance C++: AngelscriptGASValueBindingsTests.cpp::GameplayTagPropertyMapNullGuards
 * @Provenance OutStep stays 1 when Initialize throws. Extra: empty tag/container.
 * @Provenance FixtureIsolated.
 * @Provenance Both triggers throw at runtime; the observer never calls them.
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
