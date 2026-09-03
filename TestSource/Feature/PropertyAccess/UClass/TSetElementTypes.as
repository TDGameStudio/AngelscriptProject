/**
 * TSet of FString/FName/enum/FVector on a spawned actor. After BeginPlay: StringSet 4
 * + bStringContains, NameSet 4 + bNameContains, EnumSet 3 + bEnumContains, VectorSet 3
 * + bVectorContains. Keep those VerifyByPath UPROPERTY names.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetElementTypes
 * @Harness UClass
 * @Tag Feature.PropertyAccess.TSetElementTypes
 * @Provenance Theme: Feature.PropertyAccess. WorldStory TSet of FString/FName/enum/FVector.
 * @Provenance C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetElementTypes
 * @Provenance After BeginPlay: StringSet 4 + bStringContains, NameSet 4 + bNameContains,
 * @Provenance EnumSet 3 + bEnumContains, VectorSet 3 + bVectorContains.
 * @Provenance Extra: local construct empty sets and false flags; copy independence.
 * @Provenance FixtureIsolated. Keep VerifyByPath UPROPERTY names.
 */

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

	/**
	 * WorldStory: BeginPlay fills each typed set and records one Contains flag per type.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetElementTypes
	 * @Inputs none
	 * @Return the four sets and their Contains flags
	 */
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

	/**
	 * Observe a locally constructed actor: empty sets and false Contains flags.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetElementTypes
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when every set is empty and every Contains flag is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetElementTypes_DefaultEmpty()
	{
		if (StringSet.Num() != 0)
		{
			return false;
		}
		if (NameSet.Num() != 0)
		{
			return false;
		}
		if (EnumSet.Num() != 0)
		{
			return false;
		}
		if (VectorSet.Num() != 0)
		{
			return false;
		}
		if (bStringContains)
		{
			return false;
		}
		if (bNameContains)
		{
			return false;
		}
		if (bEnumContains)
		{
			return false;
		}
		return !bVectorContains;
	}

	/**
	 * Observe that writing this actor leaves another actor's sets empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetElementTypes
	 * @Inputs a second actor that must stay empty
	 * @Return true when this StringSet and NameSet have 1 and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetElementTypes_CopyIndependence(ACoverageTSetElementTypesActor Second)
	{
		if (Second is null)
		{
			throw("TSetElementTypes setup: required Second is null");
		}
		StringSet.Add("Apple");
		NameSet.Add(n"Red");
		if (StringSet.Num() != 1)
		{
			return false;
		}
		if (Second.StringSet.Num() != 0)
		{
			return false;
		}
		if (NameSet.Num() != 1)
		{
			return false;
		}
		return Second.NameSet.Num() == 0;
	}
}
