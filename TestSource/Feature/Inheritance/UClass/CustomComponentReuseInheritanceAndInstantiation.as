/**
 * Reusable default versus runtime component. C++ verifies after BeginPlay both
 * flags true and CombinedValue==30 (ComputeDerivedValue 10+5 twice). CombinedValue
 * is 0 and both flags false before BeginPlay.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.CustomComponentReuseInheritanceAndInstantiation
 * @Harness UClass
 * @Tag Feature.Inheritance.CustomComponentReuseInheritanceAndInstantiation
 * @Provenance Theme: Feature.Inheritance. WorldStory reusable default vs runtime component.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::CustomComponentReuseInheritanceAndInstantiation
 * @Provenance sha256 from theme-refs TS-FEAT-0014; lines 2292-2353.
 * @Provenance Oracle after BeginPlay: DefaultComponentValid && DynamicComponentValid; CombinedValue==30
 * @Provenance (ComputeDerivedValue 10+5 twice). Extra: CombinedValue 0 and both flags false before BeginPlay;
 * @Provenance ComputeDerivedValue on a default-value component is 15. FixtureIsolated.
 */

UCLASS()
class UCoverageReusableBaseComponent : UActorComponent
{
	UPROPERTY()
	int BaseValue = 10;

	/**
	 * Return BaseValue from the reusable base component.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs none
	 * @Return BaseValue, expected to be 10
	 */
	UFUNCTION()
	int ComputeValue()
	{
		return BaseValue;
	}
}

UCLASS()
class UCoverageReusableDerivedComponent : UCoverageReusableBaseComponent
{
	UPROPERTY()
	int DerivedValue = 5;

	/**
	 * Return ComputeValue() + DerivedValue from the reusable derived component.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs none
	 * @Return BaseValue + DerivedValue, expected to be 15
	 */
	UFUNCTION()
	int ComputeDerivedValue()
	{
		return ComputeValue() + DerivedValue;
	}

	/**
	 * Observe ComputeDerivedValue at the default DerivedValue.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs a component whose DerivedValue is 5
	 * @Return ComputeDerivedValue(), expected to be 15
	 */
	UFUNCTION()
	int DefaultComputeDerived()
	{
		return ComputeDerivedValue();
	}

	/**
	 * Observe ComputeDerivedValue after DerivedValue is zeroed.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs DerivedValue = 0
	 * @Return ComputeDerivedValue(), expected to be 10
	 * @Boundary zero derived
	 */
	UFUNCTION()
	int ZeroDerivedBoundary()
	{
		DerivedValue = 0;
		return ComputeDerivedValue();
	}
}

UCLASS()
class ACoverageComponentReusableActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageReusableDerivedComponent DefaultReusable;

	UPROPERTY()
	UCoverageReusableDerivedComponent DynamicReusable;

	UPROPERTY()
	bool DefaultComponentValid = false;

	UPROPERTY()
	bool DynamicComponentValid = false;

	UPROPERTY()
	int CombinedValue = 0;

	/**
	 * WorldStory: BeginPlay creates a dynamic component and sums both ComputeDerivedValue results.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs DefaultReusable plus a runtime Create of DynamicReusable
	 * @Return CombinedValue 30 when both components are valid and distinct
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DynamicReusable = UCoverageReusableDerivedComponent::Create(this, n"DynamicReusable");

		DefaultComponentValid = DefaultReusable != nullptr;
		DynamicComponentValid = DynamicReusable != nullptr && DynamicReusable != DefaultReusable;

		if (DefaultReusable != nullptr && DynamicReusable != nullptr)
		{
			DefaultReusable.DerivedValue = 5;
			DynamicReusable.DerivedValue = 5;
			CombinedValue = DefaultReusable.ComputeDerivedValue() + DynamicReusable.ComputeDerivedValue();
		}
	}

	/**
	 * Observe that a locally constructed actor has not created the dynamic component.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs an actor that has not begun play
	 * @Return true when both flags are false, CombinedValue is 0 and DynamicReusable is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (DefaultComponentValid)
		{
			return false;
		}
		if (DynamicComponentValid)
		{
			return false;
		}
		if (CombinedValue != 0)
		{
			return false;
		}
		return DynamicReusable == nullptr;
	}

	/**
	 * Observe CombinedValue after BeginPlay creates the dynamic component.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentReuseInheritanceAndInstantiation
	 * @Inputs BeginPlay()
	 * @Return CombinedValue, expected to be 30
	 */
	UFUNCTION()
	int BeginPlayCombined()
	{
		BeginPlay();
		return CombinedValue;
	}
}
