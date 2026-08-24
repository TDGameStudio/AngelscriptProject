// Theme: Feature.Inheritance. WorldStory Super:: chain on RunChain.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::InheritanceChain
// sha256 from theme-refs TS-FEAT-0011; lines 1132-1198.
// Oracle after ExecuteDeepChain: CallChain==1234; BaseValue==1;
// MidValue/DerivedValue/DeepValue==0 (documented deep-inheritance initializer boundary).
// Extra: CallChain 0 before execute; ExecuteChain on derived is 123. FixtureIsolated.

UCLASS()
class ACoverageClassFeaturesInheritanceBase : AActor
{
	UPROPERTY()
	int BaseValue = 1;

	UPROPERTY()
	int CallChain = 0;

	void RunChain()
	{
		CallChain = CallChain * 10 + 1;
	}
}

UCLASS()
class ACoverageClassFeaturesInheritanceMid : ACoverageClassFeaturesInheritanceBase
{
	UPROPERTY()
	int MidValue = 2;

	void RunChain()
	{
		Super::RunChain();
		CallChain = CallChain * 10 + 2;
	}
}

UCLASS()
class ACoverageClassFeaturesInheritanceDerived : ACoverageClassFeaturesInheritanceMid
{
	UPROPERTY()
	int DerivedValue = 3;

	void RunChain()
	{
		Super::RunChain();
		CallChain = CallChain * 10 + 3;
	}

	UFUNCTION()
	void ExecuteChain()
	{
		RunChain();
	}
}

UCLASS()
class ACoverageClassFeaturesInheritanceDeep : ACoverageClassFeaturesInheritanceDerived
{
	UPROPERTY()
	int DeepValue = 4;

	void RunChain()
	{
		Super::RunChain();
		CallChain = CallChain * 10 + 4;
	}

	UFUNCTION()
	void ExecuteDeepChain()
	{
		RunChain();
	}
}

int Observe_InheritanceChain_DefaultEmpty(ACoverageClassFeaturesInheritanceDeep Actor)
{
	if (Actor is null)
	{
		throw("Test_InheritanceChain setup: required Actor is null");
	}
	return Actor.CallChain;
}

int Observe_InheritanceChain_DeepExecute(ACoverageClassFeaturesInheritanceDeep Actor)
{
	if (Actor is null)
	{
		throw("Test_InheritanceChain setup: required Actor is null");
	}
	Actor.ExecuteDeepChain();
	return Actor.CallChain;
}

int Observe_InheritanceChain_DerivedExecute(ACoverageClassFeaturesInheritanceDerived Actor)
{
	if (Actor is null)
	{
		throw("Test_InheritanceChain setup: required Actor is null");
	}
	Actor.ExecuteChain();
	return Actor.CallChain;
}

int Observe_InheritanceChain_BaseValue(ACoverageClassFeaturesInheritanceDeep Actor)
{
	if (Actor is null)
	{
		throw("Test_InheritanceChain setup: required Actor is null");
	}
	return Actor.BaseValue;
}

bool Observe_InheritanceChain_TwoLocalsIndependent(ACoverageClassFeaturesInheritanceDeep First, ACoverageClassFeaturesInheritanceDeep Second)
{
	if (First is null)
	{
		throw("Test_InheritanceChain setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_InheritanceChain setup: required Second is null");
	}
	First.ExecuteDeepChain();
	return First.CallChain == 1234 && Second.CallChain == 0;
}
