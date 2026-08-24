// Theme: Feature.Inheritance. WorldStory default keyword on single class and leaf.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::DefaultKeywordOverride
// sha256 from theme-refs TS-FEAT-0010; lines 128-161.
// Oracle CDO: Health==200; Speed==600.0; Name=="Single".
// Leaf InheritedHealth remains 100 (documented CDO boundary); Armor==50.
// Extra: zeros/empty Name; two locals independent. FixtureIsolated.

UCLASS()
class ACoverageClassFeaturesSingleDefaultActor : AActor
{
	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	float Speed = 500.0f;

	UPROPERTY()
	FString Name = "Base";

	default Health = 200;
	default Speed = 600.0f;
	default Name = "Single";
}

UCLASS()
class ACoverageClassFeaturesInheritedDefaultBaseActor : AActor
{
	UPROPERTY()
	int InheritedHealth = 100;
}

UCLASS()
class ACoverageClassFeaturesInheritedDefaultLeafActor : ACoverageClassFeaturesInheritedDefaultBaseActor
{
	default InheritedHealth = 300;

	UPROPERTY()
	int Armor = 50;
}

int Observe_SingleDefault_Health(ACoverageClassFeaturesSingleDefaultActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultKeywordOverride setup: required Actor is null");
	}
	return Actor.Health;
}

float Observe_SingleDefault_Speed(ACoverageClassFeaturesSingleDefaultActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultKeywordOverride setup: required Actor is null");
	}
	return Actor.Speed;
}

FString Observe_SingleDefault_Name(ACoverageClassFeaturesSingleDefaultActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultKeywordOverride setup: required Actor is null");
	}
	return Actor.Name;
}

int Observe_LeafInheritedHealth_CDOBoundary(ACoverageClassFeaturesInheritedDefaultLeafActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultKeywordOverride setup: required Actor is null");
	}
	return Actor.InheritedHealth;
}

int Observe_LeafArmor_Default(ACoverageClassFeaturesInheritedDefaultLeafActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultKeywordOverride setup: required Actor is null");
	}
	return Actor.Armor;
}

bool Observe_SingleDefault_ZeroAndIndependence(ACoverageClassFeaturesSingleDefaultActor First, ACoverageClassFeaturesSingleDefaultActor Second)
{
	if (First is null)
	{
		throw("Test_DefaultKeywordOverride setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DefaultKeywordOverride setup: required Second is null");
	}
	First.Health = 0;
	First.Speed = 0.0f;
	First.Name = "";
	return First.Health == 0 && First.Name.Len() == 0 && Second.Health == 200 && Second.Name == "Single";
}
