// Theme: Feature.Inheritance. WorldStory reusable default vs runtime component.
// C++: AngelscriptCoverageComponentTests.cpp::CustomComponentReuseInheritanceAndInstantiation
// sha256 from theme-refs TS-FEAT-0014; lines 2292-2353.
// Oracle after BeginPlay: DefaultComponentValid && DynamicComponentValid; CombinedValue==30
// (ComputeDerivedValue 10+5 twice). Extra: CombinedValue 0 and both flags false before BeginPlay;
// ComputeDerivedValue on a default-value component is 15. FixtureIsolated.

UCLASS()
class UCoverageReusableBaseComponent : UActorComponent
{
	UPROPERTY()
	int BaseValue = 10;

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

	UFUNCTION()
	int ComputeDerivedValue()
	{
		return ComputeValue() + DerivedValue;
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
}

bool Observe_Reusable_DefaultEmpty(ACoverageComponentReusableActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CustomComponentReuseInheritanceAndInstantiation setup: required Actor is null");
	}
	return !Actor.DefaultComponentValid && !Actor.DynamicComponentValid && Actor.CombinedValue == 0 && Actor.DynamicReusable == nullptr;
}

int Observe_Reusable_DefaultComputeDerived(UCoverageReusableDerivedComponent Probe)
{
	if (Probe is null)
	{
		throw("Test_CustomComponentReuseInheritanceAndInstantiation setup: required Probe is null");
	}
	return Probe.ComputeDerivedValue();
}

int Observe_Reusable_ZeroDerivedBoundary(UCoverageReusableDerivedComponent Probe)
{
	if (Probe is null)
	{
		throw("Test_CustomComponentReuseInheritanceAndInstantiation setup: required Probe is null");
	}
	Probe.DerivedValue = 0;
	return Probe.ComputeDerivedValue();
}

int Observe_Reusable_BeginPlayCombined(ACoverageComponentReusableActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CustomComponentReuseInheritanceAndInstantiation setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.CombinedValue;
}
