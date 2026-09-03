/**
 * Default keyword on a single class and on a leaf. C++ CDO Health==200, Speed==600,
 * Name=="Single". The leaf InheritedHealth remains 100 (documented CDO boundary)
 * while Armor==50.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.DefaultKeywordOverride
 * @Harness UClass
 * @Tag Feature.Inheritance.DefaultKeywordOverride
 * @Provenance Theme: Feature.Inheritance. WorldStory default keyword on single class and leaf.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::DefaultKeywordOverride
 * @Provenance sha256 from theme-refs TS-FEAT-0010; lines 128-161.
 * @Provenance Oracle CDO: Health==200; Speed==600.0; Name=="Single".
 * @Provenance Leaf InheritedHealth remains 100 (documented CDO boundary); Armor==50.
 * @Provenance Extra: zeros/empty Name; two locals independent. FixtureIsolated.
 */

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

	/**
	 * Observe the default Health written by the default keyword.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultKeywordOverride
	 * @Inputs a freshly constructed single-default actor
	 * @Return Health, expected to be 200
	 */
	UFUNCTION()
	int DefaultHealth()
	{
		return Health;
	}

	/**
	 * Observe the default Speed written by the default keyword.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultKeywordOverride
	 * @Inputs a freshly constructed single-default actor
	 * @Return Speed, expected to be 600.0
	 */
	UFUNCTION()
	float DefaultSpeed()
	{
		return Speed;
	}

	/**
	 * Observe the default Name written by the default keyword.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultKeywordOverride
	 * @Inputs a freshly constructed single-default actor
	 * @Return Name, expected to be "Single"
	 */
	UFUNCTION()
	FString DefaultName()
	{
		return Name;
	}

	/**
	 * Observe that zeroing this instance leaves another actor at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultKeywordOverride
	 * @Inputs this actor plus a second actor
	 * @Return true when this is zeroed and the other stays Health 200 / Name "Single"
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageClassFeaturesSingleDefaultActor Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultKeywordOverride setup: required Second is null");
		}
		Health = 0;
		Speed = 0.0f;
		Name = "";
		if (Health != 0)
		{
			return false;
		}
		if (Name.Len() != 0)
		{
			return false;
		}
		if (Second.Health != 200)
		{
			return false;
		}
		return Second.Name == "Single";
	}
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

	/**
	 * Observe the documented CDO boundary: leaf InheritedHealth remains 100.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultKeywordOverride
	 * @Inputs a freshly constructed leaf actor
	 * @Return InheritedHealth, expected to be 100
	 * @Boundary inherited CDO
	 */
	UFUNCTION()
	int InheritedHealthCDOBoundary()
	{
		return InheritedHealth;
	}

	/**
	 * Observe the leaf Armor default.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultKeywordOverride
	 * @Inputs a freshly constructed leaf actor
	 * @Return Armor, expected to be 50
	 */
	UFUNCTION()
	int DefaultArmor()
	{
		return Armor;
	}
}
