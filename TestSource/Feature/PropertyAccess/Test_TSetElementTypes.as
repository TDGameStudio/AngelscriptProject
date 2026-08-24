// Theme: Feature.PropertyAccess. WorldStory TSet of FString/FName/enum/FVector.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetElementTypes
// After BeginPlay: StringSet 4 + bStringContains, NameSet 4 + bNameContains,
// EnumSet 3 + bEnumContains, VectorSet 3 + bVectorContains.
// Extra: local construct empty sets and false flags; copy independence.
// FixtureIsolated. Keep VerifyByPath UPROPERTY names.

enum class ETestEnum
{
	Alpha,
	Beta,
	Gamma,
	Delta
}

UCLASS()
class ACoverageTSetElementTypesActor : AActor
{
	UPROPERTY()
	TSet<FString> StringSet;

	UPROPERTY()
	TSet<FName> NameSet;

	UPROPERTY()
	TSet<ETestEnum> EnumSet;

	UPROPERTY()
	TSet<FVector> VectorSet;

	UPROPERTY()
	bool bStringContains = false;

	UPROPERTY()
	bool bNameContains = false;

	UPROPERTY()
	bool bEnumContains = false;

	UPROPERTY()
	bool bVectorContains = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// FString set
		StringSet.Add("Apple");
		StringSet.Add("Banana");
		StringSet.Add("Cherry");
		StringSet.Add("Date");
		bStringContains = StringSet.Contains("Banana");

		// FName set
		NameSet.Add(n"Red");
		NameSet.Add(n"Green");
		NameSet.Add(n"Blue");
		NameSet.Add(n"Yellow");
		bNameContains = NameSet.Contains(n"Green");

		// Enum set
		EnumSet.Add(ETestEnum::Alpha);
		EnumSet.Add(ETestEnum::Beta);
		EnumSet.Add(ETestEnum::Gamma);
		bEnumContains = EnumSet.Contains(ETestEnum::Beta);

		// FVector set
		VectorSet.Add(FVector(1.0, 0.0, 0.0));
		VectorSet.Add(FVector(0.0, 1.0, 0.0));
		VectorSet.Add(FVector(0.0, 0.0, 1.0));
		bVectorContains = VectorSet.Contains(FVector(0.0, 1.0, 0.0));
	}
}

bool Observe_TSetElementTypes_DefaultEmpty(ACoverageTSetElementTypesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetElementTypes setup: required Actor is null");
	}
	return Actor.StringSet.Num() == 0
		&& Actor.NameSet.Num() == 0
		&& Actor.EnumSet.Num() == 0
		&& Actor.VectorSet.Num() == 0
		&& Actor.bStringContains == false
		&& Actor.bNameContains == false
		&& Actor.bEnumContains == false
		&& Actor.bVectorContains == false;
}

bool Observe_TSetElementTypes_CopyIndependence(ACoverageTSetElementTypesActor First, ACoverageTSetElementTypesActor Second)
{
	if (First is null)
	{
		throw("Test_TSetElementTypes setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetElementTypes setup: required Second is null");
	}
	First.StringSet.Add("Apple");
	First.NameSet.Add(n"Red");
	return First.StringSet.Num() == 1 && Second.StringSet.Num() == 0
		&& First.NameSet.Num() == 1 && Second.NameSet.Num() == 0;
}
